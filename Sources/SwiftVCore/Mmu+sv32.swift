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

        func translate(cpu: Cpu, vaddr: UInt32, accessType: AccessType) throws -> UInt64 {
            return try walk(cpu: cpu, vaddr: vaddr, accessType: accessType)
        }

        func walk(cpu: Cpu, vaddr: UInt32, accessType: AccessType) throws -> UInt64 {
            let satp = cpu.getRawCsr(CsrBank.RegAddr.satp) as Satp

            let vpn: [UInt32] = [
                (vaddr >> 12) & 0x3ff,
                (vaddr >> 22) & 0x3ff
            ]

            let offset = vaddr & 0xfff

            var checkedLevel: Int = 1

            var pagetableAddr = UInt64(satp.read(cpu: cpu, field: .ppn)) * UInt64(Mmu.Sv32.pageSize)

            var pte: Pte = Sv32.Pte(rawValue: 0)
            var pteAddr: UInt64 = 0

            for i in (0...1).reversed() {
                checkedLevel = i
                pteAddr = pagetableAddr + UInt64(vpn[i]) * UInt64(Mmu.Sv32.pteSize)
                // print("paddr = 0x\(String(paddr, radix: 16))")
                pte = Sv32.Pte(rawValue: try cpu.readRawMem32(pteAddr))

                if !pte.valid || (!pte.read && pte.write) {
                    try throwPageFault(accessType: accessType, vaddr: vaddr)
                }

                if pte.read || pte.execute {
                    break
                }

                pagetableAddr = (UInt64(pte.ppnSlice[1]) << 10 + UInt64(pte.ppnSlice[0])) * UInt64(Mmu.Sv32.pageSize)
            }

            if checkedLevel > 0 {
                for i in 0..<checkedLevel where pte.ppnSlice[i] != 0 {
                    try throwPageFault(accessType: accessType, vaddr: vaddr)
                }
            }

            if !pte.accessed || (accessType == .store && !pte.dirty) {
                pte.accessed = true
                if accessType == .store {
                    pte.dirty = true
                }
                try cpu.writeRawMem32(pteAddr, data: pte.rawValue)
            }

            var ppn: [UInt32] = [0, 0]

            for i in 0..<checkedLevel {
                ppn[i] = vpn[i]
            }
            for i in checkedLevel..<2 {
                ppn[i] = pte.ppnSlice[i]
            }

            return UInt64(ppn[1]) << 22 + UInt64(ppn[0]) << 12 + UInt64(offset)
        }
    }
}

extension Mmu.Sv32 {
    struct Pte: Mmu.Pte {
        var rawValue: UInt32

        var ppn: UInt32 {
            get {
                return (rawValue >> 10) & 0xfffff
            }

            set {
                rawValue = (rawValue & (~(0xfffff << 10))) | ((newValue & 0xfffff) << 10)
            }
        }

        var ppnSlice: [UInt32] {
            get {
                return [
                    (rawValue >> 10) & 0x3ff,
                    (rawValue >> 20) & 0xfff
                ]
            }

            set {
                rawValue = (rawValue & (~(0x3ff << 10))) | ((newValue[0] & 0x3ff) << 10)
                rawValue = (rawValue & (~(0xfff << 20))) | ((newValue[1] & 0xfff) << 20)
            }
        }

        init(rawValue: UInt32) {
            self.rawValue = rawValue
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
            ppn: [UInt32]
        ) {
            rawValue = 0
            rawValue |= valid ? 0x1 : 0
            rawValue |= read ? 0x2 : 0
            rawValue |= write ? 0x4 : 0
            rawValue |= execute ? 0x8 : 0
            rawValue |= user ? 0x10 : 0
            rawValue |= global ? 0x20 : 0
            rawValue |= accessed ? 0x40 : 0
            rawValue |= dirty ? 0x80 : 0
            rawValue |= (ppn[0] & 0x3ff) << 10
            rawValue |= (ppn[1] & 0xfff) << 20
        }

    }
}

// For testing
extension Mmu.Sv32 {
    // Page mapper
    static func vmap(cpu: Cpu, vaddr: UInt32, paddr: UInt64) {
        let paddr = paddr & 0xffff_ffff
        let satp = cpu.getRawCsr(CsrBank.RegAddr.satp) as Satp

        let vpn: [UInt32] = [
            (vaddr >> 12) & 0x3ff,
            (vaddr >> 22) & 0x3ff
        ]

        var pagetableAddr = UInt64(satp.read(cpu: cpu, field: .ppn)) * UInt64(Mmu.Sv32.pageSize)
        var pteAddr: UInt64 = 0

        for i in (0...1).reversed() {
            pteAddr = pagetableAddr + UInt64(vpn[i]) * UInt64(Mmu.Sv32.pteSize)

            var pte = Pte(rawValue: try! cpu.readRawMem32(pteAddr))

            if !pte.valid {
                pte = Mmu.Sv32.Pte(
                    valid: true,
                    read: false,
                    write: false,
                    execute: false,
                    user: true,
                    global: false,
                    accessed: false,
                    dirty: false,
                    ppn: [0, 0]
                )

                if i == 0 {
                    pte.ppn = UInt32((paddr >> 12) & 0x3fffff)
                    pte.write = true
                    pte.read = true
                    pte.execute = true
                } else {
                    pte.ppn = vpn[1] + 0x80001
                }

                try! cpu.writeRawMem32(pteAddr, data: pte.rawValue)
            }

            pagetableAddr = UInt64(pte.ppn) * UInt64(Mmu.Sv32.pageSize)
            // if i == 0 {
            // }
        }
    }
}