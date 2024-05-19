public let kMemorySize: UInt32 = 256 * 1024 * 1024 // 256MB

public struct Dram: Device {
    public let startAddr: UInt64 = 0x8000_0000
    public let endAddr: UInt64 = 0x8000_0000 + UInt64(kMemorySize) - 1

    var mem: [UInt8]

    public init(size: UInt32 = kMemorySize) {
        mem = Array(repeating: UInt8(), count: Int(size))
    }

    public func read8(addr: UInt64) -> UInt8 {
        return mem[Int(addr - startAddr)]
    }

    public func read16(addr: UInt64) -> UInt16 {
        let intAddr = Int(addr - startAddr)
        return UInt16(mem[intAddr]) as UInt16
            | UInt16(mem[intAddr + 1]) << 8 as UInt16
    }

    public func read32(addr: UInt64) -> UInt32 {
        let intAddr = Int(addr - startAddr)
        return UInt32(mem[intAddr]) as UInt32
            | UInt32(mem[intAddr + 1]) << 8 as UInt32
            | UInt32(mem[intAddr + 2]) << 16 as UInt32
            | UInt32(mem[intAddr + 3]) << 24 as UInt32
    }

    public mutating func write8(addr: UInt64, data: UInt8) {
        mem[Int(addr - startAddr)] = data
    }

    public mutating func write16(addr: UInt64, data: UInt16) {
        let intAddr = Int(addr - startAddr)
        mem[intAddr] = UInt8(data & 0xFF)
        mem[intAddr + 1] = UInt8((data >> 8) & 0xFF)
    }

    public mutating func write32(addr: UInt64, data: UInt32) {
        let intAddr = Int(addr - startAddr)
        mem[intAddr] = UInt8(data & 0xFF)
        mem[intAddr + 1] = UInt8((data >> 8) & 0xFF)
        mem[intAddr + 2] = UInt8((data >> 16) & 0xFF)
        mem[intAddr + 3] = UInt8((data >> 24) & 0xFF)
    }
}
