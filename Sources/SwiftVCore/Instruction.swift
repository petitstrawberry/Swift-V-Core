import Foundation

struct Instruction: Identifiable {
    let id = UUID()
    let name: String
    let opcode: UInt8
    let funct3: UInt8?
    let funct7: UInt8?

    let closure: (Cpu, UInt32) -> Void

    func execute(cpu: Cpu, inst: UInt32) {
        closure(cpu, inst)
    }
}