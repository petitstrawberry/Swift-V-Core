//  UART 16550

public class Clint: Device {
    static let base: UInt64 = 0x2000000
    static let size: UInt64 = 0x10000

    static let msipAddr: UInt64 = base + 0x0000
    static let mispSize: UInt64 = 0x04
    static let mtimecmpAddr: UInt64 = base + 0x4000
    static let mtimecmpSize: UInt64 = 0x08
    static let mtimeAddr: UInt64 = base + 0xbff8
    static let mtimeSize: UInt64 = 0x08

    var msip: UInt32 = 0
    var mtimecmp: UInt64 = 0
    var mtime: UInt64 = 0

    public let startAddr: UInt64 = base
    public let endAddr: UInt64 = base + size - 1

    public func read8(addr: UInt64) -> UInt8 {
        switch addr {
        case Clint.msipAddr..<Clint.msipAddr + Clint.mispSize:
            return UInt8((msip >> (addr - Clint.msipAddr)*8) & 0xff)
        case Clint.mtimecmpAddr..<Clint.mtimecmpAddr + Clint.mtimecmpSize:
            return UInt8((mtimecmp >> (addr - Clint.mtimecmpAddr)*8) & 0xff)
        case Clint.mtimeAddr..<Clint.mtimeAddr + Clint.mtimeSize:
            return UInt8((mtime >> (addr - Clint.mtimeAddr)*8) & 0xff)
        default:
            return 0
        }
    }

    public func write8(addr: UInt64, data: UInt8) {
        switch addr {
        case Clint.msipAddr..<Clint.msipAddr + Clint.mispSize:
            msip = (msip & ~(0xff << (addr - Clint.msipAddr)*8))
            | UInt32(data) << (addr - Clint.msipAddr)*8
        case Clint.mtimecmpAddr..<Clint.mtimecmpAddr + Clint.mtimecmpSize:
            mtimecmp = (mtimecmp & ~(0xff << (addr - Clint.mtimecmpAddr)*8))
            | UInt64(data) << (addr - Clint.mtimecmpAddr)*8
        case Clint.mtimeAddr..<Clint.mtimeAddr + Clint.mtimeSize:
            mtime = (mtime & ~(0xff << (addr - Clint.mtimeAddr)*8))
            | UInt64(data) << (addr - Clint.mtimeAddr)*8
        default:
            break
        }
    }

    public func tick(mip: Mip, bus: Bus) {
        mtime &+= 1
        if msip & 1 != 0 {
            mip.value = mip.value & ~Mip.Fields.mtip.mask
        }
        if mtimecmp != 0 && mtime >= mtimecmp {
            mip.value = mip.value | Mip.Fields.mtip.mask
        }
    }
}
