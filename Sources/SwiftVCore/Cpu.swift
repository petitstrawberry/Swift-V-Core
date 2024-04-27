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
            let opcode: UInt8 = UInt8(inst & 0x07f)
            let rd: UInt8 = UInt8((inst >> 7) & 0x01f)
            let funct3: UInt8 = UInt8((inst >> 12) & 0x07)
            let rs1: UInt8 = UInt8((inst >> 15) & 0x01f)
            let rs2: UInt8 = UInt8((inst >> 20) & 0x01f)
            let funct7: UInt8 = UInt8((inst >> 25) & 0x07f)
            let imm20: UInt64 = Cpu.Alu.signExtend64(val: (inst >> 12) & 0x0fffff, bitWidth: 20)
            let imm12: UInt64 = Cpu.Alu.signExtend64(val: (inst >> 20) & 0x0fff, bitWidth: 12)
            let imm7: UInt64 = Cpu.Alu.signExtend64(val: (inst >> 25) & 0x07f, bitWidth: 7)

            print("PC: \(pc), Opcode: 0b\(String(opcode, radix: 2))")
            // print instruction from enum
            print("Opcode: \(Instruction(rawValue: opcode).debugDescription)")

            // Execute
            switch Instruction(rawValue: opcode) {
            case .lui:
                xregs.write(rd, imm20 << 12)
                pc &+= 4
            case .auipc:
                xregs.write(rd, pc &+ imm20 << 12)
                pc &+= 4
            case .jal:
                xregs.write(rd, pc &+ 4)
                pc &+= imm20
                xregs.write(rd, pc &+ 4)
                pc = (xregs.read(rs1) &+ imm12) & ~1
            case .br:
                switch funct3 {
                case 0b000:
                    print("beq: rs1: \(rs1), rs2: \(rs2), imm12: \(imm12)")
                    if xregs.read(rs1) == xregs.read(rs2) {
                        pc &+= imm12
                    } else {
                        pc &+= 4
                    }
                case 0b001:
                    print("bne: rs1: \(rs1), rs2: \(rs2), imm12: \(imm12)")
                    if xregs.read(rs1) != xregs.read(rs2) {
                        pc &+= imm12
                    } else {
                        pc &+= 4
                    }
                default:
                    break
                }
            case .ld:
                let addr = xregs.read(rs1) &+ imm12
                xregs.write(rd, memory.read(addr))
                pc &+= 4
            case .st:
                let addr = xregs.read(rs1) &+ imm12
                memory.write(addr, xregs.read(rs2))
                pc &+= 4
            case .imm:
                switch funct3 {
                case 0b000:
                    print("addi: rd: \(rd), rs1: \(rs1), imm12: \(imm12)")

                    xregs.write(rd, xregs.read(rs1) &+ UInt64(imm12))
                    pc &+= 4
                default:
                    break
                }
            case .alu:
                switch funct3 {
                case 0b000:
                    switch funct7 {
                    case 0b0000000:
                        print("add: rd: \(rd), rs1: \(rs1), rs2: \(rs2) ")
                        xregs.write(rd, xregs.read(rs1) &+ xregs.read(rs2))
                        print("\(xregs.read(rd)) = \(xregs.read(rs1)) + \(xregs.read(rs2))")
                        pc &+= 4
                    case 0b0100000:
                        print("sub: rd: \(rd), rs1: \(rs1), rs2: \(rs2) ")
                        xregs.write(rd, xregs.read(rs1) &- xregs.read(rs2))
                        pc &+= 4
                    default:
                        break
                    }
                default:
                    break
                }

            default:
                break
            }

            if pc > 12{
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
            let reg = xregs.read(UInt64(i))
            // print unsigned, signed, binary
            print("x\(i): \(reg), \(Int64(bitPattern: reg))")
        }

    }

    static func signExtend32(val: any FixedWidthInteger, bitWidth: Int = 8) -> UInt32 {
        // Sign extend
        // (bitWidth) bit -> 32 bit
        let vali32 = UInt32(val)
        let isSigned = (vali32 & UInt32(1 << (bitWidth - 1))) != 0
        let mask = UInt32(1 << bitWidth) - 1
        return isSigned ? (vali32 | ~mask) : vali32
    }
}
