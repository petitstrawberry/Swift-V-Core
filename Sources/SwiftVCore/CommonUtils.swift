func signExtend32(val: any FixedWidthInteger, bitWidth: Int = 8) -> UInt32 {
    // Sign extend
    // (bitWidth) bit -> 32 bit
    let vali32 = UInt32(val)
    let isSigned = (vali32 & UInt32(1 << (bitWidth - 1))) != 0
    let mask = UInt32(1 << bitWidth) - 1
    return isSigned ? (vali32 | ~mask) : vali32
}