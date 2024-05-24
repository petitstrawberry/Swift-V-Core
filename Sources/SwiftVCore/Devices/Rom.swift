public let kRomSize: UInt32 = 0xf000 // 60KB

public struct Rom: Device {
    public let startAddr: UInt64 = 0x1000
    public let endAddr: UInt64 = 0x1000 + UInt64(kRomSize) - 1

    var rom: [UInt8]

    public init(size: UInt32 = kRomSize) {
        rom = Array(repeating: UInt8(), count: Int(size))
        let resetProgram: [UInt32] = [
            0x800002b7, // lui      t0,0x80000
            0xf1402573, // csrr     a0,mhartid
            0x00028067  // jr      t0 # 80000000 <_start+0x80000000>
        ]

        // write
        for (index, value) in resetProgram.enumerated() {
            rom[index * 4] = UInt8(value & 0xff)
            rom[index * 4 + 1] = UInt8((value >> 8) & 0xff)
            rom[index * 4 + 2] = UInt8((value >> 16) & 0xff)
            rom[index * 4 + 3] = UInt8((value >> 24) & 0xff)
        }
    }

    public func read8(addr: UInt64) -> UInt8 {
        return rom[Int(addr - startAddr)]
    }

    public func read16(addr: UInt64) -> UInt16 {
        let intAddr = Int(addr - startAddr)
        return UInt16(rom[intAddr]) as UInt16
            | UInt16(rom[intAddr + 1]) << 8 as UInt16
    }

    public func read32(addr: UInt64) -> UInt32 {
        let intAddr = Int(addr - startAddr)
        return UInt32(rom[intAddr]) as UInt32
            | UInt32(rom[intAddr + 1]) << 8 as UInt32
            | UInt32(rom[intAddr + 2]) << 16 as UInt32
            | UInt32(rom[intAddr + 3]) << 24 as UInt32
    }

    public mutating func write8(addr: UInt64, data: UInt8) {
        rom[Int(addr - startAddr)] = data
    }

    public mutating func write16(addr: UInt64, data: UInt16) {
        let intAddr = Int(addr - startAddr)
        rom[intAddr] = UInt8(data & 0xFF)
        rom[intAddr + 1] = UInt8((data >> 8) & 0xFF)
    }

    public mutating func write32(addr: UInt64, data: UInt32) {
        let intAddr = Int(addr - startAddr)
        rom[intAddr] = UInt8(data & 0xFF)
        rom[intAddr + 1] = UInt8((data >> 8) & 0xFF)
        rom[intAddr + 2] = UInt8((data >> 16) & 0xFF)
        rom[intAddr + 3] = UInt8((data >> 24) & 0xFF)
    }
}
