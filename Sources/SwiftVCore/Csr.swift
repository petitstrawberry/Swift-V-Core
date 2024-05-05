public struct CsrBank {
    static let kCSRCount = 0x1000

    var csrs: [Csr?] = Array(repeating: nil, count: kCSRCount)

    public mutating func load(instructionSets: [InstructionSet]) {
        for instructionSet in instructionSets {
            for csr in instructionSet.csrs {
                self.csrs[Int(csr.addr)] = csr
                print("Loaded CSR: \(csr.name)")
            }
        }
    }
}

public protocol CsrProtocol {
    var name: String { get }
    var addr: UInt32 { get }
    var value: UInt32 { get set }
    var privilige: Csr.Privilige { get }
    var mode: Cpu.PriviligedMode { get }

    init(name: String, addr: UInt32, value: UInt32)
    func read(cpu: Cpu) throws -> UInt32
    func write(cpu: Cpu, value: UInt32) throws
}

public class Csr: CsrProtocol {
    public enum Privilige: UInt8 {
        case none = 0b00
        case read = 0b01
        case write = 0b10
        case readWrite = 0b11
    }

    public let name: String
    public let addr: UInt32
    public let privilige: Privilige
    public let mode: Cpu.PriviligedMode
    public var value: UInt32

    public func read(cpu: Cpu) throws -> UInt32 {
        if privilige.rawValue & Privilige.read.rawValue > 0 {
            return value
        } else {
            throw Trap.exception(.illegalInstruction)
        }
    }

    public func write(cpu: Cpu, value: UInt32) throws {
        if privilige.rawValue & Privilige.write.rawValue > 0 {
            self.value = value
        } else {
            throw Trap.exception(.illegalInstruction)
        }
    }

    public required init(name: String, addr: UInt32, value: UInt32 = 0) {
        self.name = name
        self.addr = addr
        self.value = value

        switch addr {
        // USER CSRs
        // Standard read-write
        case 0x000 ... 0x0ff:
            self.privilige = .readWrite
            self.mode = .user
        // Standard read-write
        case 0x400 ... 0x4ff:
            self.privilige = .readWrite
            self.mode = .user
        // Custom read-write
        case 0x800...0x8ff:
            self.privilige = .readWrite
            self.mode = .user
        // Standard read-only
        case 0xc00...0xc7f:
            self.privilige = .read
            self.mode = .user
        // Standard read-only
        case 0xc80...0xcbf:
            self.privilige = .read
            self.mode = .user
        // Custom read-only
        case 0xcc0...0xcff:
            self.privilige = .read
            self.mode = .user

        // SUPERVISOR CSRs
        // Standard read-write
        case 0x100...0x1ff:
            self.privilige = .readWrite
            self.mode = .supervisor
        // Standard read-write
        case 0x500...0x57f:
            self.privilige = .readWrite
            self.mode = .supervisor
        // Standard read-write
        case 0x580...0x5bf:
            self.privilige = .readWrite
            self.mode = .supervisor
        // Custom read-write
        case 0x5c0...0x5ff:
            self.privilige = .readWrite
            self.mode = .supervisor
        // Standard read-write
        case 0x900...0x97f:
            self.privilige = .readWrite
            self.mode = .supervisor
        // Standard read-write
        case 0x980...0x9bf:
            self.privilige = .readWrite
            self.mode = .supervisor
        // Custom read-write
        case 0x9c0...0x9ff:
            self.privilige = .readWrite
            self.mode = .supervisor
        // Standard read-only
        case 0xd00...0xd7f:
            self.privilige = .read
            self.mode = .supervisor
        // Standard read-only
        case 0xd80...0xdbf:
            self.privilige = .read
            self.mode = .supervisor
        // Custom read-only
        case 0xdc0...0xdff:
            self.privilige = .read
            self.mode = .supervisor

        // HYPERVISOR CSRs
        // Reserved
        // TODO: implement hypervisor CSRs

        // MACHINE CSRs
        // Standard read-write
        case 0x300...0x3ff:
            self.privilige = .readWrite
            self.mode = .machine
        // Standard read-write
        case 0x700...0x77f:
            self.privilige = .readWrite
            self.mode = .machine
        // Standard read-write
        case 0x780...0x79f:
            self.privilige = .readWrite
            self.mode = .machine
        // Standard read-write debug
        case 0x7a0...0x7af:
            self.privilige = .readWrite
            self.mode = .machine
        // Debug-mode-only
        case 0x7b0...0x7bf:
            self.privilige = .readWrite
            self.mode = .machine // TODO: debug mode
        // Custom read-write
        case 0x7c0...0x7ff:
            self.privilige = .readWrite
            self.mode = .machine
        // Standard read-write
        case 0xb00...0xb7f:
            self.privilige = .readWrite
            self.mode = .machine
        // Standard read-write
        case 0xb80...0xbbf:
            self.privilige = .readWrite
            self.mode = .machine
        // Custom read-write
        case 0xbc0...0xbff:
            self.privilige = .readWrite
            self.mode = .machine
        // Standard read-only
        case 0xf00...0xf7f:
            self.privilige = .read
            self.mode = .machine
        // Standard read-only
        case 0xf80...0xfbf:
            self.privilige = .read
            self.mode = .machine
        // Custom read-only
        case 0xfc0...0xfff:
            self.privilige = .read
            self.mode = .machine
        default:
            self.privilige = .none
            self.mode = .user
        }
    }
}
