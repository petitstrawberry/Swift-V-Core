struct RV32I: InstructionSet {
    let instructions: [Instruction] = [
        // LUI
        Instruction(name: "LUI", type: .U, opcode: 0b0110111) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let imm = signExtend32(val: (inst >> 12), bitWidth: 20)
            cpu.xregs.write(rd, imm)
            cpu.pc &+= 4
        },
        // AUIPC
        Instruction(name: "AUIPC", type: .U, opcode: 0b0010111) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let imm = signExtend32(val: (inst >> 12), bitWidth: 20)
            cpu.xregs.write(rd, cpu.pc &+ imm)
            cpu.pc &+= 4
        },
        // JAL
        Instruction(name: "JAL", type: .J, opcode: 0b1101111) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let imm = signExtend32(val: (inst >> 12), bitWidth: 8)
            let imm1 = signExtend32(val: (inst >> 20 & 0b11111), bitWidth: 1)
            let imm2 = signExtend32(val: (inst >> 21 & 0b1111111111), bitWidth: 10)
            let imm3 = signExtend32(val: (inst >> 31), bitWidth: 1)
            let offset = (imm3 << 20) | (imm2 << 1) | (imm1 << 11) | imm
            cpu.xregs.write(rd, cpu.pc &+ 4)
            cpu.pc &+= offset
        },
        // JALR
        Instruction(name: "JALR", type: .I, opcode: 0b1100111, funct3: 0b000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            let offset = cpu.xregs.read(rs1) &+ imm
            cpu.xregs.write(rd, cpu.pc &+ 4)
            cpu.pc = offset
        },
        // ADDI
        Instruction(name: "ADDI", type: .I, opcode: 0b0010011, funct3: 0b000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &+ imm)
            cpu.pc &+= 4
        },
        // SLTI
        Instruction(name: "SLTI", type: .I, opcode: 0b0010011, funct3: 0b010) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) < imm ? 1 : 0)
            cpu.pc &+= 4
        },
        // SLTIU
        Instruction(name: "SLTIU", type: .I, opcode: 0b0010011, funct3: 0b011) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, UInt32(bitPattern: Int32(bitPattern: cpu.xregs.read(rs1)) < Int32(bitPattern: imm) ? 1 : 0))
            cpu.pc &+= 4
        },
        // XORI
        Instruction(name: "XORI", type: .I, opcode: 0b0010011, funct3: 0b100) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) ^ imm)
            cpu.pc &+= 4
        },
        // ORI
        Instruction(name: "ORI", type: .I, opcode: 0b0010011, funct3: 0b110) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) | imm)
            cpu.pc &+= 4
        },
        // ANDI
        Instruction(name: "ANDI", type: .I, opcode: 0b0010011, funct3: 0b111) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let imm = signExtend32(val: (inst >> 20), bitWidth: 12)
            cpu.xregs.write(rd, cpu.xregs.read(rs1) & imm)
            cpu.pc &+= 4
        },
        // ADD
        Instruction(name: "ADD", type: .R, opcode: 0b0110011, funct3: 0b000, funct7: 0b0000000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &+ cpu.xregs.read(rs2))
            cpu.pc &+= 4
        },
        // SUB
        Instruction(name: "SUB", type: .R, opcode: 0b0110011, funct3: 0b000, funct7: 0b0100000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &- cpu.xregs.read(rs2))
            cpu.pc &+= 4
        },
    ]
}