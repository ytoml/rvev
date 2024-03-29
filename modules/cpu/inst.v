module cpu

const (
	b3mask      = u8(0b111)
	b4mask      = u8(0b1111)
	b5mask      = u8(0b11111)
	b6mask      = u8(0b111111)
	b7mask      = u8(0b1111111)
	b8mask      = u32(0b11111111)
	b10mask     = u32(0x3ff)
	b11mask     = u32(0x7ff)
	upper7mask  = u32(0xfe00_0000)
	upper20mask = u32(0xffff_f000)
)

interface Instruction {
	opcode() u8
	rd() u8
	rs1() u8
	rs2() u8
	funct3() u8
	funct7() u8
}

struct InstructionBase {
	i u32
}

fn (i InstructionBase) opcode() u8 {
	return u8(i.i & cpu.b7mask)
}

fn (i InstructionBase) rd() u8 {
	return u8((i.i >> 7) & cpu.b5mask)
}

fn (i InstructionBase) rs1() u8 {
	return u8((i.i >> 15) & cpu.b5mask)
}

fn (i InstructionBase) rs2() u8 {
	return u8((i.i >> 20) & cpu.b5mask)
}

fn (i InstructionBase) funct3() u8 {
	return u8((i.i >> 12) & cpu.b3mask)
}

fn (i InstructionBase) funct7() u8 {
	return u8(i.i >> 25)
}

struct IType {
	InstructionBase
}

fn (i IType) imm() u16 {
	return u16(i.i >> 20)
}

fn (i IType) imm_sext() u64 {
	return u64(i64(int(i.i)) >> 20)
}

struct LogicalShift {
	IType
}

fn (l LogicalShift) shamt() u8 {
	// Note that shamt for RV64I is 6 bits while 5 bits for RV32I
	return u8(l.i >> 20 & cpu.b6mask)
}

struct Csr {
	IType
}

fn (c Csr) csr() u16 {
	return c.imm()
}

struct Fence {
	IType
}

fn (f Fence) pred() u8 {
	return u8((f.i >> 20) & cpu.b4mask)
}

fn (f Fence) succ() u8 {
	return u8((f.i >> 24) & cpu.b4mask)
}

fn (f Fence) verify() ! {
	if f.rd() != 0 || f.rs1() != 0 || (f.i >> 28) != 0 {
		return bad_inst('fence', f)
	}
}

struct DType {
	IType
}

struct RType {
	InstructionBase
}

struct UType {
	InstructionBase
}

fn (u UType) imm() u32 {
	return u.i & cpu.upper20mask
}

struct SType {
	InstructionBase
}

fn (s SType) imm_sext() u64 {
	return u64(i64(int(s.i & cpu.upper7mask) >> 20) | ((s.i >> 7) & cpu.b5mask))
}

struct BType {
	InstructionBase
}

fn (b BType) imm() u32 {
	return u32(int(b.i & (1 << 31)) >> 19) | (b.i & (1 << 7)) << 4 | (b.i >> 20) & (cpu.b6mask << 5) | (b.i >> 7) & (cpu.b4mask << 1) & ~1
}

struct JType {
	InstructionBase
}

fn (j JType) imm() u32 {
	return u32(int(j.i & (1 << 31)) >> 11) | u32(j.i & (cpu.b10mask << 21)) >> 20 | u32((j.i >> 9) & (1 << 11)) | j.i & (cpu.b8mask << 12)
}
