public func signExtend32(val: any BinaryInteger, bitWidth: Int = 8) -> UInt32 {
    // Sign extend
    // (bitWidth) bit -> 32 bit
    let val = UInt32(val)
    let isSigned = (val & UInt32(1 << (bitWidth - 1))) != 0
    let mask = UInt32(1 << bitWidth) - 1
    return isSigned ? (val | ~mask) : val
}

public func cutBits(_ val: UInt32, mask: UInt32, shift: UInt32) -> UInt32 {
    return (val & mask) >> shift
}
