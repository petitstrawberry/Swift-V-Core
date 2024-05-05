import Foundation

public enum Trap: Error {
    case exception(Exception)
    case interrupt(Interrupt)
}
