import XCTest
@testable import Swift_V_Core

final class Swift_V_CoreTests: XCTestCase {
    func testExample() throws {
        let memory = Memory()
        let cpu = Cpu(memory: memory)
        cpu.run()
    }
}
