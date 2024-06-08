//  UART 16550

public class Uart: Device {
    static let size: UInt64 =  0x100

    public let startAddr: UInt64
    public let endAddr: UInt64
    public weak var bus: Bus?

    var regs: [UInt8] = [UInt8](repeating: 0, count: Int(size))

    public init(startAddr: UInt64 =  0x1000_0000) {
        self.startAddr = startAddr
        self.endAddr = startAddr + Uart.size - 1
        regs[RegAddr.lsr] = 1 << 5
    }

    public struct RegAddr {
        static let rhr = 0b000
        static let thr = 0b000
        static let ier = 0x01
        static let fcr = 0x02
        static let isr = 0x02
        static let lcr = 0x03
        static let mcr = 0x04
        static let lsr = 0x05
        static let msr = 0x06
        static let spr = 0x07
    }

    public func read8(addr: UInt64) -> UInt8 {
        switch Int(addr & 0b111) {
        case RegAddr.rhr:
            regs[RegAddr.lsr] &= ~1
            return regs[RegAddr.rhr]
        default:
            return regs[Int(addr - startAddr)]
        }
    }

    public func write8(addr: UInt64, data: UInt8) {
        switch Int(addr & 0b111) {
        case RegAddr.thr:
            print(Character(UnicodeScalar(data)), terminator: "")
        default:
            regs[Int(addr - startAddr)] = data
        }
    }
}
