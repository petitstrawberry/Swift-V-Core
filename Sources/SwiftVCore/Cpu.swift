public struct Cpu {
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
            let imm20: UInt32 = signExtend32(val: (inst >> 12) & 0x0fffff, bitWidth: 20)
            let imm12: UInt32 = signExtend32(val: (inst >> 20) & 0x0fff, bitWidth: 12)
            let imm7: UInt32 = signExtend32(val: (inst >> 25) & 0x07f, bitWidth: 7)

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
            print("x\(i): \(reg), \(Int64(bitPattern: reg))")
        }

    }
}
