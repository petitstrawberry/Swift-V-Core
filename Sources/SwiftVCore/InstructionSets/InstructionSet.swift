public protocol InstructionSet {
    var instructions: [Instruction] { get }
    var csrs: [Csr] { get }
    var isa: UInt32 { get }
}

extension InstructionSet {
    var instructions: [Instruction] { return [] }
    var csrs: [Csr] { return [] }
    var isa: UInt32 { return 0 }
}
