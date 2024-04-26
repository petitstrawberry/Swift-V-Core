import XCTest
@testable import SwiftVCore

final class SwiftVCoreTests: XCTestCase {
    func testExample() throws {
        var memory = Memory()

        let code: [UInt8] = [
            // 3e800093
            // 7d008113
            // c1810193
            // 83018213
            // 3e820293

            0x93, 0x00, 0x80, 0x3e,
            0x13, 0x81, 0x00, 0x7d,
            0x93, 0x01, 0x81, 0xc1,
            0x13, 0x82, 0x01, 0x83,
            0x93, 0x02, 0x82, 0x3e
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