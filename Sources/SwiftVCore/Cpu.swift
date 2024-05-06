public class Cpu {

    public enum PriviligedMode: UInt32 {
        case machine = 0b11
        case supervisor = 0b01
        case user = 0b00
    }

    var pc: UInt32 = 0
    var xregs: Xregisters = Xregisters()
    var fregs: Fregisters = Fregisters()
    var csrBank: CsrBank = CsrBank()

    var mode: PriviligedMode = .machine
    var memory: Memory
    var instructionTable = InstructionTable()

    public init(memory: Memory, instructionSets: [InstructionSet]) {
        self.memory = memory
        instructionTable.load(instructionSets: instructionSets)
        csrBank.load(instructionSets: instructionSets)
    }


    enum CpuError: Error {
        case panic(String) // もうどうしよううもない時にpanic
        case notImplemented
    }

    public func panic(msg: String) throws {
        print("Panic")
        throw CpuError.panic(msg)
    }

    public func run() {
        var halt = false

        while (!halt) {
            // Fetch
            let inst: UInt32 = memory.read32(pc)

            // Decode
            let opcode: Int = Int(inst & 0b111_1111)
            print("PC: 0x\(String(pc, radix: 16)) inst: 0b\(String(inst, radix: 2)) Opcode: 0b\(String(opcode, radix: 2))")
            do {
                // Execute
                if let type = instructionTable.typeTable[Int(opcode)] {
                    switch type {
                    case .R:
                        let funct3 = Int((inst >> 12) & 0x07)
                        let funct7 = Int((inst >> 25) & 0x7f)
                        try instructionTable.rTable[opcode][funct7][funct3]?.execute(cpu: self, inst: inst)
                    case .I, .S, .B:
                        let funct3 = Int((inst >> 12) & 0x07)
                        try instructionTable.isbTable[opcode][funct3]?.execute(cpu: self, inst: inst)
                    case .U, .J:
                        try instructionTable.ujTable[opcode]?.execute(cpu: self, inst: inst)
                    }
                } else {
                    print("Unknown opcode: 0b\(String(opcode, radix: 2))")
                    // break
                    throw Trap.exception(.illegalInstruction, tval: pc)
                }
            } catch Trap.interrupt(let interrupt, tval: let tval) {
                do {
                    // TODO: Interrupt
                    // try handleTrap(interrupt: true, trap: interrupt.rawValue, tval: tval)
                } catch {
                    print("Trap Error: \(error.localizedDescription)")
                    halt = true
                }
            } catch Trap.exception(let exception, tval: let tval) {
                do {
                    try handleTrap(interrupt: false, trap: exception.rawValue, tval: tval)
                } catch {
                    print("Trap Error: \(error.localizedDescription)")
                    halt = true
                }
            } catch {
                print("Unknown Trap: \(error.localizedDescription)")
                halt = true
            }
        }
        // print registers
        for i in 0..<32 {
            let reg = xregs.read(UInt32(i))
            // print unsigned, signed, binary
            print("\(Xregisters.RegName(rawValue: i)!): \(reg), \(Int32(bitPattern: reg))", terminator: ", ")
        }
        print()
    }
}
