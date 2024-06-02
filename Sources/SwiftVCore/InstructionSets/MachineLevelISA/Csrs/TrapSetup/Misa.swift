extension CsrBank.RegAddr {
    static let misa: UInt32 = 0x301
}

class Misa: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "misa", addr: 0x301, value: 0)
    }

    override func read(cpu: Cpu) throws -> UInt32 {
        return cpu.arch
    }

    override func write(cpu: Cpu, value: UInt32) throws {
        throw Trap.exception(.illegalInstruction)
    }
}
