struct SupervisorLevelISA: InstructionSet {
    let isa = 1 << 18
    var instructions: [Instruction] = [
        // SFENCE.VMA
        Instruction(name: "SFENCE.VMA", type: .R, mode: .supervisor,
                        opcode: 0b1110011, funct3: 0b000, funct7: 0b0001001) { cpu, _ in
            cpu.pc &+= 4
        },
        // SINVAL.VMA
        Instruction(name: "SINVAL.VMA", type: .R, mode: .supervisor,
                        opcode: 0b1110011, funct3: 0b000, funct7: 0b0001011) { cpu, _ in
            cpu.pc &+= 4
        },
        // SFENCE.W.INVAL / SFENCE.INVAL.IR
        Instruction(name: "SFENCE.W.INVAL/SFENCE.INVAL.IR", type: .R, mode: .supervisor,
                        opcode: 0b1110011, funct3: 0b000, funct7: 0b0001100) { cpu, _ in
            cpu.pc &+= 4
        }
    ]

    var csrs: [Csr] = [
        // Protection and Translation
        Satp(),
        // Trap Setup
        Sstatus(),
        Sie(),
        Stvec(),
        // Trap Handling
        Scause(),
        Sip()
    ]
}
