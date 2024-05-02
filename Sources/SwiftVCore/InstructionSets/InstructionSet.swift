public protocol InstructionSet {
    var instructions: [Instruction] { get }
    var csrs: [Csr] { get }
}