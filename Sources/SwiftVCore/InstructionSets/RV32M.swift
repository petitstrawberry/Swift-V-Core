struct RV32M: InstructionSet {
    let instructions: [Instruction] = [
        // MUL
        Instruction(name: "MUL", type: .R, opcode: 0b0110011, funct3: 0b000, funct7: 0b000001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            cpu.xregs.write(rd, cpu.xregs.read(rs1) &* cpu.xregs.read(rs2))
            cpu.pc &+= 4
        },
        // MULH
        Instruction(name: "MULH", type: .R, opcode: 0b0110011, funct3: 0b001, funct7: 0b000001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let i64 = Int64(Int32(truncatingIfNeeded: cpu.xregs.read(rs1)))
                * Int64(Int32(truncatingIfNeeded: cpu.xregs.read(rs2)))
            cpu.xregs.write(rd, UInt32(truncatingIfNeeded: Int32(i64 >> 32)))
            cpu.pc &+= 4
        },
        // MULHSU
        Instruction(name: "MULHSU", type: .R, opcode: 0b0110011, funct3: 0b010, funct7: 0b000001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let i64 = Int64(Int32(truncatingIfNeeded: cpu.xregs.read(rs1))) * Int64(cpu.xregs.read(rs2))
            cpu.xregs.write(rd, UInt32(truncatingIfNeeded: Int32(i64 >> 32)))
            cpu.pc &+= 4
        },
        // MULHU
        Instruction(name: "MULHU", type: .R, opcode: 0b0110011, funct3: 0b011, funct7: 0b000001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let i64 = UInt64(truncatingIfNeeded: cpu.xregs.read(rs1)) * UInt64(truncatingIfNeeded: cpu.xregs.read(rs2))
            cpu.xregs.write(rd, UInt32(truncatingIfNeeded: Int32(i64 >> 32)))
            cpu.pc &+= 4
        },
        // DIV
        Instruction(name: "DIV", type: .R, opcode: 0b0110011, funct3: 0b100, funct7: 0b0000001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let u32Rs1 = cpu.xregs.read(rs1)
            let u32Rs2 = cpu.xregs.read(rs2)

            let dividend = Int32(truncatingIfNeeded: u32Rs1)
            let divisor = Int32(truncatingIfNeeded: u32Rs2)
            if divisor == 0 {
                cpu.xregs.write(rd, 0xffffffff)
            } else if divisor == -1 && dividend == Int32.min {
                cpu.xregs.write(rd, u32Rs1)
            } else {
                cpu.xregs.write(rd, UInt32(truncatingIfNeeded: (dividend / divisor)))
            }
            cpu.pc &+= 4
        },
        // DIVU
        Instruction(name: "DIVU", type: .R, opcode: 0b0110011, funct3: 0b101, funct7: 0b0000001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let dividend = cpu.xregs.read(rs1)
            let divisor = cpu.xregs.read(rs2)
            if divisor == 0 {
                cpu.xregs.write(rd, 0xffffffff)
            } else {
                cpu.xregs.write(rd, dividend / divisor)
            }
            cpu.pc &+= 4
        },
        // REM
        Instruction(name: "REM", type: .R, opcode: 0b0110011, funct3: 0b110, funct7: 0b0000001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let u32Rs1 = cpu.xregs.read(rs1)
            let u32Rs2 = cpu.xregs.read(rs2)
            let dividend = Int32(truncatingIfNeeded: u32Rs1)
            let divisor = Int32(truncatingIfNeeded: u32Rs2)
            if divisor == 0 {
                cpu.xregs.write(rd, u32Rs1)
            } else if divisor == -1 && dividend == Int32.min {
                cpu.xregs.write(rd, 0)
            } else {
                cpu.xregs.write(rd, UInt32(truncatingIfNeeded: (dividend % divisor)))
            }
            cpu.pc &+= 4
        },
        // REMU
        Instruction(name: "REMU", type: .R, opcode: 0b0110011, funct3: 0b111, funct7: 0b0000001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let dividend = cpu.xregs.read(rs1)
            let divisor = cpu.xregs.read(rs2)
            if divisor == 0 {
                cpu.xregs.write(rd, dividend)
            } else {
                cpu.xregs.write(rd, dividend % divisor)
            }
            cpu.pc &+= 4
        }
    ]
}
