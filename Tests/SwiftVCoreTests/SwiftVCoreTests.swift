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

        let cpu = Cpu(
            bus: Bus(),
            instructionSets: [
                RV32I(),
                ZiCsr(),
                MachineLevelISA(),
                SupervisorLevelISA()
            ]
        )

        cpu.writeRawMem(0x8000_0000, data: code)

        cpu.run()
    }

    func testMmu() throws {

        let cpu = Cpu(
            bus: Bus(),
            instructionSets: [
                RV32I(),
                ZiCsr(),
                MachineLevelISA(),
                SupervisorLevelISA()
            ]
        )

        let vaddr = UInt32(0x00000000)
        let paddr = try cpu.mmu.translate(cpu: cpu, vaddr: vaddr, accessType: .load)
        print("Bare: 0x\(String(vaddr, radix: 16)) -> 0x\(String(paddr, radix: 16))")
        XCTAssertEqual(paddr, UInt64(vaddr))

        let satp: Satp = cpu.getRawCsr(CsrBank.RegAddr.satp)
        try satp.write(cpu: cpu, value: 0x80000000) // set Sv32 mode

        // set root page table address
        satp.write(cpu: cpu, field: .asid, value: 0x01)
        satp.write(cpu: cpu, field: .ppn, value: 0x8_0000)

        // Straight mapping test

        // 0x0000 ~ 0x0fff -> 0x8000 ~ 0x8fff
        for i in 0..<256 {
            let vaddr = UInt32(i * 0x1000)
            let paddr = UInt64(vaddr + 0x8000)
            Mmu.Sv32.vmap(cpu: cpu, vaddr: vaddr, paddr: paddr)
            // print("map: 0x\(String(vaddr, radix: 16)) -> 0x\(String(paddr, radix: 16))")
        }

        // Cache on tlb
        print("Caching on TLB...")
        for i in 0..<256 {
            let vaddr = UInt32(i * 0x1000)
            let paddr = try cpu.mmu.translate(cpu: cpu, vaddr: vaddr, accessType: .load)
            XCTAssertEqual(paddr, UInt64(vaddr + 0x8000))
        }
        print("Cached on TLB")
        // Check tlb
        print("Checking TLB...")
        let start = Date()
        for i: UInt32 in 0..<256 {
            for j: UInt32 in 0..<1 {
                let vaddr = i * 0x1000 + j
                let paddr = try cpu.mmu.translate(cpu: cpu, vaddr: vaddr, accessType: .load)
                // print("translated: 0x\(String(vaddr, radix: 16)) -> 0x\(String(paddr, radix: 16))")
                XCTAssertEqual(paddr, UInt64(vaddr + 0x8000))
            }
        }
        let elapsed = Date().timeIntervalSince(start)
        print("TLB Enabled elapsed: \(elapsed)")

        // Check non tlb
        cpu.mmu.tlbEnabled = false
        let start2 = Date()
        for i: UInt32 in 0..<256 {
            for j: UInt32 in 0..<1 {
                let vaddr = i * 0x1000 + j
                let paddr = try cpu.mmu.translate(cpu: cpu, vaddr: vaddr, accessType: .load)
                // print("translated: 0x\(String(vaddr, radix: 16)) -> 0x\(String(paddr, radix: 16))")
                XCTAssertEqual(paddr, UInt64(vaddr + 0x8000))
            }
        }
        let elapsed2 = Date().timeIntervalSince(start2)
        print("TLB Disabled elapsed: \(elapsed2)")
    }

    func testRiscvTests_rv32ui_p() throws {
        let elfPaths = getFiles(
            regex: "^rv32ui-p-(?!.*(\\.dump$|fence_i$)).*",
            directory: "Tests/SwiftVCoreTests/Resources/riscv-tests/target/share/riscv-tests/isa"
        )

        for elfPath in elfPaths {
            execTest(elfPath: elfPath)
        }
    }

    func testRiscvTests_rv32um_p() throws {
        let elfPaths = getFiles(
            regex: "^rv32um-p-(?!.*(\\.dump$)).*",
            directory: "Tests/SwiftVCoreTests/Resources/riscv-tests/target/share/riscv-tests/isa"
        )

        for elfPath in elfPaths {
            execTest(elfPath: elfPath)
        }
    }

    func testRiscvTests_rv32ua_p() throws {
        let elfPaths = getFiles(
            regex: "^rv32ua-p-(?!.*(\\.dump$)).*",
            directory: "Tests/SwiftVCoreTests/Resources/riscv-tests/target/share/riscv-tests/isa"
        )

        for elfPath in elfPaths {
            execTest(elfPath: elfPath)
        }
    }
}

func execTest(elfPath: String) {
    print("Executing \(elfPath)")

    let cpu = Cpu(
        bus: Bus(),
        instructionSets: [
            RV32I(),
            RV32M(),
            RV32A(),
            ZiCsr(),
            MachineLevelISA(),
            SupervisorLevelISA()
        ]
    )

    ElfLoader.load(path: elfPath, bus: cpu.bus)

    cpu.run()
    let result = cpu.xregs.read(.a0)

    if result == 0 {
        print("Passed")
    } else {
        print("Failed: \(result)")
    }

    XCTAssertEqual(result, 0)
}

func getFiles(regex: String, directory: String) -> [String] {
    let fileManager = FileManager.default
    var matchedFiles = [String]()

    do {
        let files = try fileManager.contentsOfDirectory(atPath: directory)
        let regex = try NSRegularExpression(pattern: regex)

        for file in files {
            let range = NSRange(location: 0, length: file.utf16.count)
            if regex.firstMatch(in: file, options: [], range: range) != nil {
                let filePath = (directory as NSString).appendingPathComponent(file)
                matchedFiles.append(filePath)
            }
        }
    } catch {
        print("Error reading directory contents: \(error.localizedDescription)")
    }

    return matchedFiles
}

