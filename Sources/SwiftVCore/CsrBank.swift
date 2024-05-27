public struct CsrBank {
    static let kCSRCount = 0x1000

    var csrs: [Csr]

    public init() {
        // Initialize all CSRs to a dummy CSR
        let csr = Csr(name: "Dummy CSR", addr: UInt32(0), value: 0)
        self.csrs = Array(repeating: csr, count: CsrBank.kCSRCount)
    }

    public mutating func load(instructionSets: [InstructionSet]) {
        for instructionSet in instructionSets {
            for csr in instructionSet.csrs {
                self.csrs[Int(csr.addr)] = csr
                print("Loaded CSR at 0x\(String(csr.addr, radix: 16)): \(csr.name)")
            }
        }
    }

    public struct RegAddr {
        static let none: UInt32 = 0x000
    }
}
