struct Mmu {

    enum AddressingMode: UInt8 {
        case bare = 0b0
        case sv32 = 0b1

        func getTranslator() -> VaddrTranslator.Type {
            switch self {
            case .bare:
                return Bare.self
            case .sv32:
                return Sv32.self
            }
        }
    }

    protocol VaddrTranslator {
        static func translate(vaddr: UInt32) throws -> UInt32
    }

    let cpu: Cpu

    var priviligedMode: Cpu.PriviligedMode {
        return cpu.mode
    }

    var addressingMode: AddressingMode {
        //  TODO: Implement after implementing supervisor mode
        // return cpu.readRawCsr(CsrBank.RegAddr.satp)
        return .bare
    }

    func translate(vaddr: UInt32, write: Bool) throws -> UInt32 {
        return try addressingMode.getTranslator().translate(vaddr: vaddr)
    }
}
