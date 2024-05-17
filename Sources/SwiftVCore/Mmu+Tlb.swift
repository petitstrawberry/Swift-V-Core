extension Mmu {
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