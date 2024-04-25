public let kMemorySize: UInt64 = 1024 * 1024 * 1024 // 256MB

public struct Memory {
    private var mem: [UInt8]

    public init(size: UInt64 = kMemorySize) {
        mem = Array(repeating: UInt8(), count: Int(size))
    }

    public func read(_ addr: UInt64) -> UInt8 {
        return mem[Int(addr)]
    }

    public func read(_ addr: UInt64) -> UInt16 {
        return UInt16(mem[Int(addr)]) | UInt16(mem[Int(addr) + 1]) << 8
    }

    public func read(_ addr: UInt64) -> UInt32 {
        return UInt32(mem[Int(addr)]) | UInt32(mem[Int(addr) + 1]) << 8
        | UInt32(mem[Int(addr) + 2]) << 16 | UInt32(mem[Int(addr) + 3]) << 24
    }

    // public func read(_ addr: UInt64) -> UInt64 {
    //     return UInt64(mem[Int(addr)]) | (UInt64(mem[Int(addr) + 1]) << 8)
    //     | (UInt64(mem[Int(addr) + 2]) << 16) | (UInt64(mem[Int(addr) + 3]) << 24)
    //     | (UInt64(mem[Int(addr) + 4]) << 32) | (UInt64(mem[Int(addr) + 5]) << 40)
    //     | (UInt64(mem[Int(addr) + 6]) << 48) | (UInt64(mem[Int(addr) + 7]) << 56)
    // }

    public func read(_ addr: UInt64, _ size: Int) -> [UInt8] {
        return Array(mem[Int(addr)..<Int(addr) + size])
    }

    public mutating func write(_ addr: UInt64, _ value: UInt8) {
        mem[Int(addr)] = value
    }

    public mutating func write(_ addr: UInt64, _ value: [UInt8]) {
        for i in 0..<value.count {
            mem[Int(addr) + i] = value[i]
        }
    }
}
