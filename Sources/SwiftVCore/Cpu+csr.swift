extension Cpu {
    public func readCsr(_ addr: UInt32) throws -> UInt32 {
        if let csr = csrBank.csrs[Int(addr)] {
            if csr.mode.rawValue >= mode.rawValue {
                return try csr.read(cpu: self)
            } else {
                throw Trap.exception(.illegalInstruction)
            }
        } else {
            throw Trap.exception(.illegalInstruction)
        }
    }

    public func writeCsr(_ addr: UInt32, _ newValue: UInt32) throws {
        if let csr = csrBank.csrs[Int(addr)] {
            if csr.mode.rawValue >= mode.rawValue {
                try csr.write(cpu: self, value: newValue)
            } else {
                throw Trap.exception(.illegalInstruction)
            }
        } else {
            throw Trap.exception(.illegalInstruction)
        }
    }
}