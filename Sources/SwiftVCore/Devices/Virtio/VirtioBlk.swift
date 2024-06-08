import Foundation

public class VirtioBlk: VirtioDevice {
    public static let base: UInt64 = 0x1000_1000
    public static let size: UInt64 = 0x1000

    public static let sectorSize: UInt64 = 512

    var disk: [UInt8] = []

    required public init() {
        super.init(
            startAddr: Self.base,
            endAddr: Self.base + Self.size - 1,
            deviceID: 0x02,
            virtQueueCount: 1
        )
    }

    public func loadDiskImage(path: String) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            disk = [UInt8](data)
            print("Loaded disk image: \(path)")
        } catch {
            print("Failed to load disk image: \(error)")
        }
    }

    public func tick() {
        guard let bus = bus else {
            return
        }
        let queue = virtQueues[0]

        let plic = bus.plic

        let descs = queue.descTable
        guard let avail = queue.availRing,
            let used = queue.usedRing
        else {
            return
        }

        do {
            if queue.queueNotify != UINT32_MAX {
                queue.queueNotify = UINT32_MAX

                let descID = avail.ring[Int(queue.lastAvailIdx) % Int(queue.queueNum)].pointee

                used.ring[Int(used.idx.pointee) % Int(queue.queueNum)].id.pointee = UInt32(descID)
                used.ring[Int(used.idx.pointee) % Int(queue.queueNum)].len.pointee = 0

                let desc0 = descs[Int(descID)]
                let desc1 = descs[Int(desc0.next.pointee)]

                let sector = try UInt64(bus.read32(addr: desc0.addr.pointee))
                    | (UInt64(bus.read32(addr: desc0.addr.pointee + 4)) << 32)

                if desc0.flags.pointee & 2 == 0 {
                    // read memory data and write to disk
                    let offset = sector * Self.sectorSize
                    for i in 0..<desc1.len.pointee {
                        let data = try bus.read8(addr: desc1.addr.pointee + UInt64(i))
                        disk[Int(offset + UInt64(i))] = data
                    }
                } else {
                    // read disk data and write to memory
                    let offset = sector * Self.sectorSize
                    for i in 0..<desc1.len.pointee {
                        let data = disk[Int(offset + UInt64(i))]
                        try bus.write8(addr: desc1.addr.pointee + UInt64(i), data: data)
                    }
                }
                let desc2 = descs[Int(desc1.next.pointee)]
                desc2.addr.pointee = 0
            }
            plic.requestInterrupt(interrupt: 1)
        } catch {
            print("VirtioBlk: \(error)")
            return
        }

    }
}
