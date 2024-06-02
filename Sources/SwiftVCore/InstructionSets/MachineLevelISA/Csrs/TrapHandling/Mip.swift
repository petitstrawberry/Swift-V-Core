extension CsrBank.RegAddr {
    static let mip: UInt32 = 0x344
}

public class Mip: Csr {
    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        super.init(name: name, addr: addr, value: value)
    }

    init() {
        super.init(name: "mip", addr: 0x344, value: 0)
    }

    public override func read(cpu: Cpu) throws -> UInt32 {
        return value
    }

    public override func write(cpu: Cpu, value: UInt32) throws {
        self.value = value
    }

    func read(cpu: Cpu, field: Fields) -> UInt32 {
        return cutBits(value, mask: field.mask, shift: field.shift)
    }

    func write(cpu: Cpu, field: Fields, value: UInt32) {
        self.value = (self.value & ~field.mask) | (value << field.shift)
    }

    enum Fields: UInt32 {
        case ssip = 1
        case msip = 3
        case stip = 5
        case mtip = 7
        case seip = 9
        case meip = 11

        var mask: UInt32 {
            return 1 << self.rawValue
        }

        var shift: UInt32 {
            return self.rawValue
        }
    }
}
