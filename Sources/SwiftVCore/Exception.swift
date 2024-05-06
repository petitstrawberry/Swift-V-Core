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
    case environmentCallFromMMode = 11
    case instructionPageFault = 12
    case loadPageFault = 13
    case storeAMOPageFault = 15

    // Get tval from exception type and pc
    func getTval(pc: UInt32, tval: UInt32) -> UInt32 {
        switch self {
        case .instructionAddressMisaligned, .instructionAccessFault,
            .breakpoint, .loadAddressMisaligned, .loadAccessFault,
            .storeAMOAddressMisaligned, .storeAMOAccessFault,
            .illegalInstruction:
            return pc
        case .instructionPageFault, .loadPageFault, .storeAMOPageFault:
            return tval
        default:
            return 0
        }
    }

    // Get epc from exception type and pc
    func getEpc(_ pc: UInt32) -> UInt32 {
        switch self {
        case .breakpoint, .environmentCallFromUMode, .environmentCallFromSMode,
            .environmentCallFromMMode, .instructionPageFault, .loadPageFault, .storeAMOPageFault:
            return pc
        default:
            return pc + 4
        }
    }
}
