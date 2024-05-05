import Foundation
public protocol Trap: Equatable, Error {
    var exceptionCode: UInt32 { get }
    var interrupt: Bool { get }
    var priority: UInt8 { get }
    static func == (lhs: any Trap, rhs: any Trap) -> Bool
    func getCause() -> UInt32
}

extension Trap {
    public static func == (lhs: any Trap, rhs: any Trap) -> Bool {
        return lhs.exceptionCode == rhs.exceptionCode
            && lhs.interrupt == rhs.interrupt
    }

    public func getCause() -> UInt32 {
        return exceptionCode | (interrupt ? 1 : 0) << 31
    }
}