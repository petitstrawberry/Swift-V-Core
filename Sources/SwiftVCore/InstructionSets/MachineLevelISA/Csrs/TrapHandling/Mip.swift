class Mip: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mip", addr: 0x344, value: 0)
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
        case ssip
        case msip
        case stip
        case mtip
        case seip
        case meip

        var mask: UInt32 {
            switch self {
            case .ssip: return 1 << 1
            case .msip: return 1 << 3
            case .stip: return 1 << 5
            case .mtip: return 1 << 7
            case .seip: return 1 << 9
            case .meip: return 1 << 11
            }
        }

        var shift: UInt32 {
            switch self {
            case .ssip: return 1
            case .msip: return 3
            case .stip: return 5
            case .mtip: return 7
            case .seip: return 9
            case .meip: return 11
            }
        }
    }
}
