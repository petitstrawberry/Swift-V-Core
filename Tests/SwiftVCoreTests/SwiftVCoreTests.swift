import XCTest
@testable import SwiftVCore

final class SwiftVCoreTests: XCTestCase {
    func testAluFunc() throws {

        // signExtend32

        // 7bit -> 32bit
        XCTAssertEqual(signExtend32(val: 0b0000000, bitWidth: 7), 0x00000000) // 0
        XCTAssertEqual(signExtend32(val: 0b0000001, bitWidth: 7), 0x00000001) // 1
        XCTAssertEqual(signExtend32(val: 0b0111111, bitWidth: 7), 0x0000003f) // 63
        XCTAssertEqual(signExtend32(val: 0b1000000, bitWidth: 7), 0xffffffc0) // -64
        XCTAssertEqual(signExtend32(val: 0b1111111, bitWidth: 7), 0xffffffff) // -1

        // 12bit -> 32bit
        XCTAssertEqual(signExtend32(val: 0b000000000000, bitWidth: 12), 0x00000000) // 0
        XCTAssertEqual(signExtend32(val: 0b000000000001, bitWidth: 12), 0x00000001) // 1
        XCTAssertEqual(signExtend32(val: 0b011111111111, bitWidth: 12), 0x000007ff) // 2047
        XCTAssertEqual(signExtend32(val: 0b100000000000, bitWidth: 12), 0xfffff800) // -2048
        XCTAssertEqual(signExtend32(val: 0b111111111111, bitWidth: 12), 0xffffffff) // -1

    }
    func testExecuteCode() throws {
        var memory = Memory()

        let code: [UInt8] = [
            // addi a0,zero,10
            // addi a1,zero,0
            // add a1,a1,a0
            // addi a0,a0,-1
            // bne a0,zero,-8

            // 0x00a00513
            // 0x00000593
            // 0x00a585b3
            // 0xfff50513
            // 0xfe051ce3

            0x13, 0x05, 0xa0, 0x00,
            0x93, 0x05, 0x00, 0x00,
            0xb3, 0x85, 0xa5, 0x00,
            0x13, 0x05, 0xf5, 0xff,
            0xe3, 0x1c, 0x05, 0xfe
        ]

        let data: [UInt8] = []

        memory.write(0x00000, code)
        memory.write(0x10000, data)

        let cpu = Cpu(
            memory: memory,
            instructionSets: [
                RV32I(),
                ZiCsr(),
                MachineLevelISA(),
                SupervisorLevelISA()
            ]
        )

        cpu.run()
    }

    func testMmu() throws {

        let cpu = Cpu(
            memory: Memory(),
            instructionSets: [
                RV32I(),
                ZiCsr(),
                MachineLevelISA(),
                SupervisorLevelISA()
            ]
        )

        let vaddr = UInt32(0x00000000)
        let paddr = try cpu.mmu.translate(cpu: cpu, vaddr: vaddr, accessType: .load)

        XCTAssertEqual(paddr, vaddr)

        let satp: Satp = cpu.getRawCsr(CsrBank.RegAddr.satp)
        try satp.write(cpu: cpu, value: 0x80000000)

        // TLB match
        cpu.mmu.tlb.add(entry: .init(valid: true, read: true, write: true, execute: true,
            user: true, global: true, accessed: false, dirty: false, asid: 0, ppn: 0x80000, vpn: 0x10000))

        let vaddr2 = UInt32(0x1000_01ff)
        let paddr2 = try cpu.mmu.translate(cpu: cpu, vaddr: vaddr2, accessType: .load)
        XCTAssertEqual(paddr2, UInt32(0x8000_01ff))

        // TLB miss
        // Table walk
        let vaddr3 = UInt32(
            0x01 << 22 |
            0x00 << 12 |
            0x2ff
        )
        // set root page table address
        satp.write(cpu: cpu, field: .asid, value: 0x01)
        satp.write(cpu: cpu, field: .ppn, value: 0x1000)
        // create page table
        let pte0 = Mmu.Sv32.Pte(
            valid: true,
            read: false,
            write: false,
            execute: false,
            user: true,
            global: false,
            accessed: false,
            dirty: false,
            asid: 0x01,
            ppn: [0x300, 0x01]
        ).getRawValue()
        cpu.writeRawMem32(0x0100_0000 + 0x0004, data: pte0)

        let pte1 = Mmu.Sv32.Pte(
            valid: true,
            read: true,
            write: true,
            execute: false,
            user: true,
            global: false,
            accessed: false,
            dirty: false,
            asid: 0x01,
            ppn: [0x3ff, 0x00]
        ).getRawValue()
        cpu.writeRawMem32(0x00070_0000 + 0x0000, data: pte1)

        let paddr3 = try cpu.mmu.translate(cpu: cpu, vaddr: vaddr3, accessType: .load)
        print("0x\(String(vaddr3, radix: 16)) -> 0x\(String(paddr3, radix: 16))")
        XCTAssertEqual(paddr3, UInt32(0x003f_f2ff))

        // TLB miss
        // Table walk
        // Direct mapping & short table walk
        let vaddr4 = UInt32(
            0x00 << 22 |
            0x10 << 12 |
            0x2ff
        )
        let pte2 = Mmu.Sv32.Pte(
            valid: true,
            read: true,
            write: true,
            execute: false,
            user: true,
            global: false,
            accessed: false,
            dirty: false,
            asid: 0x01,
            ppn: [0x00, 0x00]
        ).getRawValue()
        cpu.writeRawMem32(0x0100_0000 + 0x0000, data: pte2)
        let paddr4 = try cpu.mmu.translate(cpu: cpu, vaddr: vaddr4, accessType: .load)
        print("0x\(String(vaddr4, radix: 16)) -> 0x\(String(paddr4, radix: 16))")
        XCTAssertEqual(paddr4, UInt32(0x0001_02ff))

    }
}
