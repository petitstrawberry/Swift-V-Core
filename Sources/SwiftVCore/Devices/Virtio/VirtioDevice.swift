public class VirtioDevice: Device {
    public let startAddr: UInt64
    public let endAddr: UInt64

    public init() {
        fatalError("Must implemented in subclass")
    }

    public init(startAddr: UInt64, endAddr: UInt64, deviceID: UInt32, queueNumMax: UInt32) {
        self.startAddr = startAddr
        self.endAddr = endAddr
        self.deviceID = deviceID
        self.queueNumMax = queueNumMax
        self.queueDescLow = Array(repeating: 0, count: Int(queueNumMax))
        self.queueDescHigh = Array(repeating: 0, count: Int(queueNumMax))
        self.queueDriverLow = Array(repeating: 0, count: Int(queueNumMax))
        self.queueDriverHigh = Array(repeating: 0, count: Int(queueNumMax))
        self.queueDeviceLow = Array(repeating: 0, count: Int(queueNumMax))
        self.queueDeviceHigh = Array(repeating: 0, count: Int(queueNumMax))
    }

    // Registers
    public let magicValue: UInt32 = 0x74726976 // ro
    public let version: UInt32 = 0x2 // ro
    public let deviceID: UInt32 // ro
    public let vendorID: UInt32 = 0x1af4 // ro
    public let deviceFeatures: [UInt32] = Array(repeating: 0, count: 2) // ro
    public var deviceFeaturesSel: UInt32 = 0 // wo
    public var driverFeatures: [UInt32] = Array(repeating: 0, count: 2) // wo
    public var driverFeaturesSel: UInt32 = 0 // wo
    public var queueSel: UInt32 = 0 // wo
    public let queueNumMax: UInt32 // ro
    public var queueNum: UInt32 = 0 // wo
    public var queueReady: UInt32 = 0 // rw
    public var queueNotify: UInt32 = 0 // wo
    public var interruptStatus: UInt32 = 0 // ro
    public var interruptAck: UInt32 = 0 // wo
    public var status: UInt32 = 0 // rw
    public var queueDescLow: [UInt32] // wo
    public var queueDescHigh: [UInt32] // wo
    public var queueDriverLow: [UInt32] // wo
    public var queueDriverHigh: [UInt32] // wo
    public var queueDeviceLow: [UInt32] // wo
    public var queueDeviceHigh: [UInt32] // wo
    public var configGeneration: UInt32 = 0 // ro
    public var config: [UInt8] = [] // rw

    // Offset, size
    public static let magicValueOffset: UInt64 = 0x0
    public static let magicValueSize: UInt64 = 0x4

    public static let versionOffset: UInt64 = 0x4
    public static let versionSize: UInt64 = 0x4

    public static let deviceIDOffset: UInt64 = 0x8
    public static let deviceIDSize: UInt64 = 0x4

    public static let vendorIDOffset: UInt64 = 0xc
    public static let vendorIDSize: UInt64 = 0x4

    public static let deviceFeaturesOffset: UInt64 = 0x10
    public static let deviceFeaturesSize: UInt64 = 0x4

    public static let deviceFeaturesSelOffset: UInt64 = 0x14
    public static let deviceFeaturesSelSize: UInt64 = 0x4

    public static let driverFeaturesOffset: UInt64 = 0x20
    public static let driverFeaturesSize: UInt64 = 0x4

    public static let driverFeaturesSelOffset: UInt64 = 0x24
    public static let driverFeaturesSelSize: UInt64 = 0x4

    public static let queueSelOffset: UInt64 = 0x30
    public static let queueSelSize: UInt64 = 0x4

    public static let queueNumMaxOffset: UInt64 = 0x34
    public static let queueNumMaxSize: UInt64 = 0x4

    public static let queueNumOffset: UInt64 = 0x38
    public static let queueNumSize: UInt64 = 0x4

    public static let queueReadyOffset: UInt64 = 0x44
    public static let queueReadySize: UInt64 = 0x4

    public static let queueNotifyOffset: UInt64 = 0x50
    public static let queueNotifySize: UInt64 = 0x4

    public static let interruptStatusOffset: UInt64 = 0x60
    public static let interruptStatusSize: UInt64 = 0x4

    public static let interruptAckOffset: UInt64 = 0x64
    public static let interruptAckSize: UInt64 = 0x4

    public static let statusOffset: UInt64 = 0x70
    public static let statusSize: UInt64 = 0x4

    public static let queueDescLowOffset: UInt64 = 0x80
    public static let queueDescLowSize: UInt64 = 0x04

    public static let queueDescHighOffset: UInt64 = 0x84
    public static let queueDescHighSize: UInt64 = 0x04

    public static let queueDriverLowOffset: UInt64 = 0x90
    public static let queueDriverLowSize: UInt64 = 0x04

    public static let queueDriverHighOffset: UInt64 = 0x94
    public static let queueDriverHighSize: UInt64 = 0x04

    public static let queueDeviceLowOffset: UInt64 = 0xa0
    public static let queueDeviceLowSize: UInt64 = 0x04

    public static let queueDeviceHighOffset: UInt64 = 0xa4
    public static let queueDeviceHighSize: UInt64 = 0x04

    public static let configGenerationOffset: UInt64 = 0xfc
    public static let configGenerationSize: UInt64 = 0x4

    public static let configOffset: UInt64 = 0x100

    public func setQueueDesc(index: Int, low: UInt32, high: UInt32) {
        queueDescLow[index] = low
        queueDescHigh[index] = high
    }

    public func setQueueDriver(index: Int, low: UInt32, high: UInt32) {
        queueDriverLow[index] = low
        queueDriverHigh[index] = high
    }

    public func setQueueDevice(index: Int, low: UInt32, high: UInt32) {
        queueDeviceLow[index] = low
        queueDeviceHigh[index] = high
    }

    // MMIO
    public func read8(addr: UInt64) -> UInt8 {
        let addr = addr - startAddr
        let offset = addr % 4

        switch addr {
        case VirtioDevice.magicValueOffset..<VirtioDevice.magicValueOffset + VirtioDevice.magicValueSize:
            return UInt8((magicValue >> (offset * 8)) & 0xff)
        case VirtioDevice.versionOffset..<VirtioDevice.versionOffset + VirtioDevice.versionSize:
            return UInt8((version >> (offset * 8)) & 0xff)
        case VirtioDevice.deviceIDOffset..<VirtioDevice.deviceIDOffset + VirtioDevice.deviceIDSize:
            return UInt8((deviceID >> (offset * 8)) & 0xff)
        case VirtioDevice.vendorIDOffset..<VirtioDevice.vendorIDOffset + VirtioDevice.vendorIDSize:
            return UInt8((vendorID >> (offset * 8)) & 0xff)
        case VirtioDevice.deviceFeaturesOffset..<VirtioDevice.deviceFeaturesOffset + VirtioDevice.deviceFeaturesSize:
            return UInt8((deviceFeatures[Int(deviceFeaturesSel)] >> (offset * 8)) & 0xff)
        case VirtioDevice.driverFeaturesOffset..<VirtioDevice.driverFeaturesOffset + VirtioDevice.driverFeaturesSize:
            return UInt8((driverFeatures[Int(driverFeaturesSel)] >> (offset * 8)) & 0xff)
        case VirtioDevice.queueNumMaxOffset..<VirtioDevice.queueNumMaxOffset + VirtioDevice.queueNumMaxSize:
            return UInt8((queueNumMax >> (offset * 8)) & 0xff)
        case VirtioDevice.queueReadyOffset..<VirtioDevice.queueReadyOffset + VirtioDevice.queueReadySize:
            return UInt8((queueReady >> (offset * 8)) & 0xff)
        case VirtioDevice.interruptStatusOffset..<VirtioDevice.interruptStatusOffset + VirtioDevice.interruptStatusSize:
            return UInt8((interruptStatus >> (offset * 8)) & 0xff)
        case VirtioDevice.statusOffset..<VirtioDevice.statusOffset + VirtioDevice.statusSize:
            return UInt8((status >> (offset * 8)) & 0xff)
        case VirtioDevice.configGenerationOffset..<VirtioDevice.configGenerationOffset + VirtioDevice.configGenerationSize:
            return UInt8((configGeneration >> (offset * 8)) & 0xff)
        case VirtioDevice.configOffset..<VirtioDevice.configOffset + UInt64(config.count):
            return config[Int(addr - VirtioDevice.configOffset)]
        default:
            return 0
        }
    }

    public func write8(addr: UInt64, data: UInt8) {
        let addr = addr - startAddr
        let offset = addr % 4

        switch addr {
        case VirtioDevice.deviceFeaturesSelOffset..<VirtioDevice.deviceFeaturesSelOffset + VirtioDevice.deviceFeaturesSelSize:
            deviceFeaturesSel = UInt32(deviceFeaturesSel & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.driverFeaturesSelOffset..<VirtioDevice.driverFeaturesSelOffset + VirtioDevice.driverFeaturesSelSize:
            driverFeaturesSel = UInt32(driverFeaturesSel & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueSelOffset..<VirtioDevice.queueSelOffset + VirtioDevice.queueSelSize:
            queueSel = UInt32(queueSel & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueNumOffset..<VirtioDevice.queueNumOffset + VirtioDevice.queueNumSize:
            queueNum = UInt32(queueNum & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueReadyOffset..<VirtioDevice.queueReadyOffset + VirtioDevice.queueReadySize:
            queueReady = UInt32(queueReady & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueNotifyOffset..<VirtioDevice.queueNotifyOffset + VirtioDevice.queueNotifySize:
            queueNotify = UInt32(queueNotify & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.interruptAckOffset..<VirtioDevice.interruptAckOffset + VirtioDevice.interruptAckSize:
            interruptAck = UInt32(interruptAck & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.statusOffset..<VirtioDevice.statusOffset + VirtioDevice.statusSize:
            status = UInt32(status & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueDescLowOffset..<VirtioDevice.queueDescLowOffset + VirtioDevice.queueDescLowSize:
            queueDescLow[Int(queueSel)]
                = UInt32(queueDescLow[Int(queueSel)] & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueDescHighOffset..<VirtioDevice.queueDescHighOffset + VirtioDevice.queueDescHighSize:
            queueDescHigh[Int(queueSel)]
                = UInt32(queueDescHigh[Int(queueSel)] & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueDriverLowOffset..<VirtioDevice.queueDriverLowOffset + VirtioDevice.queueDriverLowSize:
            queueDriverLow[Int(queueSel)]
                = UInt32(queueDriverLow[Int(queueSel)] & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueDriverHighOffset..<VirtioDevice.queueDriverHighOffset + VirtioDevice.queueDriverHighSize:
            queueDriverHigh[Int(queueSel)]
                = UInt32(queueDriverHigh[Int(queueSel)] & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueDeviceLowOffset..<VirtioDevice.queueDeviceLowOffset + VirtioDevice.queueDeviceLowSize:
            queueDeviceLow[Int(queueSel)]
                = UInt32(queueDeviceLow[Int(queueSel)] & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.queueDeviceHighOffset..<VirtioDevice.queueDeviceHighOffset + VirtioDevice.queueDeviceHighSize:
            queueDeviceHigh[Int(queueSel)]
                = UInt32(queueDeviceHigh[Int(queueSel)] & ~(0xff << offset) | UInt32(data) << offset)
        case VirtioDevice.configOffset..<VirtioDevice.configOffset + UInt64(config.count) * 4:
            config[Int(addr - VirtioDevice.configOffset)] = data
        default:
            break
        }
    }

    public func read32(addr: UInt64) -> UInt32 {
        let addr = addr - startAddr

        switch addr {
        case VirtioDevice.magicValueOffset:
            return magicValue
        case VirtioDevice.versionOffset:
            return version
        case VirtioDevice.deviceIDOffset:
            return deviceID
        case VirtioDevice.vendorIDOffset:
            return vendorID
        case VirtioDevice.deviceFeaturesOffset:
            return deviceFeatures[Int(deviceFeaturesSel)]
        case VirtioDevice.driverFeaturesOffset:
            return driverFeatures[Int(driverFeaturesSel)]
        case VirtioDevice.queueNumMaxOffset:
            return queueNumMax
        case VirtioDevice.queueReadyOffset:
            return queueReady
        case VirtioDevice.interruptStatusOffset:
            return interruptStatus
        case VirtioDevice.statusOffset:
            return status
        case VirtioDevice.configGenerationOffset:
            return configGeneration
        case VirtioDevice.configOffset:
            return UInt32(config[Int(addr - VirtioDevice.configOffset)])
        default:
            return 0
        }
    }

    public func write32(addr: UInt64, data: UInt32) {
        let addr = addr - startAddr

        switch addr {
        case VirtioDevice.deviceFeaturesSelOffset:
            deviceFeaturesSel = data
        case VirtioDevice.driverFeaturesOffset:
            driverFeatures[Int(driverFeaturesSel)] = data
        case VirtioDevice.queueSelOffset:
            queueSel = data
        case VirtioDevice.queueNumOffset:
            queueNum = data
        case VirtioDevice.queueReadyOffset:
            queueReady = data
        case VirtioDevice.queueNotifyOffset:
            queueNotify = data
        case VirtioDevice.interruptAckOffset:
            interruptAck = data
        case VirtioDevice.statusOffset:
            status = data
        case VirtioDevice.queueDescLowOffset:
            queueDescLow[Int(queueSel)] = data
        case VirtioDevice.queueDescHighOffset:
            queueDescHigh[Int(queueSel)] = data
        case VirtioDevice.queueDriverLowOffset:
            queueDriverLow[Int(queueSel)] = data
        case VirtioDevice.queueDriverHighOffset:
            queueDriverHigh[Int(queueSel)] = data
        case VirtioDevice.queueDeviceLowOffset:
            queueDeviceLow[Int(queueSel)] = data
        case VirtioDevice.queueDeviceHighOffset:
            queueDeviceHigh[Int(queueSel)] = data
        case VirtioDevice.configOffset:
            config[Int(addr - VirtioDevice.configOffset)] = UInt8(data & 0xff)
        default:
            break
        }
    }
}
