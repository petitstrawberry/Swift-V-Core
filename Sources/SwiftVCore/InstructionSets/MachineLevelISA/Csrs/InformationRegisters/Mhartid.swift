extension CsrBank.RegAddr {
    static let mhartid: UInt32 = 0x342
}

class Mhartid: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mhartid", addr: 0xf14, value: 0)
    }

    override func read(cpu: Cpu) throws -> UInt32 {
        return cpu.hartid
    }

    override func write(cpu: Cpu, value: UInt32) throws {
        // Can't write to mhartid
        throw Trap.exception(.illegalInstruction)
    }
}
