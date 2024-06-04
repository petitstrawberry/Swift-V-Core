struct SupervisorLevelISA: InstructionSet {
    let isa = 1 << 18
    var instructions: [Instruction] = [
        Instruction(name: "SRET", type: .R, mode: .machine,
                        opcode: 0b1110011, funct3: 0b000, funct7: 0b0001000, rs2: 0b00010) { cpu, _ in
            let sstatus = cpu.getRawCsr(CsrBank.RegAddr.sstatus) as Sstatus
            let sepc = cpu.readRawCsr(CsrBank.RegAddr.sepc)

            // Restore sie from mstatus.spie value
            sstatus.write(cpu: cpu, field: .mie, value: sstatus.read(cpu: cpu, field: .spie))

            // Change mode to mstatus.spp
            cpu.mode = Cpu.PriviligedMode(rawValue: sstatus.read(cpu: cpu, field: .spp))!

            // Set spie to 1
            sstatus.write(cpu: cpu, field: .spie, value: 1)

            // Set spp to U-mode
            sstatus.write(cpu: cpu, field: .spp, value: 0)

            //　Set pc to sepc
            cpu.pc = sepc
        },
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
        },
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
