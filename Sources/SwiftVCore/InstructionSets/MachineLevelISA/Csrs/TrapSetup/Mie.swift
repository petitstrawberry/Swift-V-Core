class Mie: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mie", addr: 0x304, value: 0)
    }

    override func read(cpu: Cpu) throws -> UInt32 {
        // TODO: Check? RL
        return value
    }

    override func write(cpu: Cpu, value: UInt32) throws {
        // TODO: Check? WA
        self.value = value
    }

    func read(cpu: Cpu, field: Fields) -> UInt32 {
        // TODO: Check? RL
        return cutBits(value, mask: field.mask, shift: field.shift)
    }

    func write(cpu: Cpu, field: Fields, value: UInt32) {
        // TODO: Check? WA
        self.value = (self.value & ~field.mask) | (value << field.shift)
    }

    enum Fields {
        case ssie
        case msie
        case stie
        case mtie
        case seie
        case meie

        var mask: UInt32 {
            switch self {
            case .ssie: return 1 << 1
            case .msie: return 1 << 3
            case .stie: return 1 << 5
            case .mtie: return 1 << 7
            case .seie: return 1 << 9
            case .meie: return 1 << 11
            }
        }

        var shift: UInt32 {
            switch self {
            case .ssie: return 1
            case .msie: return 3
            case .stie: return 5
            case .mtie: return 7
            case .seie: return 9
            case .meie: return 11
            }
        }
    }
}
