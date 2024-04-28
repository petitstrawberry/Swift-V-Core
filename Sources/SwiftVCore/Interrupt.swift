public struct Interrupt: Trap {
    public let exceptionCode: UInt8
    public let interrupt: Bool = true
    public let priority: UInt8
}

extension Interrupt {
    static let supervisorSoftwareInterrupt = Interrupt(exceptionCode: 1, priority: 1)
    static let virtualSupervisorSoftwareInterrupt = Interrupt(exceptionCode: 2, priority: 1)
    static let machineSoftwareInterrupt = Interrupt(exceptionCode: 3, priority: 1)
    static let supervisorTimerInterrupt = Interrupt(exceptionCode: 5, priority: 1)
    static let virtualSupervisorTimerInterrupt = Interrupt(exceptionCode: 6, priority: 1)
    static let machineTimerInterrupt = Interrupt(exceptionCode: 7, priority: 1)
    static let supervisorExternalInterrupt = Interrupt(exceptionCode: 9, priority: 1)
    static let virtualSupervisorExternalInterrupt = Interrupt(exceptionCode: 10, priority: 1)
    static let machineExternalInterrupt = Interrupt(exceptionCode: 11, priority: 1)
    static let supervisorGuestExternalInterrupt = Interrupt(exceptionCode: 12, priority: 1)
}
