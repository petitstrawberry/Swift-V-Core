extension Cpu {
    func handleTrap(interrupt: Bool, trap: UInt32, tval: UInt32) throws {
        // Get cause
        let cause = trap | (interrupt ? 1 << 31 : 0)
        // Get current mode as previous mode
        let previousMode = mode
        // Get tval
        let tval = switch interrupt {
        case true: UInt32(0)
        default: Exception(rawValue: trap)?.getTval(pc: pc, tval: tval) ?? tval
        }
        // Get pc as epc
        let epc = switch interrupt {
        case true: pc
        default: Exception(rawValue: trap)?.getEpc(pc) ?? pc
        }

        // TODO: Check delegation
        // let mdeleg = switch interrupt {
        //  case true: try readCsr(CsrBank.RegAddr.mideleg)
        //  case false: try readCsr(CsrBank.RegAddr.medeleg)
        // }

        // TODO: Delegation to supervisor / user mode
        let newMode = previousMode

        // Get status register
        let status = switch previousMode {
        case .machine:
            getRawCsr(CsrBank.RegAddr.mstatus) as Mstatus
        // TODO: Other modes
        default:
            throw CpuError.notImplemented
        }

        // TODO: Interrupt
        // if interrupt {
        // }

        // Get tvec register
        let tvec = switch newMode {
        case .machine:
            getRawCsr(CsrBank.RegAddr.mtvec) as Mtvec
        // TODO: Other modes
        default:
            throw CpuError.notImplemented
        }

        // Set epc, cause, tval
        switch newMode {
        case .machine:
            try writeRawCsr(CsrBank.RegAddr.mepc, epc)
            try writeRawCsr(CsrBank.RegAddr.mcause, cause)
            try writeRawCsr(CsrBank.RegAddr.mtval, tval)
        // TODO: Other modes
        default:
            throw CpuError.notImplemented
        }

        // Get MIE
        let mie = status.read(cpu: self, field: .mie)
        // Set MPIE to MIE
        status.write(cpu: self, field: .mpie, value: mie)
        // Set MIE to 0
        status.write(cpu: self, field: .mie, value: 0)

        mode = newMode

        // Set pc to tvec
        // if tvec is vector mode, pc = tvec.base + cause * 4
        pc = if tvec.read(cpu: self, field: .mode) == 0 {
            tvec.read(cpu: self, field: .base)
        } else {
            tvec.read(cpu: self, field: .base) + cause * 4
        }
    }
}
