public let kMemorySize: UInt32 = 256 * 1024 * 1024 // 256MB

public struct Memory {
    var mem: [UInt8]

    public init(size: UInt32 = kMemorySize) {
        mem = Array(repeating: UInt8(), count: Int(size))
    }

    public func read(_ addr: UInt32, _ size: Int) -> [UInt8] {
        return Array(mem[Int(addr)..<Int(addr) + size])
    }

    public func read(_ addr: UInt32) -> UInt8 {
        return mem[Int(addr)]
    }

    public func read(_ addr: UInt32) -> UInt16 {
        let intAddr = Int(addr)
        return UInt16(mem[intAddr]) as UInt16
            | UInt16(mem[intAddr + 1]) << 8 as UInt16
    }

    public func read(_ addr: UInt32) -> UInt32 {
        let intAddr = Int(addr)
        return UInt32(mem[intAddr]) as UInt32
            | UInt32(mem[intAddr + 1]) << 8 as UInt32
            | UInt32(mem[intAddr + 2]) << 16 as UInt32
            | UInt32(mem[intAddr + 3]) << 24 as UInt32
    }

    public mutating func write(_ addr: UInt32, _ value: [UInt8]) {
        for i in 0..<value.count {
            mem[Int(addr) + i] = value[i]
        }
    }

    public mutating func write(_ addr: UInt32, _ value: UInt8) {
        mem[Int(addr)] = value
    }

    public mutating func write(_ addr: UInt32, _ value: UInt16) {
        let intAddr = Int(addr)
        mem[intAddr] = UInt8(value & 0xFF)
        mem[intAddr + 1] = UInt8((value >> 8) & 0xFF)
    }

    public mutating func write(_ addr: UInt32, _ value: UInt32) {
        let intAddr = Int(addr)
        mem[intAddr] = UInt8(value & 0xFF)
        mem[intAddr + 1] = UInt8((value >> 8) & 0xFF)
        mem[intAddr + 2] = UInt8((value >> 16) & 0xFF)
        mem[intAddr + 3] = UInt8((value >> 24) & 0xFF)
    }
}
