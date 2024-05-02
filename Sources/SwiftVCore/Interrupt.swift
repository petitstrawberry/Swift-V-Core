public struct Interrupt: Trap {
    public let exceptionCode: UInt32
    public let interrupt: Bool = true
    public let priority: UInt8
}

extension Interrupt {
    static let supervisorSoftwareInterrupt = Interrupt(exceptionCode: 1, priority: 1)
    static let machineSoftwareInterrupt = Interrupt(exceptionCode: 3, priority: 1)
    static let supervisorTimerInterrupt = Interrupt(exceptionCode: 5, priority: 1)
    static let machineTimerInterrupt = Interrupt(exceptionCode: 7, priority: 1)
    static let supervisorExternalInterrupt = Interrupt(exceptionCode: 9, priority: 1)
    static let machineExternalInterrupt = Interrupt(exceptionCode: 11, priority: 1)
}
