public protocol Trap: Equatable {
    var exceptionCode: UInt8 { get }
    var interrupt: Bool { get }
    var priority: UInt8 { get }
}