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
    func testExample() throws {
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
            0xe3, 0x1c, 0x05, 0xfe,
        ]

        let data: [UInt8] = []

        // print code instructions in binary format (LE)
        // example:
        // 00000293 -> 00000000 00000000 00000010 10010011

        for i in 0..<code.count/4 {
            for j in 0..<4 {
                print("\(code[i * 4 + 3 - j].binaryString)", terminator: " ")
            }
            print()
        }

        memory.write(0x00000, code)
        memory.write(0x10000, data)

        var cpu = Cpu(memory: memory, instructionSets: [RV32I()])
        cpu.run()
    }
}

extension FixedWidthInteger {
    var binaryString: String {
        var result: [String] = []
        for i in 0..<(Self.bitWidth / 8) {
            // ビットの右側から見ていって、UInt8の8bit(1byte)からはみ出た部分はtruncatiteする。
            // 自身のビット長によって8bitづつ右側ビットシフトをして、右端8bitづつUInt8にしている
            let byte = UInt8(truncatingIfNeeded: self >> (i * 8))

            // 2進数文字列に変換
            let byteString = String(byte, radix: 2)

            // 8桁(8bit)になるように0 padding
            let padding = String(repeating: "0",
                                 count: 8 - byteString.count)
            // 先頭にパディングを足す
            result.append(padding + byteString)
        }

        // 右端の8ビットが配列の先頭に入っているが、joined()するときは左端の8bitが配列の先頭に来ていて欲しいのでreversed()している
        return result.reversed().joined()
    }
}