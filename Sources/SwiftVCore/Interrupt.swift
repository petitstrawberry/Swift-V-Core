public enum Interrupt: UInt32 {
    case supervisorSoftwareInterrupt = 1
    case machineSoftwareInterrupt = 3
    case supervisorTimerInterrupt = 5
    case machineTimerInterrupt = 7
    case supervisorExternalInterrupt = 9
    case machineExternalInterrupt = 11
}
