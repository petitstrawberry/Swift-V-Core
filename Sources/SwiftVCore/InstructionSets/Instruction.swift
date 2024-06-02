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
    public let mode: Cpu.PriviligedMode
    public let opcode: UInt8
    public let funct3: UInt8?
    public let funct7: UInt8?
    public let funct5: UInt8?

    public let closure: (Cpu, UInt32) throws -> Void

    public init(name: String, type: InstructionType, mode: Cpu.PriviligedMode = .user,
                opcode: UInt8, funct3: UInt8? = nil,
                closure: @escaping (Cpu, UInt32) throws -> Void) {
        self.name = name
        self.type = type
        self.mode = mode
        self.opcode = opcode
        self.funct3 = funct3
        self.funct5 = nil
        self.funct7 = nil
        self.closure = closure
    }

    public init(name: String, type: InstructionType, mode: Cpu.PriviligedMode = .user,
                opcode: UInt8, funct3: UInt8, funct7: UInt8,
                closure: @escaping (Cpu, UInt32) throws -> Void) {
        self.name = name
        self.type = type
        self.mode = mode
        self.opcode = opcode
        self.funct3 = funct3
        self.funct5 = nil
        self.funct7 = funct7
        self.closure = closure
    }

    public init(name: String, type: InstructionType, mode: Cpu.PriviligedMode = .user,
                opcode: UInt8, funct3: UInt8, funct5: UInt8,
                closure: @escaping (Cpu, UInt32) throws -> Void) {
        self.name = name
        self.type = type
        self.mode = mode
        self.opcode = opcode
        self.funct3 = funct3
        self.funct5 = funct5
        self.funct7 = nil
        self.closure = closure
    }

    func execute(cpu: Cpu, inst: UInt32) throws {
        // wait for interrupt
        if cpu.wfi {
            return
        }
        // check if the instruction is a privileged instruction
        if opcode == 0b1110011 {
            if cpu.mode.rawValue < mode.rawValue {
                throw Trap.exception(.illegalInstruction)
            }
        }
        try closure(cpu, inst)
    }
}
