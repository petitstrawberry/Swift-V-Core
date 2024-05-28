import ElfParser
import Foundation

public class ElfLoader {
    static func load(path: String, bus: Bus) {
        let ram = bus.dram

        guard let parser = ElfParser(filePath: path),
            let elfHeader = parser.parseElfHeader(),
            let programHeaders = parser.parseProgramHeaders(elfHeader: elfHeader) else {

            print("Failed to parse ELF file")
            fatalError()
        }

        let binaryData = parser.extractBinaryData(
            with: programHeaders.filter {
                $0.p_type == 1 // PT_LOADに限定
            }
        )

        for (address, data) in binaryData {
            let ramAddress = Int(address)

            guard ramAddress + data.count - 1 <= ram.endAddr else {
                print("Data exceeds RAM bounds")
                fatalError()
            }
            let ramAddressIndex = ramAddress - Int(ram.startAddr)
            ram.mem.replaceSubrange(ramAddressIndex..<(ramAddressIndex + data.count), with: data)
        }
    }
}
