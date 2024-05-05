// RV32/64 Zicsr Standard Extension
struct ZiCsr: InstructionSet {
    var csrs: [Csr] = []
    var instructions: [Instruction] = [
        // CSRRW
        Instruction(name: "csrrw", type: .I, opcode: 0b1110011, funct3: 0b001, funct7: nil) { cpu, inst in
            let csr = inst >> 20
            let rs1 = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let regVal = cpu.xregs.read(rs1)

            if rd > 0 {
                let csrVal = try cpu.readCsr(csr)
                cpu.xregs.write(rd, csrVal)
            }
            try cpu.writeCsr(csr, regVal)
        },
        // CSRRS
        Instruction(name: "csrrs", type: .I, opcode: 0b1110011, funct3: 0b010, funct7: nil) { cpu, inst in
            let csr = inst >> 20
            let rs1 = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let csrVal = try cpu.readCsr(csr)
            let writeBit = cpu.xregs.read(rs1)
            cpu.xregs.write(rd, csrVal)

            if writeBit > 0 {
                try cpu.writeCsr(csr, csrVal | writeBit)
            }
        },
        // CSRRC
        Instruction(name: "csrrc", type: .I, opcode: 0b1110011, funct3: 0b011, funct7: nil) { cpu, inst in
            let csr = inst >> 20
            let rs1 = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let csrVal = try cpu.readCsr(csr)
            let writeBit = cpu.xregs.read(rs1)
            cpu.xregs.write(rd, csrVal)

            if writeBit > 0 {
                try cpu.writeCsr(csr, csrVal & ~writeBit)
            }
        },
        // CSRRWI
        Instruction(name: "csrrwi", type: .I, opcode: 0b1110011, funct3: 0b101, funct7: nil) { cpu, inst in
            let csr = inst >> 20
            let uimm = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            if rd > 0 {
                let csrVal = try cpu.readCsr(csr)
                cpu.xregs.write(rd, csrVal)
            }
            try cpu.writeCsr(csr, uimm)
        },
        // CSRRSI
        Instruction(name: "csrrsi", type: .I, opcode: 0b1110011, funct3: 0b110, funct7: nil) { cpu, inst in
            let csr = inst >> 20
            let uimm = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let csrVal = try cpu.readCsr(csr)
            cpu.xregs.write(rd, csrVal)

            if uimm > 0 {
                try cpu.writeCsr(csr, csrVal | uimm)
            }
        },
        // CSRRCI
        Instruction(name: "csrrci", type: .I, opcode: 0b1110011, funct3: 0b111, funct7: nil) { cpu, inst in
            let csr = inst >> 20
            let uimm = (inst >> 15) & 0b11111
            let rd = (inst >> 7) & 0b11111

            let csrVal = try cpu.readCsr(csr)
            cpu.xregs.write(rd, csrVal)

            if uimm > 0 {
                try cpu.writeCsr(csr, csrVal & ~uimm)
            }
        }
    ]
}
