extension CsrBank.RegAddr {
    static let sstatus: UInt32 = 0x100
}

class Sstatus: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "sstatus", addr: 0x100, value: 0)
    }

    override func read(cpu: Cpu) throws -> UInt32 {
        return cpu.readRawCsr(CsrBank.RegAddr.mstatus) & mask
    }

    override func write(cpu: Cpu, value: UInt32) throws {
        let mstatus = cpu.getRawCsr(CsrBank.RegAddr.mstatus)
        mstatus.value =  (mstatus.value & ~mask) | (value & mask)
    }

    func read(cpu: Cpu, field: Fields) -> UInt32 {
        return cutBits(cpu.readRawCsr(CsrBank.RegAddr.mstatus) & mask, mask: field.mask, shift: field.shift)
    }

    func write(cpu: Cpu, field: Fields, value: UInt32) {
        let mstatus = cpu.getRawCsr(CsrBank.RegAddr.mstatus)
        mstatus.value = (self.value & ~field.mask) | (value << field.shift)
    }

    var mask = Fields.sie.mask |
                Fields.mie.mask |
                Fields.ube.mask |
                Fields.spp.mask |
                Fields.vs.mask |
                Fields.fs.mask |
                Fields.xs.mask |
                Fields.sum.mask |
                Fields.mxr.mask |
                Fields.sd.mask

    enum Fields: UInt32 {
        case sie = 1
        case mie = 3
        case spie = 5
        case ube = 6
        case spp = 8
        case vs = 9
        case fs = 13
        case xs = 15
        case sum = 18
        case mxr = 19
        case sd = 31

        var mask: UInt32 {
            1 << self.rawValue
        }

        var shift: UInt32 {
            self.rawValue
        }
    }
}
