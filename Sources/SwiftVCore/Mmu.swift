struct Mmu {

    enum AddressingMode: UInt8 {
        case bare = 0b0
        case sv32 = 0b1
    }

    func getAddressingMode(cpu: Cpu) -> AddressingMode {
        return try! cpu.readRawCsr(CsrBank.RegAddr.satp) & 0x8000_0000 == 0 ? .bare : .sv32
    }

    protocol VaddrTranslator {
        static var vaddrSize: Int { get }
        static var pageSize: Int { get }
        static var pteSize: Int { get }

        func translate(cpu: Cpu, vaddr: UInt32) throws -> UInt32
    }

    let bareVaddrTranslator: Bare
    let sv32VaddrTranslator: Sv32

    init() {
        self.bareVaddrTranslator = Bare()
        self.sv32VaddrTranslator = Sv32()
    }

    func translate(cpu: Cpu, vaddr: UInt32, write: Bool) throws -> UInt32 {
        let addressingMode = getAddressingMode(cpu: cpu)
        let translator: any VaddrTranslator = switch addressingMode {
        case .bare:
            bareVaddrTranslator
        case .sv32:
            sv32VaddrTranslator
        }

        let satp = cpu.getRawCsr(CsrBank.RegAddr.satp) as Satp

        if addressingMode != .bare {
            if let entry = tlb.get(vpn: vaddr >> 12, asid: satp.read(cpu: cpu, field: .asid)) {
                return entry.ppn << 12 + vaddr & 0xfff
            }
        }

        return try translator.translate(cpu: cpu, vaddr: vaddr)
    }

    var tlb = Tlb()
    struct Tlb {
        static let size = 256
        var entries: [Entry] = Array(repeating: Entry(), count: size)

        func get(vpn: UInt32, asid: UInt32) -> Entry? {
            return entries.first { $0.match(vpn: vpn, asid: asid) }
        }

        mutating func add(entry: Entry) {
            let index = entries.firstIndex { !$0.valid } ?? 0
            entries[index] = entry
        }

        mutating func invalidate(asid: UInt32) {
            entries.indices.forEach { i in
                if entries[i].asid == asid {
                    entries[i].valid = false
                }
            }
        }
    }
}

extension Mmu.Tlb {
    struct Entry {
        var valid: Bool = false
        var read: Bool = false
        var write: Bool = false
        var execute: Bool = false
        var user: Bool = false
        var global: Bool = false
        var accessed: Bool = false
        var dirty: Bool = false

        var asid: UInt32 = 0
        var ppn: UInt32 = 0
        var vpn: UInt32 = 0

        func match(vpn: UInt32, asid: UInt32) -> Bool {
            return self.vpn == vpn && self.asid == asid && valid
        }
    }
}
