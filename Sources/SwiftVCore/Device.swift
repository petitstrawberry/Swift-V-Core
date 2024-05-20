public protocol Device {
    var startAddr: UInt64 { get }
    var endAddr: UInt64 { get }

    func read8(addr: UInt64) -> UInt8
    mutating func write8(addr: UInt64, data: UInt8)
    func read16(addr: UInt64) -> UInt16
    mutating func write16(addr: UInt64, data: UInt16)
    func read32(addr: UInt64) -> UInt32
    mutating func write32(addr: UInt64, data: UInt32)

}
