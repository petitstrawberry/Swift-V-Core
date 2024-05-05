public struct CsrBank {
    static let kCSRCount = 0x1000

    var csrs: [Csr?] = Array(repeating: nil, count: kCSRCount)

    public mutating func load(instructionSets: [InstructionSet]) {
        for instructionSet in instructionSets {
            for csr in instructionSet.csrs {
                self.csrs[Int(csr.addr)] = csr
                print("Loaded CSR: \(csr.name)")
            }
        }
    }

    public struct RegAddr {
        static let none: UInt32 = 0x000
    }
}
