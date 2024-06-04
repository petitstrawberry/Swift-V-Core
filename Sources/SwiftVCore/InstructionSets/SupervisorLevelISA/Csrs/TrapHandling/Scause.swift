extension CsrBank.RegAddr {
    static let scause: UInt32 = 0x142
}

class Scause: Mcause {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    override init() {
        super.init(name: "scause", addr: 0x342, value: 0)
    }
}
