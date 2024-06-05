let kOpcodeMax = 0b1111111
let kFunct3Max = 0b111
let kFunct7Max = 0b1111111
let kRs2Max = 0b11111

public struct InstructionTable {

    private var instructions: [Instruction?] = [nil]

    private var table: [[[[UInt16]]]] = Array(
        repeating: Array(
            repeating: Array(
                repeating: Array(
                    repeating: 0,
                    count: kRs2Max + 1
                ),
                count: kFunct7Max + 1
            ),
            count: kFunct3Max + 1
        ),
        count: kOpcodeMax + 1
    )

    public func getInstruction(opcode: UInt8, funct3: UInt8, funct7: UInt8, rs2: UInt8) -> Instruction? {
        let opcode = Int(opcode)
        let funct3 = Int(funct3)
        let funct7 = Int(funct7)
        let rs2 = Int(rs2)

        let index = table[opcode][funct3][funct7][rs2]
        return instructions[Int(index)]
    }

    public mutating func load(cpu: Cpu, instructionSets: [InstructionSet]) {
        for instructionSet in instructionSets {

            cpu.arch |= instructionSet.isa

            for instruction in instructionSet.instructions {
                instructions.append(instruction)
                let index = UInt16(instructions.count - 1)

                let opcode = instruction.opcode

                if let funct3 = instruction.funct3 {
                    if let funct7 = instruction.funct7 {
                        if let rs2 = instruction.rs2 {
                            table[Int(opcode)][Int(funct3)][Int(funct7)][Int(rs2)] = index
                        } else {
                            for rs2 in 0...kRs2Max {
                                table[Int(opcode)][Int(funct3)][Int(funct7)][rs2] = index
                            }
                        }
                    } else {
                        if let funct5 = instruction.funct5 {
                            for param in 0...0b11 {
                                for rs2 in 0...kRs2Max {
                                    table[Int(opcode)][Int(funct3)][Int(funct5) << 2 + param][rs2] = index
                                }
                            }
                        } else {
                            table[Int(opcode)][Int(funct3)] = Array(
                                repeating: Array(
                                    repeating: index, count: kRs2Max + 1
                                ),
                                count: kFunct7Max + 1
                            )
                        }
                    }
                } else {
                    table[Int(opcode)] = Array(
                        repeating: Array(
                            repeating: Array(
                                repeating: index, count: kRs2Max + 1
                            ),
                            count: kFunct7Max + 1
                        ),
                        count: kFunct3Max + 1
                    )
                }

                // print("Loaded instruction: \(instruction.name)")
            }
        }
    }
}
