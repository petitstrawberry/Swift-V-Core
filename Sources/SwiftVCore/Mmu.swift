public struct Mmu {

    public enum AddressingMode: UInt8 {
        case bare = 0b0
        case sv32 = 0b1
    }

    public enum AccessType {
        case instruction
        case load
        case store
    }

    func getAddressingMode(cpu: Cpu) -> AddressingMode {
        return try! cpu.readRawCsr(CsrBank.RegAddr.satp) & 0x8000_0000 == 0 ? .bare : .sv32
    }

    protocol VaddrTranslator {
        static var vaddrSize: Int { get }
        static var pageSize: Int { get }
        static var pteSize: Int { get }

        func translate(cpu: Cpu, vaddr: UInt32, accessType: AccessType) throws -> UInt32
    }

    let bareVaddrTranslator: Bare
    let sv32VaddrTranslator: Sv32

    init() {
        self.bareVaddrTranslator = Bare()
        self.sv32VaddrTranslator = Sv32()
    }

    mutating func translate(cpu: Cpu, vaddr: UInt32, accessType: AccessType) throws -> UInt32 {
        let addressingMode = getAddressingMode(cpu: cpu)
        let translator: any VaddrTranslator = switch addressingMode {
        case .bare:
            bareVaddrTranslator
        case .sv32:
            sv32VaddrTranslator
        }

        let satp = cpu.getRawCsr(CsrBank.RegAddr.satp) as Satp
        let asid = satp.read(cpu: cpu, field: .asid)

        let vpn = vaddr >> 12

        if addressingMode != .bare {
            if let entry = tlb.get(vpn: vpn, asid: asid, accessType: accessType) {
                return entry.ppn << 12 + vaddr & 0xfff
            }
        }

        let paddr = try translator.translate(cpu: cpu, vaddr: vaddr, accessType: accessType)

        tlb.add(entry: .init(valid: true, asid: asid, vpn: vpn, accessType: accessType, ppn: (paddr >> 12) & 0xfff))

        return paddr
    }

    var tlb = Tlb()
}
