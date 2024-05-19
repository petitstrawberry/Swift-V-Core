public struct Mmu {
    var tlb = Tlb()
    var tlbEnabled: Bool = true

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

    let sv32VaddrTranslator: Sv32

    init() {
        self.sv32VaddrTranslator = Sv32()
    }

    mutating func translate(cpu: Cpu, vaddr: UInt32, accessType: AccessType) throws -> UInt32 {
        let addressingMode = getAddressingMode(cpu: cpu)
        if addressingMode == .bare {
            return vaddr
        }

        let translator: any VaddrTranslator = switch addressingMode {
        case .sv32:
            sv32VaddrTranslator
        case .bare:
            fatalError()
        }

        let satp = cpu.getRawCsr(CsrBank.RegAddr.satp) as Satp
        let asid = satp.read(cpu: cpu, field: .asid)

        let vpn = vaddr >> 12

        if tlbEnabled {
            if  let entry = tlb.get(vpn: vpn, asid: asid, accessType: accessType) {
                return entry.ppn << 12 + vaddr & 0xfff
            }
        }

        let paddr = try translator.translate(cpu: cpu, vaddr: vaddr, accessType: accessType)

        if tlbEnabled {
            tlb.put(asid: asid, vpn: vpn, ppn: paddr >> 12, accessType: accessType)
        }

        return paddr
    }
}
