extension Mmu {

    struct Sv32: VaddrTranslator {

        static func translate(vaddr: UInt32) throws -> UInt32 {
            return try tablewalk(vaddr: vaddr)
        }

        static func tablewalk(vaddr: UInt32) throws -> UInt32 {
            return vaddr
        }
    }
}
