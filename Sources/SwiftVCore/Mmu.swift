struct Mmu {

    enum AddressingMode: UInt8 {
        case bare = 0b0
        case sv32 = 0b1
    }

    func getAddressingMode(cpu: Cpu) -> AddressingMode {
        return try! cpu.readRawCsr(CsrBank.RegAddr.satp) & 0x8000_0000 == 0 ? .bare : .sv32
    }

    protocol VaddrTranslator {
        static var vaddrSize: Int { get }
        static var pageSize: Int { get }
        static var pteSize: Int { get }

        func translate(cpu: Cpu, vaddr: UInt32) throws -> UInt32
    }

    let bareVaddrTranslator: Bare
    let sv32VaddrTranslator: Sv32

    init() {
        self.bareVaddrTranslator = Bare()
        self.sv32VaddrTranslator = Sv32()
    }

    func translate(cpu: Cpu, vaddr: UInt32, write: Bool) throws -> UInt32 {
        let addressingMode = getAddressingMode(cpu: cpu)
        let translator: any VaddrTranslator = switch addressingMode {
        case .bare:
            bareVaddrTranslator
        case .sv32:
            sv32VaddrTranslator
        }

        return try translator.translate(cpu: cpu, vaddr: vaddr)
    }
}
