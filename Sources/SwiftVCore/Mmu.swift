struct Mmu {
    let cpu: Cpu

    var priviligedMode: Cpu.PriviligedMode {
        return cpu.mode
    }

    enum AddressingMode: UInt8 {
        case bare = 0b0
        case sv32 = 0b1
    }

    var addressingMode: AddressingMode {
        //  TODO: Implement after implementing supervisor mode
        // return cpu.readRawCsr(CsrBank.RegAddr.satp)
        return .bare
    }

    protocol VaddrTranslator {
        var cpu: Cpu { get }
        static var vaddrSize: Int { get }
        static var pageSize: Int { get }
        static var pteSize: Int { get }

        func translate(vaddr: UInt32) throws -> UInt32
    }

    let bareVaddrTranslator: Bare
    let sv32VaddrTranslator: Sv32

    init(cpu: Cpu) {
        self.cpu = cpu
        self.bareVaddrTranslator = Bare(cpu: cpu)
        self.sv32VaddrTranslator = Sv32(cpu: cpu)
    }

    func translate(vaddr: UInt32, write: Bool) throws -> UInt32 {
        let translator: any VaddrTranslator = switch addressingMode {
        case .bare:
            bareVaddrTranslator
        case .sv32:
            sv32VaddrTranslator
        }

        return try translator.translate(vaddr: vaddr)
    }
}
