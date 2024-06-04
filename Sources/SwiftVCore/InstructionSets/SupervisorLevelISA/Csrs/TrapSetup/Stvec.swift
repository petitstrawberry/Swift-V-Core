extension CsrBank.RegAddr {
    static let stvec: UInt32 = 0x105
}

class Stvec: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "stvec", addr: 0x105, value: 0)
    }
}
