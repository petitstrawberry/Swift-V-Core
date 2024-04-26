public struct Cpu {
    public enum PriviligedMode: UInt8 {
        case machine = 0b11
        case supervisor = 0b01
        case user = 0b00
    }

    var pc: UInt64 = 0
    var xregs: Xregisters = Xregisters()
    var fregs: Fregisters = Fregisters()
    var mode: PriviligedMode = .machine
    var memory: Memory

    public mutating func run() {
        var interrupt: Bool = false
        var exception: Bool = false

        while (!interrupt && !exception) {
            // Fetch
            let inst: UInt32 = memory.read(pc)
            // Decode
            let opcode: UInt8 = UInt8(inst & 0x07F)
            let rd: UInt8 = UInt8((inst >> 7) & 0x01F)
            let funct3: UInt8 = UInt8((inst >> 12) & 0x07)
            let rs1: UInt8 = UInt8((inst >> 15) & 0x01F)
            let rs2: UInt8 = UInt8((inst >> 20) & 0x01F)
            let funct7: UInt8 = UInt8((inst >> 25) & 0x07F)
            let imm20: UInt32 = UInt32((inst >> 12) & 0x0FFFFF)
            let imm12: UInt16 = UInt16((inst >> 20) & 0x0FFF)
            let imm7: UInt8 = UInt8((inst >> 25) & 0x07F)

            print("PC: \(pc), Opcode: 0b\(String(opcode, radix: 2))")
            // print instruction from enum
            print("Opcode: \(Instruction(rawValue: opcode).debugDescription)")

            // Execute
            switch Instruction(rawValue: opcode) {
            case .lui:
                xregs.write(rd, UInt64(imm20) << 12)
                pc += 4
            case .auipc:
                xregs.write(rd, pc + UInt64(imm20) << 12)
                pc += 4
            case .jal:
                xregs.write(rd, pc + 4)
                pc += UInt64(imm20)     // imm20[19] imm20[10:1] imm20[11] imm20[20]
            case .jalr:
                xregs.write(rd, pc + 4)
                pc = (xregs.read(rs1) + UInt64(imm12)) & ~1
            case .br:
                switch funct3 {
                case 0b000:
                    print("beq: rs1: \(rs1), rs2: \(rs2), imm12: \(imm12)")
                    if xregs.read(rs1) == xregs.read(rs2) {
                        pc += UInt64(imm12)
                    } else {
                        pc += 4
                    }
                case 0b001:
                    print("bne: rs1: \(rs1), rs2: \(rs2), imm12: \(imm12)")
                    if xregs.read(rs1) != xregs.read(rs2) {
                        pc += UInt64(imm12)
                    } else {
                        pc += 4
                    }
                case 0b100:
                    if xregs.read(rs1) < xregs.read(rs2) {
                        pc += UInt64(imm12)
                    } else {
                        pc += 4
                    }
                case 0b101:
                    if xregs.read(rs1) >= xregs.read(rs2) {
                        pc += UInt64(imm12)
                    } else {
                        pc += 4
                    }
                case 0b110:
                    if xregs.read(rs1) < xregs.read(rs2) {
                        pc += UInt64(imm12)
                    } else {
                        pc += 4
                    }
                case 0b111:
                    if xregs.read(rs1) >= xregs.read(rs2) {
                        pc += UInt64(imm12)
                    } else {
                        pc += 4
                    }
                default:
                    break
                }
            case .ld:
                let addr: UInt64 = xregs.read(rs1) + UInt64(imm12)
                xregs.write(rd, memory.read(addr))
                pc += 4
            case .st:
                let addr: UInt64 = xregs.read(rs1) + UInt64(imm12)
                memory.write(addr, xregs.read(rs2))
                pc += 4
            case .imm:
                switch funct3 {
                case 0b000:
                    print("addi: rd: \(rd), rs1: \(rs1), imm12: \(imm12)")

                    xregs.write(rd, xregs.read(rs1) + UInt64(imm12))
                    pc += 4
                case 0b010:
                    xregs.write(rd, xregs.read(rs1) < UInt64(imm12) ? 1 : 0)
                    pc += 4
                case 0b011:
                    xregs.write(rd, xregs.read(rs1) < UInt64(imm12) ? 1 : 0)
                    pc += 4
                case 0b100:
                    xregs.write(rd, xregs.read(rs1) ^ UInt64(imm12))
                    pc += 4
                case 0b110:
                    xregs.write(rd, xregs.read(rs1) | UInt64(imm12))
                    pc += 4
                case 0b111:
                    xregs.write(rd, xregs.read(rs1) & UInt64(imm12))
                    pc += 4
                case 0b001:
                    xregs.write(rd, xregs.read(rs1) << imm7)
                    pc += 4
                case 0b101:
                    switch funct7 {
                    case 0b0000000:
                        xregs.write(rd, xregs.read(rs1) >> imm7)
                        pc += 4
                    case 0b0100000:
                        xregs.write(rd, xregs.read(rs1) >> imm7)
                        pc += 4
                    default:
                        break
                    }
                default:
                    break
                }
            case .alu:
                switch funct3 {
                case 0b000:
                    switch funct7 {
                    case 0b0000000:
                        print("add: rd: \(rd), rs1: \(rs1), rs2: \(rs2) ")
                        xregs.write(rd, xregs.read(rs1) + xregs.read(rs2))
                        pc += 4
                    case 0b0100000:
                        xregs.write(rd, xregs.read(rs1) - xregs.read(rs2))
                        pc += 4
                    default:
                        break
                    }
                case 0b001:
                    // xregs.write(rd, xregs.read(rs1) + xregs.read(rs2))
                    pc += 4
                case 0b010:
                    xregs.write(rd, xregs.read(rs1) < xregs.read(rs2) ? 1 : 0)
                    pc += 4
                case 0b011:
                    xregs.write(rd, xregs.read(rs1) < xregs.read(rs2) ? 1 : 0)
                    pc += 4
                case 0b100:
                    xregs.write(rd, xregs.read(rs1) ^ xregs.read(rs2))
                    pc += 4
                case 0b110:
                    xregs.write(rd, xregs.read(rs1) | xregs.read(rs2))
                    pc += 4
                case 0b111:
                    xregs.write(rd, xregs.read(rs1) & xregs.read(rs2))
                    pc += 4
                default:
                    break
                }

            default:
                break
            }

            if pc == 20 {
                break
            }

        }
        // print memory

        // for i in stride(from: 0,
        //                 to: memory.mem.count,
        //                 by: 4) {
        //     print("0x\(String(i, radix: 16)):", terminator: " ")

        //     for j in 0..<3 {
        //         print("0x\(String(memory.mem[i + j], radix: 16))", terminator: " ")
        //     }
        //     print("0x\(String(memory.mem[i + 3], radix: 16))")
        // }

        // print registers
        for i in 0..<32 {
            print("x\(i): \(xregs.read(UInt8(i)))")
        }

    }

}