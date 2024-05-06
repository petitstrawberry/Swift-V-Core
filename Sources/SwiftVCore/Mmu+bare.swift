extension Mmu {

    struct Bare: VaddrTranslator {

        static func translate(vaddr: UInt32) throws -> UInt32 {
            return vaddr
        }
    }
}
