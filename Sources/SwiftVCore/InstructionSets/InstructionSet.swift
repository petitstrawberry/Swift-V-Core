public protocol InstructionSet {
    var instructions: [Instruction] { get }
    var csrs: [Csr] { get }
}

extension InstructionSet {
    var instructions: [Instruction] { return [] }
    var csrs: [Csr] { return [] }
}