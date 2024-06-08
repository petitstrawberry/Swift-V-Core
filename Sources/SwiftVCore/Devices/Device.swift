public protocol Device {
    var startAddr: UInt64 { get }
    var endAddr: UInt64 { get }
    var bus: Bus? { get set }

    mutating func connect(bus: Bus)

    func read8(addr: UInt64) -> UInt8
    func write8(addr: UInt64, data: UInt8)
    func read16(addr: UInt64) -> UInt16
    func write16(addr: UInt64, data: UInt16)
    func read32(addr: UInt64) -> UInt32
    func write32(addr: UInt64, data: UInt32)
}

extension Device {
    public mutating func connect(bus: Bus) {
        self.bus = bus
    }

    public func read8(addr: UInt64) -> UInt8 {
        fatalError("read8 not implemented")
    }

    public func write8(addr: UInt64, data: UInt8) {
        fatalError("write8 not implemented")
    }

    public func read16(addr: UInt64) -> UInt16 {
        return UInt16(read8(addr: addr)) | UInt16(read8(addr: addr + 1)) << 8
    }

    public func write16(addr: UInt64, data: UInt16) {
        write8(addr: addr, data: UInt8(data & 0xff))
        write8(addr: addr + 1, data: UInt8((data >> 8) & 0xff))
    }

    public func read32(addr: UInt64) -> UInt32 {
        return UInt32(read8(addr: addr))
            | UInt32(read8(addr: addr + 1)) << 8
            | UInt32(read8(addr: addr + 2)) << 16
            | UInt32(read8(addr: addr + 3)) << 24
    }

    public func write32(addr: UInt64, data: UInt32) {
        write8(addr: addr, data: UInt8(data & 0xff))
        write8(addr: addr + 1, data: UInt8((data >> 8) & 0xff))
        write8(addr: addr + 2, data: UInt8((data >> 16) & 0xff))
        write8(addr: addr + 3, data: UInt8((data >> 24) & 0xff))
    }

    public func tick(mip: Mip, bus: Bus) {}
}
