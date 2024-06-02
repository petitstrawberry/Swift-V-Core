struct SupervisorLevelISA: InstructionSet {
    let isa = 1 << 18
    var instructions: [Instruction] = []
    var csrs: [Csr] = [
        Satp()
    ]
}
