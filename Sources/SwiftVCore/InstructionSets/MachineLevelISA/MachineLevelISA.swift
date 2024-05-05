struct MachineLevelISA: InstructionSet {
    var instructions: [Instruction] = []
    var csrs: [Csr] = [
        // Trap Setup
        // mstatus
        Mstatus(),
        // misa
        // medeleg
        // mideleg
        // mie
        Mie(),
        // mtvec
        Mtvec(),
        // mcounteren
        // mstatush
        Mstatush(),

        //  Trap Handling
        // mscratch
        Csr(name: "mscratch", addr: 0x340), // TODO: Check if this is correct
        // mepc
        Csr(name: "mepc", addr: 0x341), // TODO: Check if this is correct WARL
        // mcause
        Mcause(),
        // mtval
        Csr(name: "mtval", addr: 0x343), // TODO: Check if this is correct WARL
        // mip
        Mip(),
        // mtinst
        Csr(name: "mtinst", addr: 0x34a), // TODO: Check if this is correct WARL
        // mtval2
        Csr(name: "mtval2", addr: 0x34b), // TODO: Check if this is correct WARL
    ]
}
