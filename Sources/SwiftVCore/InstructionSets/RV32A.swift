struct RV32A: InstructionSet {
    let instructions: [Instruction] = [
        Instruction(name: "LR.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b00010) { cpu, inst in
        }
    ]
}