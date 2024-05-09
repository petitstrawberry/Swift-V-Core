extension Mmu {

    struct Sv32: VaddrTranslator {
        static let vaddrSize = 32 // 32-bit virtual address
        static let pageSize = 4096 // 4KiB page size
        static let pteSize = 4 // 4 bytes per PTE

        func translate(cpu: Cpu, vaddr: UInt32) throws -> UInt32 {
            return try walk(cpu: cpu, vaddr: vaddr)
        }

        func walk(cpu: Cpu, vaddr: UInt32) throws -> UInt32 {
            let satp = cpu.getRawCsr(CsrBank.RegAddr.satp) as Satp
            var ppn: [UInt32] = [
                0,
                0
            ]
            let vpn: [UInt32] = [
                (vaddr >> 12) & 0x3ff,
                (vaddr >> 22) & 0x3ff
            ]

            let offset = vaddr & 0xfff

            var x = satp.read(cpu: cpu, field: .ppn) * UInt32(Mmu.Sv32.pageSize)

            for i in stride(from: 1, to: 0, by: -1) {
                let pte = Pte(pte: cpu.readRawMem32(x + vpn[i] * UInt32(Mmu.Sv32.pteSize)))

                if !pte.valid {
                    throw Trap.exception(.loadPageFault, tval: vaddr)
                }

                ppn[i] = pte.ppn[i]
                x = (pte.ppn[1] << 10 + pte.ppn[0]) * UInt32(Mmu.Sv32.pageSize)
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
            ppn[1] = (pte >> 20) & 0xfff
        }
    }
}
