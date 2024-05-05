public enum Exception: UInt32 {
    case instructionAddressMisaligned = 0
    case instructionAccessFault = 1
    case illegalInstruction = 2
    case breakpoint = 3
    case loadAddressMisaligned = 4
    case loadAccessFault = 5
    case storeAMOAddressMisaligned = 6
    case storeAMOAccessFault = 7
    case environmentCallFromUMode = 8
    case environmentCallFromSMode = 9
    case instructionPageFault = 12
    case loadPageFault = 13
    case storeAMOPageFault = 15
}
