class Mstatus: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mstatus", addr: 0x300, value: 0)
    }

    override func read(cpu: Cpu) throws -> UInt32 {
        return value
    }

    override func write(cpu: Cpu, value: UInt32) throws {
        self.value = value
    }

    func read(cpu: Cpu, field: Fields) -> UInt32 {
        return cutBits(value, mask: field.mask, shift: field.shift)
    }

    func write(cpu: Cpu, field: Fields, value: UInt32) {
        self.value = (self.value & ~field.mask) | (value << field.shift)
    }

    enum Fields {
        case sie
        case mie
        case spie
        case ube
        case mpie
        case spp
        case vs
        case mpp
        case fs
        case xs
        case mprv
        case sum
        case mxr
        case tvm
        case tw
        case tsr
        case sd

        var mask: UInt32 {
            switch self {
            case .sie: return 1 << 1
            case .mie: return 1 << 3
            case .spie: return 1 << 5
            case .ube: return 1 << 6
            case .mpie: return 1 << 7
            case .spp: return 1 << 8
            case .vs: return 0b111 << 9
            case .mpp: return 0b11 << 11
            case .fs: return 0b11 << 13
            case .xs: return 0b11 << 15
            case .mprv: return 1 << 17
            case .sum: return 1 << 18
            case .mxr: return 1 << 19
            case .tvm: return 1 << 20
            case .tw: return 1 << 21
            case .tsr: return 1 << 22
            case .sd: return 1 << 31
            }
        }

        var shift: UInt32 {
            switch self {
            case .sie: return 1
            case .mie: return 3
            case .spie: return 5
            case .ube: return 6
            case .mpie: return 7
            case .spp: return 8
            case .vs: return 9
            case .mpp: return 11
            case .fs: return 13
            case .xs: return 15
            case .mprv: return 17
            case .sum: return 18
            case .mxr: return 19
            case .tvm: return 20
            case .tw: return 21
            case .tsr: return 22
            case .sd: return 31
            }
        }
    }
}
