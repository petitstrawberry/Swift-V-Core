public class Plic: Device {
    static let base: UInt64 = 0xc00_0000
    static let size: UInt64 = contextBase + 2 * 4 * contextStride

    public let startAddr: UInt64 = base
    public let endAddr: UInt64 = base + size - 1

    static let interruptSourceNum: Int = 1024

    static let priorityBase: UInt64 = 0x0
    static let prioritySize: UInt64 = 0x1000
    static let pendingBase: UInt64 = 0x1000
    static let pendingSize: UInt64 = 0x80
    static let enableBase: UInt64 = 0x2000
    static let enableSize: UInt64 = 0x100
    static let enableStride: UInt64 = 0x80
    static let contextBase: UInt64 = 0x20_0000
    static let contextStride: UInt64 = 0x1000

    static let thresholdOffset: UInt64 = 0x0
    static let claimOffset: UInt64 = 0x4

    var priority: [UInt32] = Array(repeating: 0, count: interruptSourceNum)
    var pending: [UInt32] = Array(repeating: 0, count: interruptSourceNum / 32)
    var enable: [[UInt32]] = Array(
        repeating: Array(
            repeating: 0, count: interruptSourceNum / 32
        ),
        count: 8
    )
    var threshold: [UInt32] = Array(repeating: 0, count: 8)
    var claim: [UInt32] = Array(repeating: 0, count: 8)

    public func read8(addr: UInt64) -> UInt8 {
        return 0
    }

    public func write8(addr: UInt64, data: UInt8) {
    }

    public func read32(addr: UInt64) -> UInt32 {
        let addr = addr - Plic.base
        if addr % 4 != 0 {
            return 0
        }

        switch addr {
        case Plic.priorityBase..<Plic.priorityBase + Plic.prioritySize:
            return priority[Int(addr / 4)]
        case Plic.pendingBase..<Plic.pendingBase + Plic.pendingSize:
            return pending[Int(addr / 4)]
        case Plic.enableBase..<Plic.enableBase + Plic.enableSize:
            let context = Int((addr - Plic.enableBase) / Plic.enableStride)
            return enable[context][Int((addr - Plic.enableBase) / 4)]
        case Plic.contextBase..<Plic.contextBase + Plic.contextStride:
            let context = Int((addr - Plic.contextBase) / Plic.contextStride)
            let offset = (addr - Plic.contextBase) % Plic.contextStride

            switch offset {
            case Plic.thresholdOffset:
                return threshold[context]
            case Plic.claimOffset:
                return claim[context]
            default:
                return 0
            }
        default:
            return 0
        }
    }

    public func write32(addr: UInt64, data: UInt32) {
        let addr = addr - Plic.base
        if addr % 4 != 0 {
            return
        }

        switch addr {
        case Plic.priorityBase..<Plic.priorityBase + Plic.prioritySize:
            priority[Int(addr / 4)] = data
        case Plic.pendingBase..<Plic.pendingBase + Plic.pendingSize:
            pending[Int(addr / 4)] = data
        case Plic.enableBase..<Plic.enableBase + Plic.enableSize:
            let context = Int((addr - Plic.enableBase) / Plic.enableStride)
            enable[context][Int((addr - Plic.enableBase) / 4)] = data
        case Plic.contextBase..<Plic.contextBase + Plic.contextStride:
            let context = Int((addr - Plic.contextBase) / Plic.contextStride)
            let offset = (addr - Plic.contextBase) % Plic.contextStride

            switch offset {
            case Plic.thresholdOffset:
                threshold[context] = data
            case Plic.claimOffset:
                // claim[context] = data
                completeInterrupt(context: context, interrupt: Int(data))
            default:
                break
            }
        default:
            break
        }
    }

    func isEnabled(context: Int, interrupt: Int) -> Bool {
        return enable[context][interrupt / 32] & (1 << (interrupt % 32)) != 0
    }

    func completeInterrupt(context: Int, interrupt: Int) {
        pending[interrupt / 32] &= ~(1 << (interrupt % 32))
        // enable[context][interrupt / 32] &= ~(1 << (interrupt % 32))
        claim[context] = 0
    }

    func claimInterrupt(context: Int, interrupt: Int) {
        if isEnabled(context: context, interrupt: interrupt) {
            claim[context] = UInt32(interrupt)
        }
    }

    public func interruptRequest(context: Int, interrupt: Int) {
        pending[interrupt / 32] |= 1 << (interrupt % 32)
        if isEnabled(context: context, interrupt: interrupt) {
            claim[context] = UInt32(interrupt)
        }
    }

    public func tick(mip: Mip, bus: Bus) {
        // var interrupt = -1
        // for context in 0..<2 {
        //     if threshold[context] == 0 {
        //         continue
        //     }
        //     if
        // }

        // if interrupt == -1 {
        //     continue
        // }

        // if interrupt > 0 {
        //     if context % 2 == 0 {
        //         mip.value = mip.value | Mip.Fields.meip.mask
        //     } else {
        //         mip.value = mip.value | Mip.Fields.seip.mask
        //     }
        // }
        // enable[context][interrupt / 32] |= 1 << (interrupt % 32)
        // pending[interrupt / 32] |= 1 << (interrupt % 32)
    }
}
