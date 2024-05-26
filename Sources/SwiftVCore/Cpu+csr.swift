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

    // Note: This function is used for cpu internal use only
    // Get access to CSR without amy checking
    public func getRawCsr<T: Csr>(_ addr: UInt32) -> T {
        return csrBank.csrs[Int(addr)] as! T
    }

    // Note: This function is used for cpu internal use only
    // Read CSR without amy checking
    public func readRawCsr(_ addr: UInt32) -> UInt32 {
        return getRawCsr(addr).value
    }

    // Note: This function is used for cpu internal use only
    // Write CSR without any checking
    public func writeRawCsr(_ addr: UInt32, _ newValue: UInt32)  {
        getRawCsr(addr).value = newValue
    }
}
