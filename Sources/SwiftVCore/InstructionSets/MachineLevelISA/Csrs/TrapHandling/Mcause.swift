class Mcause: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mcause", addr: 0x344, value: 0)
    }

    override func read(cpu: Cpu) throws -> UInt32 {
        // TODO: Check? RL
        return value
    }

    override func write(cpu: Cpu, value: UInt32) throws {
        // TODO: Check? WL
        self.value = value
    }

    func read(cpu: Cpu, field: Fields) -> UInt32 {
        // TODO: Check? RL
        return cutBits(value, mask: field.mask, shift: field.shift)
    }

    func write(cpu: Cpu, field: Fields, value: UInt32) {
        // TODO: Check? WL
        self.value = (self.value & ~field.mask) | (value << field.shift)
    }

    enum Fields {
        case interrupt
        case exceptionCode

        var mask: UInt32 {
            switch self {
            case .interrupt: return 0x8000_0000
            case .exceptionCode: return 0x7fff_ffff
            }
        }

        var shift: UInt32 {
            switch self {
            case .interrupt: return 31
            case .exceptionCode: return 0
            }
        }
    }
}
