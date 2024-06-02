struct Zifencei: InstructionSet {
    var csrs: [Csr] = []
    var instructions: [Instruction] = [
        Instruction(name: "FENCE.I", type: .I, opcode: 0b0001111, funct3: 0b001) { cpu, inst in
            cpu.pc &+= 4
        },
    ]
}