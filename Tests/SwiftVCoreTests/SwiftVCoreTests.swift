import XCTest
@testable import SwiftVCore

final class SwiftVCoreTests: XCTestCase {
    func testAluFunc() throws {

        // signExtend64

        // 7bit -> 64bit
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b1111111, bitWidth: 7), 0xffffffffffffffff) // -1
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b0000000, bitWidth: 7), 0x0000000000000000) // 0
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b0000001, bitWidth: 7), 0x0000000000000001) // 1
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b0111111, bitWidth: 7), 0x000000000000003f) // 63
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b1000000, bitWidth: 7), 0xffffffffffffffc0) // -64
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b1000001, bitWidth: 7), 0xffffffffffffffc1) // -63

        // 12bit -> 64bit
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b111111111111, bitWidth: 12), 0xffffffffffffffff) // -1
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b000000000000, bitWidth: 12), 0x0000000000000000) // 0
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b000000000001, bitWidth: 12), 0x0000000000000001) // 1
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b011111111111, bitWidth: 12), 0x00000000000007ff) // 2047
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b100000000000, bitWidth: 12), 0xfffffffffffff800) // -2048
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b100000000001, bitWidth: 12), 0xfffffffffffff801) // -2047

        // 20bit -> 64bit
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b11111111111111111111, bitWidth: 20), 0xffffffffffffffff) // -1
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b00000000000000000000, bitWidth: 20), 0x0000000000000000) // 0
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b00000000000000000001, bitWidth: 20), 0x0000000000000001) // 1
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b01111111111111111111, bitWidth: 20), 0x000000000007ffff) // 524287
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b10000000000000000000, bitWidth: 20), 0xfffffffffff80000) // -524288
        XCTAssertEqual(Cpu.Alu.signExtend64(val: 0b10000000000000000001, bitWidth: 20), 0xfffffffffff80001) // -524287
    }
    func testExample() throws {
        var memory = Memory()

        let code: [UInt8] = [
            // 3e800513
            // 83000593
            // 00b50633
            // 40b506b3

            0x13, 0x05, 0x80, 0x3e,
            0x93, 0x05, 0x00, 0x83,
            0x33, 0x06, 0xb5, 0x00,
            0xb3, 0x06, 0xb5, 0x40
        ]

        // print code instructions in binary format (LE)
        // example:
        // 00000293 -> 00000000 00000000 00000010 10010011

        for i in 0..<code.count/4 {
            for j in 0..<4 {
                print("\(code[i * 4 + 3 - j].binaryString)", terminator: " ")
            }
            print()
        }

        memory.write(0x0000, code)
        var cpu = Cpu(memory: memory)
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