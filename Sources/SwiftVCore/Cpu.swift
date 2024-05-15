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
    var mmu: Mmu = Mmu()

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

    public func readMem(_ addr: UInt32, size: UInt32) throws -> [UInt8] {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .load)
        return memory.read(addr, Int(size))
    }

    public func writeMem(_ addr: UInt32, data: [UInt8]) throws {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .store)
        memory.write(addr, data)
    }

    public func readMem8(_ addr: UInt32) throws -> UInt8 {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .load)
        return memory.read8(addr)
    }

    public func readMem16(_ addr: UInt32) throws -> UInt16 {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .load)
        return memory.read16(addr)
    }

    public func readMem32(_ addr: UInt32) throws -> UInt32 {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .load)
        return memory.read32(addr)
    }

    public func writeMem8(_ addr: UInt32, data: UInt8) throws {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .store)
        memory.write8(addr, data)
    }

    public func writeMem16(_ addr: UInt32, data: UInt16) throws {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .store)
        memory.write16(addr, data)
    }

    public func writeMem32(_ addr: UInt32, data: UInt32) throws {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .store)
        memory.write32(addr, data)
    }

    public func readRawMem8(_ addr: UInt32) -> UInt8 {
        return memory.read8(addr)
    }

    public func readRawMem16(_ addr: UInt32) -> UInt16 {
        return memory.read16(addr)
    }

    public func readRawMem32(_ addr: UInt32) -> UInt32 {
        return memory.read32(addr)
    }

    public func writeRawMem8(_ addr: UInt32, data: UInt8) {
        memory.write8(addr, data)
    }

    public func writeRawMem16(_ addr: UInt32, data: UInt16) {
        memory.write16(addr, data)
    }

    public func writeRawMem32(_ addr: UInt32, data: UInt32) {
        memory.write32(addr, data)
    }

    func fetch(addr: UInt32) throws -> UInt32 {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .instruction)
        return memory.read32(addr)
    }

    public func run() {
        var halt = false

        while (!halt) {
            do {
                // Fetch
                let inst: UInt32 = try fetch(addr: pc)

                // Decode
                let opcode: Int = Int(inst & 0b111_1111)
                print("PC: 0x\(String(pc, radix: 16)) inst: 0b\(String(inst, radix: 2)) Opcode: 0b\(String(opcode, radix: 2))")

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
