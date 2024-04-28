let kOpcodeMax = 0b1111111
let kFunct3Max = 0b111
let kFunct7Max = 0b1111111

public struct InstructionTable {
    var typeTable: [Instruction.InstructionType?] = Array(repeating: nil, count: kOpcodeMax + 1)
    var rTable: [[[Instruction?]]] = Array(repeating:
        Array(repeating:
            Array(repeating: nil, count: kFunct3Max + 1),
            count: kFunct7Max + 1
        ),
        count: kOpcodeMax + 1
    )
    var isbTable: [[Instruction?]] = Array(repeating:
        Array(repeating: nil, count: kFunct3Max + 1),
        count: kOpcodeMax + 1
    )
    var ujTable: [Instruction?] = Array(repeating: nil, count: kOpcodeMax + 1)

    public mutating func load(instructionSets: [InstructionSet]) {
        for instructionSet in instructionSets {
            for instruction in instructionSet.instructions {
                switch instruction.type {
                case .R:
                    rTable[Int(instruction.opcode)][Int(instruction.funct7!)][Int(instruction.funct3!)] = instruction
                case .I, .S, .B:
                    isbTable[Int(instruction.opcode)][Int(instruction.funct3!)] = instruction
                case .U, .J:
                    ujTable[Int(instruction.opcode)] = instruction
                }
                typeTable[Int(instruction.opcode)] = instruction.type

                print("Loaded instruction: \(instruction.name)")
            }
        }
    }
}
