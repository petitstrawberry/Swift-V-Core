import Foundation

public enum Trap: Error {
    case exception(_ trap: Exception, tval: UInt32 = 0)
    case interrupt(_ trap: Interrupt, tval: UInt32 = 0)
}
