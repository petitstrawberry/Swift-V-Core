struct RV32A: InstructionSet {
    var isa = 1 << 0
    let instructions: [Instruction] = [
        // LR.W
        Instruction(name: "LR.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b00010) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = try cpu.readMem32(addr)
            cpu.xregs.write(rd, value)
            cpu.reservationSet.insert(addr)

            cpu.pc &+= 4
        },
        // SC.W
        Instruction(name: "SC.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b00011) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            if cpu.reservationSet.contains(addr) {
                try cpu.writeMem32(addr, data: value)
                cpu.reservationSet.remove(addr)
                cpu.xregs.write(rd, 0)
            } else {
                cpu.xregs.write(rd, 1)
            }

            cpu.pc &+= 4
        },
        // AMOSWAP.W
        Instruction(name: "AMOSWAP.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b00001) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            try cpu.writeMem32(addr, data: value)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
        // AMOADD.W
        Instruction(name: "AMOADD.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b00000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            try cpu.writeMem32(addr, data: memValue &+ value)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
        // AMOXOR.W
        Instruction(name: "AMOXOR.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b00100) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            try cpu.writeMem32(addr, data: memValue ^ value)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
        // AMOAND.W
        Instruction(name: "AMOAND.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b01100) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            try cpu.writeMem32(addr, data: memValue & value)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
        // AMOOR.W
        Instruction(name: "AMOOR.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b01000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            try cpu.writeMem32(addr, data: memValue | value)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
        // AMOMIN.W
        Instruction(name: "AMOMIN.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b10000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            let result = Int32(truncatingIfNeeded: memValue) < Int32(truncatingIfNeeded: value) ? memValue : value
            try cpu.writeMem32(addr, data: result)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
        // AMOMAX.W
        Instruction(name: "AMOMAX.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b10100) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            let result = Int32(truncatingIfNeeded: memValue) > Int32(truncatingIfNeeded: value) ? memValue : value
            try cpu.writeMem32(addr, data: result)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
        // AMOMINU.W
        Instruction(name: "AMOMINU.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b11000) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            let result = memValue < value ? memValue : value
            try cpu.writeMem32(addr, data: result)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
        // AMOMAXU.W
        Instruction(name: "AMOMAXU.W", type: .R, opcode: 0b0101111, funct3: 0b010, funct5: 0b11100) { cpu, inst in
            let rd = UInt8(inst >> 7 & 0b11111)
            let rs1 = (inst >> 15) & 0b11111
            let rs2 = (inst >> 20) & 0b11111
            let addr = cpu.xregs.read(rs1)
            let value = cpu.xregs.read(rs2)
            let memValue = try cpu.readMem32(addr)
            let result = memValue > value ? memValue : value
            try cpu.writeMem32(addr, data: result)
            cpu.xregs.write(rd, memValue)

            cpu.pc &+= 4
        },
    ]
}
