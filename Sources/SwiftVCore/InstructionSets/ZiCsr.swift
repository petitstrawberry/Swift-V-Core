// RV32/64 Zicsr Standard Extension
struct ZiCsr: InstructionSet {
    var csrs: [Csr] = []
    var instructions: [Instruction] = [
        // CSRRW
        Instruction(name: "CSRRW", type: .I, opcode: 0b1110011, funct3: 0b001) { cpu, inst in
            let csr = inst >> 20
            let rs1 = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let regVal = cpu.xregs.read(rs1)

            if rd > 0 {
                let csrVal = try cpu.readCsr(csr)
                cpu.xregs.write(rd, csrVal)
            }
            try cpu.writeCsr(csr, regVal)
            cpu.pc &+= 4
        },
        // CSRRS
        Instruction(name: "CSRRS", type: .I, opcode: 0b1110011, funct3: 0b010) { cpu, inst in
            let csr = inst >> 20
            let rs1 = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let csrVal = try cpu.readCsr(csr)
            let writeBit = cpu.xregs.read(rs1)
            cpu.xregs.write(rd, csrVal)

            if writeBit > 0 {
                try cpu.writeCsr(csr, csrVal | writeBit)
            }
            cpu.pc &+= 4
        },
        // CSRRC
        Instruction(name: "CSRRC", type: .I, opcode: 0b1110011, funct3: 0b011) { cpu, inst in
            let csr = inst >> 20
            let rs1 = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let csrVal = try cpu.readCsr(csr)
            let writeBit = cpu.xregs.read(rs1)
            cpu.xregs.write(rd, csrVal)

            if writeBit > 0 {
                try cpu.writeCsr(csr, csrVal & ~writeBit)
            }
            cpu.pc &+= 4
        },
        // CSRRWI
        Instruction(name: "CSRRWI", type: .I, opcode: 0b1110011, funct3: 0b101) { cpu, inst in
            let csr = inst >> 20
            let uimm = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            if rd > 0 {
                let csrVal = try cpu.readCsr(csr)
                cpu.xregs.write(rd, csrVal)
            }
            try cpu.writeCsr(csr, uimm)
            cpu.pc &+= 4
        },
        // CSRRSI
        Instruction(name: "CSRRSI", type: .I, opcode: 0b1110011, funct3: 0b110) { cpu, inst in
            let csr = inst >> 20
            let uimm = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let csrVal = try cpu.readCsr(csr)
            cpu.xregs.write(rd, csrVal)

            if uimm > 0 {
                try cpu.writeCsr(csr, csrVal | uimm)
            }
            cpu.pc &+= 4
        },
        // CSRRCI
        Instruction(name: "CSRRCI", type: .I, opcode: 0b1110011, funct3: 0b111) { cpu, inst in
            let csr = inst >> 20
            let uimm = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let csrVal = try cpu.readCsr(csr)
            cpu.xregs.write(rd, csrVal)

            if uimm > 0 {
                try cpu.writeCsr(csr, csrVal & ~uimm)
            }
            cpu.pc &+= 4
        }
    ]
}
