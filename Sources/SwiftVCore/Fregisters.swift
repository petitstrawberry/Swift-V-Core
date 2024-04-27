public struct Fregisters {

    public enum RegName: Int {
        case ft0 = 0
        case ft1
        case ft2
        case ft3
        case ft4
        case ft5
        case ft6
        case ft7
        case fs0
        case fs1
        case fa0
        case fa1
        case fa2
        case fa3
        case fa4
        case fa5
        case fa6
        case fa7
        case fs2
        case fs3
        case fs4
        case fs5
        case fs6
        case fs7
        case fs8
        case fs9
        case fs10
        case fs11
        case ft8
        case ft9
        case ft10
        case ft11
    }

    private var fregs: [Float32]

    public init() {
        fregs = Array(repeating: Float32(), count: kRegisterCount)
    }

    public func read(_ reg: RegName) -> Float32 {
        return fregs[reg.rawValue]
    }

    public mutating func write(_ reg: RegName, _ value: Float32) {
        fregs[reg.rawValue] = value
    }

    public func read(_ reg: UInt32) -> Float32 {
        return fregs[Int(reg)]
    }

    public mutating func write(_ reg: UInt32, _ value: Float32) {
        fregs[Int(reg)] = value
    }
}