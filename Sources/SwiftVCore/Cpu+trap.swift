extension Cpu {
    func handleTrap(interrupt: Bool, trap: UInt32, tval: UInt32) throws {
        // Get cause
        let cause = UInt32(1 << trap) | UInt32(interrupt ? 1 << 31 : 0)
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
        let deleg = if interrupt {
            readRawCsr(CsrBank.RegAddr.mideleg)
        } else {
            readRawCsr(CsrBank.RegAddr.medeleg)
        }

        // TODO: Delegation to supervisor / user mode
        let newMode: PriviligedMode = if mode.rawValue <= PriviligedMode.supervisor.rawValue && (deleg & cause) > 0 {
            .supervisor
        } else {
            .machine
        }

        // TODO: disable interrupts
        if interrupt {
            self.wfi = false
        }

        switch newMode {
        case .machine:
            // Get status register
            let status = getRawCsr(CsrBank.RegAddr.mstatus) as Mstatus

            // Get tvec register
            let tvec = getRawCsr(CsrBank.RegAddr.mtvec) as Mtvec

            // Set epc, cause, tval
            writeRawCsr(CsrBank.RegAddr.mepc, epc)
            writeRawCsr(CsrBank.RegAddr.mcause, cause)
            writeRawCsr(CsrBank.RegAddr.mtval, tval)

            // Get MIE
            let mie = status.read(cpu: self, field: .mie)
            // Set MPIE to MIE
            status.write(cpu: self, field: .mpie, value: mie)
            // Set MIE to 0
            status.write(cpu: self, field: .mie, value: 0)
            // Set MPP to previous mode
            status.write(cpu: self, field: .mpp, value: mode.rawValue)

            // Set pc to tvec
            // if tvec is vector mode, pc = tvec.base + cause * 4
            if tvec.read(cpu: self, field: .mode) == 0 {
                self.pc = tvec.value & 0xffff_fffc
            } else {
                self.pc = tvec.read(cpu: self, field: .base) <<  2 + cause * 4
            }
        case .supervisor:
            // Get status register
            let status = getRawCsr(CsrBank.RegAddr.sstatus) as Sstatus

            // Get tvec register
            let tvec = getRawCsr(CsrBank.RegAddr.stvec) as Stvec

            // Set epc, cause, tval
            writeRawCsr(CsrBank.RegAddr.sepc, epc)
            writeRawCsr(CsrBank.RegAddr.scause, cause)
            writeRawCsr(CsrBank.RegAddr.stval, tval)
            // Get SIE
            let sie = status.read(cpu: self, field: .sie)
            // Set SPIE to SIE
            status.write(cpu: self, field: .spie, value: sie)
            // Set SIE to 0
            status.write(cpu: self, field: .sie, value: 0)
            // Set SPP to previous mode
            status.write(cpu: self, field: .spp, value: mode.rawValue)
            // Set pc to tvec
            // if tvec is vector mode, pc = tvec.base + cause * 4
            if tvec.read(cpu: self, field: .mode) == 0 {
                self.pc = tvec.value & 0xffff_fffc
            } else {
                self.pc = tvec.read(cpu: self, field: .base) <<  2 + cause * 4
            }
        default:
            fatalError("Not implemented yet")
        }

        // Chnage mode to new mode
        mode = newMode
    }

    // check pending interrupts
    func checkInterrupt() throws {
        let mip = getRawCsr(CsrBank.RegAddr.mip) as Mip
        let mie = getRawCsr(CsrBank.RegAddr.mie) as Mie

        let pending = try Int(mip.read(cpu: self) & mie.read(cpu: self))

        if pending > 0 {
            // Get the highest priority interrupt
            if let interrupt = Interrupt(rawValue: UInt32(pending.bitWidth) - 1) {
                let mip = getRawCsr(CsrBank.RegAddr.mip) as Mip
                mip.value &= ~(1 << interrupt.rawValue)
                throw Trap.interrupt(interrupt, tval: 0)
            }
        }
    }
}
