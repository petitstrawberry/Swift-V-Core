public struct VirtQueue {
    public var descTable: [Desc] = []
    public var availRing: Avail?
    public var usedRing: Used?

    public var queueNum: UInt32 = 0
    public var queueNumMax: UInt32 = 32
    public var queueReady: UInt32 = 0
    public var queueNotify: UInt32 = 0
    public var descAddr: UInt64 = 0
    public var driverAddr: UInt64 = 0 // Available ring
    public var deviceAddr: UInt64 = 0 // Used ring

    public mutating func reset() {
        descTable = []
        availRing = nil
        usedRing = nil
        queueNum = 0
        queueReady = 0
        queueNotify = 0
        descAddr = 0
        driverAddr = 0
        deviceAddr = 0
    }

    public mutating func loadQueue(bus: Bus) {
        guard queueNum > 0 else {
            return
        }
        descTable = (0..<queueNum).map { i in
            let descAddr = self.descAddr + 16 * UInt64(i)
            return Desc(bus: bus, addr: descAddr)
        }
        availRing = Avail(bus: bus, addr: driverAddr, ququeNum: Int(queueNum))
        usedRing = Used(bus: bus, addr: deviceAddr, ququeNum: Int(queueNum))
    }
}

extension VirtQueue {
    public struct Desc {
        public var addr: UnsafeMutablePointer<UInt64>
        public var len: UnsafeMutablePointer<UInt32>
        public var flags: UnsafeMutablePointer<UInt16>
        public var next: UnsafeMutablePointer<UInt16>

        public init(bus: Bus, addr: UInt64) {
            let index = Int(addr - bus.dram.startAddr)
            let baseAddr = withUnsafeMutablePointer(to: &bus.dram.mem[index]) {
                return $0
            }
            self.addr = UnsafeMutableRawPointer(baseAddr).bindMemory(to: UInt64.self, capacity: 1)
            self.len = UnsafeMutableRawPointer(baseAddr + 8).bindMemory(to: UInt32.self, capacity: 1)
            self.flags = UnsafeMutableRawPointer(baseAddr + 12).bindMemory(to: UInt16.self, capacity: 1)
            self.next = UnsafeMutableRawPointer(baseAddr + 14).bindMemory(to: UInt16.self, capacity: 1)
        }
    }
}

extension VirtQueue {
    public struct Avail {
        public var flags: UnsafeMutablePointer<UInt16>
        public var idx: UnsafeMutablePointer<UInt16>
        public var ring: [UnsafeMutablePointer<UInt16>]
        public var usedEvent: UnsafeMutablePointer<UInt16>

        public init(bus: Bus, addr: UInt64, ququeNum: Int) {
            let index = Int(addr - bus.dram.startAddr)
            let baseAddr = withUnsafeMutablePointer(to: &bus.dram.mem[index]) {
                return $0
            }
            self.flags = UnsafeMutableRawPointer(baseAddr).bindMemory(to: UInt16.self, capacity: 1)
            self.idx = UnsafeMutableRawPointer(baseAddr + 2).bindMemory(to: UInt16.self, capacity: 1)
            self.ring = (0..<ququeNum).map { i in
                let ringAddr = addr + 4 + 2 * UInt64(i)
                let ringIndex = Int(ringAddr - bus.dram.startAddr)
                let ringBaseAddr = withUnsafeMutablePointer(to: &bus.dram.mem[ringIndex]) {
                    return $0
                }
                return UnsafeMutableRawPointer(ringBaseAddr).bindMemory(to: UInt16.self, capacity: 1)
            }
            self.usedEvent = UnsafeMutableRawPointer(baseAddr + 4 + 2 * ququeNum)
                .bindMemory(to: UInt16.self, capacity: 1)
        }
    }
}

extension VirtQueue {
    public struct Used {
        public var flags: UnsafeMutablePointer<UInt16>
        public var idx: UnsafeMutablePointer<UInt16>
        public let ring: [Elem]

        public init(bus: Bus, addr: UInt64, ququeNum: Int) {
            let index = Int(addr - bus.dram.startAddr)
            let baseAddr = withUnsafeMutablePointer(to: &bus.dram.mem[index]) {
                return $0
            }
            self.flags = UnsafeMutableRawPointer(baseAddr).bindMemory(to: UInt16.self, capacity: 1)
            self.idx = UnsafeMutableRawPointer(baseAddr + 2).bindMemory(to: UInt16.self, capacity: 1)
            self.ring = (0..<ququeNum).map { i in
                let elemAddr = addr + 4 + 8 * UInt64(i)
                return Elem(bus: bus, addr: elemAddr)
            }
        }
    }

    public struct Elem {
        public var id: UnsafeMutablePointer<UInt32>
        public var len: UnsafeMutablePointer<UInt32>

        public init(bus: Bus, addr: UInt64) {
            let index = Int(addr - bus.dram.startAddr)
            let baseAddr = withUnsafeMutablePointer(to: &bus.dram.mem[index]) {
                return $0
            }
            self.id = UnsafeMutableRawPointer(baseAddr).bindMemory(to: UInt32.self, capacity: 1)
            self.len = UnsafeMutableRawPointer(baseAddr + 4).bindMemory(to: UInt32.self, capacity: 1)
        }
    }
}
