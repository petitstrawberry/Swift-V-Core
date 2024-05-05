extension CsrBank.RegAddr {
    static let mstatush: UInt32 = 0x301
}

class Mstatush: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mstatush", addr: 0x301, value: 0)
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
        case sbe
        case mbe

        var mask: UInt32 {
            switch self {
            case .sbe: return 1 << 4
            case .mbe: return 1 << 5
            }
        }

        var shift: UInt32 {
            switch self {
            case .sbe: return 4
            case .mbe: return 5
            }
        }
    }
}
