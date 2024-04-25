import XCTest
@testable import SwiftVCore

final class SwiftVCoreTests: XCTestCase {
    func testExample() throws {
        var memory = Memory()

        let code: [UInt8] = [
            // 00000293
            // 00000313
            // 00a00393
            // 00128293
            // 00530333
            // 00729463
            // ff1ff06f
            // fd5ff06f
            // 00030533
            // 00008067

            0x93, 0x02, 0x00, 0x00,
            0x13, 0x03, 0x00, 0x00,
            0x93, 0x03, 0xa0, 0x00,
            0x93, 0x82, 0x12, 0x00,
            0x33, 0x03, 0x53, 0x00,
            0x63, 0x94, 0x72, 0x00,
            0x6f, 0xf0, 0x1f, 0xff,
            0x6f, 0xf0, 0x5f, 0xfd,
            0x33, 0x03, 0x03, 0x00,
            0x67, 0x80, 0x00, 0x00,
        ]
        memory.write(0x0000, code)
        var cpu = Cpu(memory: memory)
        cpu.run()
    }
}
