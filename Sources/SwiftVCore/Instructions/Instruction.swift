public enum Instruction: UInt8 {
    case lui = 0b0110111
    case auipc = 0b0010111
    case jal = 0b1101111
    case jalr = 0b1100111
    case br = 0b1100011 // beq, bne, blt, bge, bltu, bgeu
    case ld = 0b0000011 // lb, lh, lw, lbu, lhu
    case st = 0b0100011 // sb, sh, sw
    case imm = 0b0010011 // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
    case alu = 0b0110011 // add, sub, sll, slt, sltu, xor, srl, sra, or, and
    case fence = 0b0001111
    case ecalls = 0b1110011 // ecall, ebreak
}