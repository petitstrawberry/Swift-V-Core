import Foundation

public class Cpu {

    public enum PriviligedMode: UInt32 {
        case machine = 0b11
        case supervisor = 0b01
        case user = 0b00
    }

    let hartid: UInt32
    var arch: UInt32 = 0

    var reservationSet: Set<UInt32> = []
    var wfi: Bool = false
    var mode: PriviligedMode = .machine
    var pc: UInt32 = 0x1000
    var cycle: UInt64 = 0

    var xregs: Xregisters = Xregisters()
    var fregs: Fregisters = Fregisters()
    var csrBank: CsrBank = CsrBank()

    var mmu: Mmu = Mmu()
    var bus: Bus

    var instructionTable = InstructionTable()

    public init(hartid: UInt32 = 0, bus: Bus, instructionSets: [InstructionSet]) {
        self.hartid = hartid
        self.bus = bus
        self.arch = 0
        instructionTable.load(cpu: self, instructionSets: instructionSets)
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

    public func readMem8(_ addr: UInt32) throws -> UInt8 {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .load)
        return try bus.read8(addr: UInt64(addr))
    }

    public func readMem16(_ addr: UInt32) throws -> UInt16 {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .load)
        return try bus.read16(addr: UInt64(addr))
    }

    public func readMem32(_ addr: UInt32) throws -> UInt32 {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .load)
        return try bus.read32(addr: UInt64(addr))
    }

    public func writeMem8(_ addr: UInt32, data: UInt8) throws {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .store)
        try bus.write8(addr: UInt64(addr), data: data)
    }

    public func writeMem16(_ addr: UInt32, data: UInt16) throws {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .store)
        try bus.write16(addr: UInt64(addr), data: data)
    }

    public func writeMem32(_ addr: UInt32, data: UInt32) throws {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .store)
        try bus.write32(addr: UInt64(addr), data: data)
    }

    public func readRawMem8(_ addr: UInt64) throws -> UInt8 {
        return try bus.read8(addr: addr)
    }

    public func readRawMem16(_ addr: UInt64) throws -> UInt16 {
        return try bus.read16(addr: addr)
    }

    public func readRawMem32(_ addr: UInt64) throws -> UInt32 {
        return try bus.read32(addr: addr)
    }

    public func writeRawMem8(_ addr: UInt64, data: UInt8) throws {
        try bus.write8(addr: addr, data: data)
    }

    public func writeRawMem16(_ addr: UInt64, data: UInt16) throws {
        try bus.write16(addr: addr, data: data)
    }

    public func writeRawMem32(_ addr: UInt64, data: UInt32) throws {
        try bus.write32(addr: addr, data: data)
    }

    func fetch(addr: UInt32) throws -> UInt32 {
        let addr = try mmu.translate(cpu: self, vaddr: addr, accessType: .instruction)
        return try bus.read32(addr: UInt64(addr))
    }

    var halt: Bool = false

    public func run() {
        halt = false

        while (!halt) {
            do {
                // Fetch
                // print("PC: 0x\(String(pc, radix: 16))")
                let inst: UInt32 = try fetch(addr: pc)

                // print("a1: 0x\(String(xregs.read(.a1), radix: 16))")

                // Decode
                let opcode: Int = Int(inst & 0b111_1111)
                let funct3: Int = Int((inst >> 12) & 0b111)
                let funct7: Int = Int(inst >> 25)

                // print("Opcode: 0b\(String(opcode, radix: 2)) Funct3: 0b\(String(funct3, radix: 2))  Funct7: 0b\(String(funct7, radix: 2))")

                // Execute
                if let instruction = instructionTable.getInstruction(
                    opcode: UInt8(opcode), funct3: UInt8(funct3), funct7: UInt8(funct7)
                ) {
                    try instruction.execute(cpu: self, inst: inst)
                } else {
                    print("Unknown instruction")
                    print("opcode: 0b\(String(opcode, radix: 2))")
                    print("funct3: 0b\(String(funct3, radix: 2))")
                    print("funct7: 0b\(String(funct7, radix: 2))")

                    if opcode == 0 {
                        halt = true
                    } else {
                        throw Trap.exception(.illegalInstruction, tval: pc)
                    }
                    // break
                    // throw Trap.exception(.illegalInstruction, tval: pc)

                }
            } catch Trap.interrupt(let interrupt, tval: let tval) {
                do {
                    try handleTrap(interrupt: true, trap: interrupt.rawValue, tval: tval)
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
    }

    func incrementCycle() {
        cycle += 1
        bus.tick(mip: getRawCsr(CsrBank.RegAddr.mip) as! Mip)
    }
}

// For testing, debugging, development, or other purposes
extension Cpu {
    public func readMem(_ addr: UInt32, size: Int)  throws -> [UInt8] {
        var data: [UInt8] = []
        for i in 0..<size {
            data.append(try readMem8(addr + UInt32(i)))
        }
        return data
    }

    public func writeMem(_ addr: UInt32, data: [UInt8]) throws {
        for i in 0..<data.count {
            try writeMem8(addr + UInt32(i), data: data[i])
        }
    }

    public func readRawMem(_ addr: UInt64, size: Int) -> [UInt8] {
        var data: [UInt8] = []
        for i in 0..<size {
            data.append(try! readRawMem8(addr + UInt64(i)))
        }
        return data
    }

    public func writeRawMem(_ addr: UInt64, data: [UInt8]) {
        for i in 0..<data.count {
            try! writeRawMem8(addr + UInt64(i), data: data[i])
        }
    }
}
