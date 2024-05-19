extension Mmu {
    struct Tlb {
        static let size = 256

        // LRU Cache
        var dictionary: [Mmu.Tlb.Entry.Key : Mmu.Tlb.Entry]
        var entries: [Entry]
        var head: Entry

        init() {

            dictionary = [:]
            entries = (0..<Mmu.Tlb.size).map { _ in Entry() }

            // make a circular linked list
            for i in 0..<Mmu.Tlb.size where i > 0 {
                entries[i - 1].nextEntry = entries[i]
                entries[i].prevEntry = entries[i - 1]
            }
            entries[Mmu.Tlb.size - 1].nextEntry = entries[0]
            entries[0].prevEntry = entries[Mmu.Tlb.size - 1]
            head = entries[0]
        }

        mutating func get(vpn: UInt32, asid: UInt32, accessType: AccessType) -> Entry? {
            let key = Entry.Key(asid: asid, vpn: vpn, accessType: accessType)

            // if found, move the entry to the head
            if let ret = dictionary[key] {
                if ret === head {
                    return ret
                }
                let prevHead = head
                let pevTail = head.prevEntry!
                let prev = ret.prevEntry!
                let next = ret.nextEntry!

                prev.nextEntry = next
                next.prevEntry = prev
                head = ret
                head.prevEntry = pevTail
                pevTail.nextEntry = head
                prevHead.prevEntry = ret
                ret.nextEntry = prevHead

                return ret
            }

            return nil
        }

        mutating func put(asid: UInt32, vpn: UInt32, ppn: UInt32, accessType: AccessType) {
            let key = Entry.Key(asid: asid, vpn: vpn, accessType: accessType)
            let prevTail = head.prevEntry!
            if prevTail.valid {
                dictionary.removeValue(forKey: Entry.Key(
                    asid: prevTail.asid, vpn: prevTail.vpn, accessType: prevTail.accessType
                ))
                // print("TLB: evict 0x\(String(prevTail.vpn, radix: 16))")
            }
            let entry = prevTail
            entry.valid = true
            entry.asid = asid
            entry.vpn = vpn
            entry.accessType = accessType
            entry.ppn = ppn

            dictionary[key] = entry
            head = entry
        }
    }
}

extension Mmu.Tlb {
    class Entry {

        var valid: Bool = false
        var asid: UInt32 = 0
        var vpn: UInt32 = 0
        var accessType: Mmu.AccessType = .load

        var nextEntry: Entry?
        var prevEntry: Entry?

        var ppn: UInt32 = 0

        func match(vpn: UInt32, asid: UInt32, accessType: Mmu.AccessType) -> Bool {
            return self.valid && self.vpn == vpn && self.asid == asid && self.accessType == accessType
        }
    }
}

extension Mmu.Tlb.Entry {
    struct Key: Hashable {
        var asid: UInt32
        var vpn: UInt32
        var accessType: Mmu.AccessType
    }
}
