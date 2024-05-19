public protocol Device {
    var startAddr: UInt32 { get }
    var endAddr: UInt32 { get }

    func read8(addr: UInt32) -> UInt8
    mutating func write8(addr: UInt32, data: UInt8)
    func read16(addr: UInt32) -> UInt16
    mutating func write16(addr: UInt32, data: UInt16)
    func read32(addr: UInt32) -> UInt32
    mutating func write32(addr: UInt32, data: UInt32)

}
