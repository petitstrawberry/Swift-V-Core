public class Cpu {
    public enum PriviligedMode: UInt8 {
        case machine = 0b11
        case supervisor = 0b01
        case user = 0b00
    }

    var pc: UInt32 = 0
    var xregs: Xregisters = Xregisters()
    var fregs: Fregisters = Fregisters()
    var mode: PriviligedMode = .machine
    var memory: Memory
    var instructionTable = InstructionTable()
    public init(memory: Memory, instructionSets: [InstructionSet]) {
        self.memory = memory
        instructionTable.load(instructionSets: instructionSets)
    }

    public func run() {
        var interrupt: Bool = false
        var exception: Bool = false

        while (!interrupt && !exception) {
            // Fetch
            let inst: UInt32 = memory.read32(pc)
            // Decode
            let opcode: Int = Int(inst & 0x07f)

            // Execute
            if let type = instructionTable.typeTable[Int(opcode)] {
                switch type {
                case .R:
                    let funct3 = Int((inst >> 12) & 0x07)
                    let funct7 = Int((inst >> 25) & 0x7f)
                    instructionTable.rTable[opcode][funct7][funct3]?.execute(cpu: self, inst: inst)
                case .I, .S, .B:
                    let funct3 = Int((inst >> 12) & 0x07)
                    instructionTable.isbTable[opcode][funct3]?.execute(cpu: self, inst: inst)
                case .U, .J:
                    instructionTable.ujTable[opcode]?.execute(cpu: self, inst: inst)
                }
            } else {
                print("Unknown opcode: 0b\(String(opcode, radix: 2))")
                break
            }

            if pc>20 {
                break
            }

            print("PC: \(pc), Opcode: 0b\(String(opcode, radix: 2))")

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
            let reg = xregs.read(UInt32(i))
            // print unsigned, signed, binary
            print("x\(i): \(reg), \(Int32(bitPattern: reg))")
        }

    }
}
