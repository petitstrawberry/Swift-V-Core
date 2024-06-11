extension CsrBank.RegAddr {
    static let mideleg: UInt32 = 0x303
}

class Mideleg: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mideleg", addr: 0x303, value: 0)
    }

    override public func write(cpu: Cpu, value: UInt32) throws {
        self.value = (self.value & ~mask) | (value & mask)
    }

    let mask = Mip.Fields.ssip.mask | Mip.Fields.stip.mask | Mip.Fields.seip.mask
}
