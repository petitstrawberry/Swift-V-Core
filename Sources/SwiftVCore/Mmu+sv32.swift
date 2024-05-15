extension Mmu {

    struct Sv32: VaddrTranslator {
        static let vaddrSize = 32 // 32-bit virtual address
        static let pageSize = 4096 // 4KiB page size
        static let pteSize = 4 // 4 bytes per PTE

        // throw page fault by access type
        func throwPageFault(accessType: AccessType, vaddr: UInt32) throws {
            switch accessType {
            case .instruction:
                throw Trap.exception(.instructionPageFault, tval: vaddr)
            case .load:
                throw Trap.exception(.loadPageFault, tval: vaddr)
            case .store:
                throw Trap.exception(.storeAMOPageFault, tval: vaddr)
            }
        }

        func translate(cpu: Cpu, vaddr: UInt32, accessType: AccessType) throws -> UInt32 {
            return try walk(cpu: cpu, vaddr: vaddr, accessType: accessType)
        }

        func walk(cpu: Cpu, vaddr: UInt32, accessType: AccessType) throws -> UInt32 {
            let satp = cpu.getRawCsr(CsrBank.RegAddr.satp) as Satp

            let vpn: [UInt32] = [
                (vaddr >> 12) & 0x3ff,
                (vaddr >> 22) & 0x3ff
            ]

            let offset = vaddr & 0xfff

            var checkedLevel: Int = 1

            var pagetableAddr = satp.read(cpu: cpu, field: .ppn) * UInt32(Mmu.Sv32.pageSize)

            var pte: Pte = Pte(pte: 0)
            var pteAddr: UInt32 = 0

            for i in (0...1).reversed() {
                checkedLevel = i
                pteAddr = pagetableAddr + vpn[i] * UInt32(Mmu.Sv32.pteSize)
                // print("paddr = 0x\(String(paddr, radix: 16))")
                pte = Pte(pte: cpu.readRawMem32(pteAddr))

                if !pte.valid || (!pte.read && pte.write) {
                    try throwPageFault(accessType: accessType, vaddr: vaddr)
                }

                if pte.read || pte.execute {
                    break
                }

                pagetableAddr = (pte.ppn[1] << 10 + pte.ppn[0]) * UInt32(Mmu.Sv32.pageSize)
            }

            if checkedLevel > 0 {
                for i in 0..<checkedLevel where pte.ppn[i] != 0 {
                    try throwPageFault(accessType: accessType, vaddr: vaddr)
                }
            }

            if !pte.accessed || (accessType == .store && !pte.dirty) {
                pte.accessed = true
                if accessType == .store {
                    pte.dirty = true
                }
                cpu.writeRawMem32(pteAddr, data: pte.getRawValue())
            }

            var ppn: [UInt32] = [0, 0]

            for i in 0..<checkedLevel {
                ppn[i] = vpn[i]
            }
            for i in checkedLevel..<2 {
                ppn[i] = pte.ppn[i]
            }

            return ppn[1] << 22 + ppn[0] << 12 + offset
        }
    }
}

extension Mmu.Sv32 {
    struct Pte {
        var valid: Bool
        var read: Bool
        var write: Bool
        var execute: Bool
        var user: Bool
        var global: Bool
        var accessed: Bool
        var dirty: Bool
        var ppn: [UInt32] = [
            0,
            0
        ]

        init(pte: UInt32) {
            valid = pte & 0x1 != 0
            read = pte & 0x2 != 0
            write = pte & 0x4 != 0
            execute = pte & 0x8 != 0
            user = pte & 0x10 != 0
            global = pte & 0x20 != 0
            accessed = pte & 0x40 != 0
            dirty = pte & 0x80 != 0
            ppn[0] = (pte >> 10) & 0x3ff
            ppn[1] = (pte >> 20) & 0x3ff
        }

        // for testing
        init(
            valid: Bool,
            read: Bool,
            write: Bool,
            execute: Bool,
            user: Bool,
            global: Bool,
            accessed: Bool,
            dirty: Bool,
            asid: UInt32,
            ppn: [UInt32]
        ) {
            self.valid = valid
            self.read = read
            self.write = write
            self.execute = execute
            self.user = user
            self.global = global
            self.accessed = accessed
            self.dirty = dirty
            self.ppn[0] = ppn[0] & 0x3ff
            self.ppn[1] = ppn[1] & 0x3ff
        }

        func getRawValue() -> UInt32 {
            var pte: UInt32 = 0

            pte |= valid ? 0x1 : 0
            pte |= read ? 0x2 : 0
            pte |= write ? 0x4 : 0
            pte |= execute ? 0x8 : 0
            pte |= user ? 0x10 : 0
            pte |= global ? 0x20 : 0
            pte |= accessed ? 0x40 : 0
            pte |= dirty ? 0x80 : 0
            pte |= ppn[0] << 10
            pte |= ppn[1] << 20

            return pte
        }
    }
}
