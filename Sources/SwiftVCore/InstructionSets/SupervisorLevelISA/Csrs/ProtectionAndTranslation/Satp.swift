extension CsrBank.RegAddr {
    static let satp: UInt32 = 0x180
}

class Satp: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "satp", addr: 0x180, value: 0)
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
        case mode
        case asid
        case ppn

        var mask: UInt32 {
            switch self {
            case .mode: return 0x8000_0000
            case .asid: return 0x07c0_0000
            case .ppn: return 0x3f_fffff
            }
        }

        var shift: UInt32 {
            switch self {
            case .mode: return 31
            case .asid: return 22
            case .ppn: return 0
            }
        }
    }
}
