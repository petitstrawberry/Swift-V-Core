let kRegisterCount = 32

let kMemoryBase: UInt64 = 0x8000_0000
let kPointerToDtb: UInt64 = 0x1020

public struct Xregisters {
    public enum RegName: Int{
        case zero = 0
        case ra = 1
        case sp = 2
        case gp = 3
        case tp = 4
        case t0 = 5
        case t1 = 6
        case t2 = 7
        case s0 = 8
        case s1 = 9
        case a0 = 10
        case a1 = 11
        case a2 = 12
        case a3 = 13
        case a4 = 14
        case a5 = 15
        case a6 = 16
        case a7 = 17
        case s2 = 18
        case s3 = 19
        case s4 = 20
        case s5 = 21
        case s6 = 22
        case s7 = 23
        case s8 = 24
        case s9 = 25
        case s10 = 26
        case s11 = 27
        case t3 = 28
        case t4 = 29
        case t5 = 30
        case t6 = 31
    }

    private var xregs: [UInt64]

    public init() {
        xregs = Array(repeating: UInt64(), count: kRegisterCount)
        xregs[Xregisters.RegName.sp.rawValue] = kMemoryBase + kMemorySize
        xregs[Xregisters.RegName.a0.rawValue] = 0
        xregs[Xregisters.RegName.a1.rawValue] = kPointerToDtb
    }

    public func get(_ reg: RegName) -> UInt64 {
        return xregs[reg.rawValue]
    }

    public mutating func set(_ reg: RegName, _ value: UInt64) {
        xregs[reg.rawValue] = value
    }

    public func get(_ reg: UInt64) -> UInt64 {
        return xregs[Int(reg)]
    }

    public mutating func set(_ reg: UInt64, _ value: UInt64) {
        xregs[Int(reg)] = value
    }
}