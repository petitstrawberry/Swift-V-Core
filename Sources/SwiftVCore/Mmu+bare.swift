extension Mmu {

    struct Bare: VaddrTranslator {
        let cpu: Cpu
        static let vaddrSize = 32 // 32-bit virtual address as physical address
        static let pageSize = 4096 // 4KiB page size
        static let pteSize = 0 // no page table

        func translate(vaddr: UInt32) throws -> UInt32 {
            return vaddr
        }
    }
}
