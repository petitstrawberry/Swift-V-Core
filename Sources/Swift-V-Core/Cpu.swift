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

    public init(memory: Memory = Memory()) {
        self.memory = memory
    }

    // public mutating func locateBinary(binary: [UInt8]) {
    //     for i in 0..<binary.count {
    //         memory.write(UInt64(i), binary[i])
    //     }
    // }

    public func run() {
        var interrupt: Bool = false
        var exception: Bool = false

        while (!interrupt && !exception) {
            let inst: UInt32 = memory.read(pc)
            let opcode: UInt8 = UInt8(inst & 0x7F)


            print("PC: \(pc), Opcode: \(opcode)")
        }
    }

}