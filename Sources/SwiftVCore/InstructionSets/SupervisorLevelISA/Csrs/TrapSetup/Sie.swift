extension CsrBank.RegAddr {
    static let sie: UInt32 = 0x104
}

class Sie: Mie {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    override init() {
        super.init(name: "sie", addr: 0104, value: 0)
    }

    override func read(cpu: Cpu) throws -> UInt32 {
        return  cpu.readRawCsr(CsrBank.RegAddr.mie) & cpu.readRawCsr(CsrBank.RegAddr.mideleg)
    }

    override func write(cpu: Cpu, value: UInt32) throws {
        let mask = cpu.readRawCsr(CsrBank.RegAddr.mideleg)
        let mie = cpu.getRawCsr(CsrBank.RegAddr.mie)
        mie.value = (mie.value & ~mask) | (value & mask)
    }

    override func read(cpu: Cpu, field: Fields) -> UInt32 {
        let mask = cpu.readRawCsr(CsrBank.RegAddr.mideleg)
        let mie = cpu.getRawCsr(CsrBank.RegAddr.mie)
        return cutBits(mie.value & mask, mask: field.mask, shift: field.shift)
    }

    override func write(cpu: Cpu, field: Fields, value: UInt32) {
        let mask = cpu.readRawCsr(CsrBank.RegAddr.mideleg)
        let mie = cpu.getRawCsr(CsrBank.RegAddr.mie)
        mie.value = (mie.value & ~(field.mask & mask)) | (value << field.shift)
    }
}
