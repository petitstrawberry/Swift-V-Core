class Mtvec: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mtvec", addr: 0x305, value: 0)
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
        case mode
        case base

        var mask: UInt32 {
            switch self {
            case .mode: return 0b11 << 0
            case .base: return 0xffff_fffc
            }
        }

        var shift: UInt32 {
            switch self {
            case .mode: return 0
            case .base: return 2
            }
        }
    }
}
