struct SupervisorLevelISA: InstructionSet {
    var instructions: [Instruction] = []
    var csrs: [Csr] = [
        Satp()
    ]
}
