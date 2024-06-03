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

    enum Fields {
        case sie
        case mie
        case ube
        case spp
        case vs
        case fs
        case xs
        case sum
        case mxr
        case sd

        var mask: UInt32 {
            switch self {
            case .sie: return 1 << 1
            case .mie: return 1 << 3
            case .ube: return 1 << 6
            case .spp: return 1 << 8
            case .vs: return 0b111 << 9
            case .fs: return 0b11 << 13
            case .xs: return 0b11 << 15
            case .sum: return 1 << 18
            case .mxr: return 1 << 19
            case .sd: return 1 << 31
            }
        }

        var shift: UInt32 {
            switch self {
            case .sie: return 1
            case .mie: return 3
            case .ube: return 6
            case .spp: return 8
            case .vs: return 9
            case .fs: return 13
            case .xs: return 15
            case .sum: return 18
            case .mxr: return 19
            case .sd: return 31
            }
        }
    }
}
