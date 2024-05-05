import Foundation

public struct Instruction: Identifiable {
    public enum InstructionType: String {
        case R
        case I
        case S
        case B
        case U
        case J
    }

    public let id = UUID()
    public let name: String
    public let type: InstructionType
    public let opcode: UInt8
    public let funct3: UInt8?
    public let funct7: UInt8?

    public let closure: (Cpu, UInt32) throws -> Void

    public init(name: String, type: InstructionType, opcode: UInt8, funct3: UInt8? = nil, funct7: UInt8? = nil, closure: @escaping (Cpu, UInt32) throws -> Void) {
        self.name = name
        self.type = type
        self.opcode = opcode
        self.funct3 = funct3
        self.funct7 = funct7
        self.closure = closure
    }

    func execute(cpu: Cpu, inst: UInt32) {
        print("Execute: \(name)")
        do {
            try closure(cpu, inst)
        } catch {
            print("Error: \(error)")
        }
    }
}
