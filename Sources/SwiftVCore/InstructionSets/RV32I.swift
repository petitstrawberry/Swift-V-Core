struct RV32I: InstructionSet {
    let instructions: [Instruction] = [
        // ADDI
        Instruction(name: "ADDI", type: .I, opcode: 0b0010011, funct3: 0b000, closure: { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &+ imm)
            cpu.pc &+= 4
        }),
        // ADD
        Instruction(name: "ADD", type: .R, opcode: 0b0110011, funct3: 0b000, funct7: 0b0000000, closure: { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &+ cpu.xregs.read(rs2))
            cpu.pc &+= 4
        }),
        // SUB
        Instruction(name: "SUB", type: .R, opcode: 0b0110011, funct3: 0b000, funct7: 0b0100000, closure: { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &- cpu.xregs.read(rs2))
            cpu.pc &+= 4
        }),
    ]
}