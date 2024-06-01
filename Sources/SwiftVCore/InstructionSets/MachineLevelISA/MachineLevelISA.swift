struct MachineLevelISA: InstructionSet {
    var instructions: [Instruction] = [
        // MRET
        Instruction(name: "MRET", type: .R, mode: .machine,
                        opcode: 0b1110011, funct3: 0b000, funct7: 0b0011000) { cpu, _ in
            let mstatus = cpu.getRawCsr(CsrBank.RegAddr.mstatus) as Mstatus
            let mepc = try cpu.readRawCsr(CsrBank.RegAddr.mepc)

            // Restore mie from mstatus.mpie value
            mstatus.write(cpu: cpu, field: .mie, value: mstatus.read(cpu: cpu, field: .mpie))

            // Change mode to mstatus.mpp
            cpu.mode = Cpu.PriviligedMode(rawValue: mstatus.read(cpu: cpu, field: .mpp))!

            // Set mpie to 1
            mstatus.write(cpu: cpu, field: .mpie, value: 1)

            // Set mpp to U-mode
            mstatus.write(cpu: cpu, field: .mpp, value: 0)

            //　Set pc to mepc
            cpu.pc = mepc
        },
        // WFI
        Instruction(name: "WFI", type: .I, mode: .machine,
                        opcode: 0b1110011, funct3: 0b000, funct7: 0b0001000) { cpu, _ in
            // Wait for interrupt
            // set wfi flag
            cpu.wfi = true
            cpu.pc &+= 4
        },
    ]
    var csrs: [Csr] = [
        //  Information Registers
        Mhartid(),
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
