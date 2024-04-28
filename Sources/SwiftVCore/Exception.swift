public struct Exception: Trap {
    public let exceptionCode: UInt8
    public let interrupt: Bool = false
    public let priority: UInt8
}

extension Exception {
    static let instructionAddressMisaligned = Exception(exceptionCode: 0, priority: 1)
    static let instructionAccessFault = Exception(exceptionCode: 1, priority: 1)
    static let illegalInstruction = Exception(exceptionCode: 2, priority: 1)
    static let breakpoint = Exception(exceptionCode: 3, priority: 1)
    static let loadAddressMisaligned = Exception(exceptionCode: 4, priority: 1)
    static let loadAccessFault = Exception(exceptionCode: 5, priority: 1)
    static let storeAMOAddressMisaligned = Exception(exceptionCode: 6, priority: 1)
    static let storeAMOAccessFault = Exception(exceptionCode: 7, priority: 1)
    static let environmentCallFromUMode = Exception(exceptionCode: 8, priority: 1)
    static let environmentCallFromSMode = Exception(exceptionCode: 9, priority: 1)
    static let instructionPageFault = Exception(exceptionCode: 12, priority: 1)
    static let loadPageFault = Exception(exceptionCode: 13, priority: 1)
    static let storeAMOPageFault = Exception(exceptionCode: 15, priority: 1)
}


