extension CsrBank.RegAddr {
    static let medeleg: UInt32 = 0x302
}

class Medeleg: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "medeleg", addr: 0x302, value: 0)
    }
}
