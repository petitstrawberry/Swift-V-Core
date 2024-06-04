extension CsrBank.RegAddr {
    static let sip: UInt32 = 0x144
}

public class Sip: Mip {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    override init() {
        super.init(name: "sip", addr: 0x144, value: 0)
    }

    public override func read(cpu: Cpu) throws -> UInt32 {
        return  cpu.readRawCsr(CsrBank.RegAddr.mip) & cpu.readRawCsr(CsrBank.RegAddr.mideleg)

    }

    public override func write(cpu: Cpu, value: UInt32) throws {
        let mask = Fields.ssip.mask & cpu.readRawCsr(CsrBank.RegAddr.mideleg)
        let mip = cpu.getRawCsr(CsrBank.RegAddr.mip)
        mip.value = (mip.value & ~mask) | (value & mask)
    }

    override func read(cpu: Cpu, field: Fields) -> UInt32 {
        let mask = cpu.readRawCsr(CsrBank.RegAddr.mideleg)
        let mip = cpu.getRawCsr(CsrBank.RegAddr.mip)
        return cutBits(mip.value & mask, mask: field.mask, shift: field.shift)
    }

    override func write(cpu: Cpu, field: Fields, value: UInt32) {
        let mask = Fields.ssip.mask & cpu.readRawCsr(CsrBank.RegAddr.mideleg)
        let mip = cpu.getRawCsr(CsrBank.RegAddr.mip)
        mip.value = (mip.value & ~(field.mask & mask)) | (value << field.shift)
    }
}
