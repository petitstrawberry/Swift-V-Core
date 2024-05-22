public class Bus {
    var dram = Dram()
    var devices: [Device] = []

    public func addDevice(_ device: Device) {
        devices.append(device)
    }

    func read8(addr: UInt64) throws -> UInt8 {
        switch addr {
        case dram.startAddr...dram.endAddr:
            return dram.read8(addr: addr)
        default:
            for index in devices.indices {
                let device = devices[index]
                if device.startAddr <= addr && addr <= device.endAddr {
                    return device.read8(addr: addr)
                }
            }
            throw Trap.exception(.loadAccessFault)
        }
    }

    func write8(addr: UInt64, data: UInt8) throws {
        switch addr {
        case dram.startAddr...dram.endAddr:
            dram.write8(addr: addr, data: data)
        default:
            for index in devices.indices {
                let device = devices[index]
                if device.startAddr <= addr && addr <= device.endAddr {
                    devices[index].write8(addr: addr, data: data)
                    return
                }
            }
            throw Trap.exception(.storeAMOAccessFault)
        }
    }

    func read16(addr: UInt64) throws -> UInt16 {
        switch addr {
        case dram.startAddr...dram.endAddr:
            return dram.read16(addr: addr)
        default:
            for index in devices.indices {
                let device = devices[index]
                if device.startAddr <= addr && addr <= device.endAddr {
                    return device.read16(addr: addr)
                }
            }
            throw Trap.exception(.loadAccessFault)
        }
    }

    func write16(addr: UInt64, data: UInt16) throws {
        switch addr {
        case dram.startAddr...dram.endAddr:
            dram.write16(addr: addr, data: data)
        default:
            for index in devices.indices {
                let device = devices[index]
                if device.startAddr <= addr && addr <= device.endAddr {
                    devices[index].write16(addr: addr, data: data)
                    return
                }
            }
            throw Trap.exception(.storeAMOAccessFault)
        }
    }

    func read32(addr: UInt64) throws -> UInt32 {
        switch addr {
        case dram.startAddr...dram.endAddr:
            return dram.read32(addr: addr)
        default:
            for index in devices.indices {
                let device = devices[index]
                if device.startAddr <= addr && addr <= device.endAddr {
                    return device.read32(addr: addr)
                }
            }
            throw Trap.exception(.loadAccessFault)
        }
    }

    func write32(addr: UInt64, data: UInt32) throws {
        switch addr {
        case dram.startAddr...dram.endAddr:
            dram.write32(addr: addr, data: data)
        default:
            for index in devices.indices {
                let device = devices[index]
                if device.startAddr <= addr && addr <= device.endAddr {
                    devices[index].write32(addr: addr, data: data)
                    return
                }
            }
            throw Trap.exception(.storeAMOAccessFault)
        }
    }
}
