public struct CsrBank {
    static let kCSRCount = 0x1000

    var csrs: [Csr]

    public init() {
        // Initialize all CSRs  with 0
        self.csrs = []
        for addr in 0..<CsrBank.kCSRCount {
            self.csrs.append(
                Csr(name: "CSR_0x\(String(addr, radix: 16))", addr: UInt32(addr), value: 0)
            )
        }
    }

    public mutating func load(instructionSets: [InstructionSet]) {
        for instructionSet in instructionSets {
            for csr in instructionSet.csrs {
                self.csrs[Int(csr.addr)] = csr
                // print("Loaded CSR at 0x\(String(csr.addr, radix: 16)): \(csr.name)")
            }
        }
    }

    public struct RegAddr {
        static let none: UInt32 = 0x000
    }
}
