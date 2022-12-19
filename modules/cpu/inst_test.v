module cpu

fn test_jtype() {
	test_cases := [
		[0b1 << 31 | 0b1110001110 << 21 | 0b1 << 20 | 0b00110011 << 12,
			0b1111_1111_1111 << 20 | 0b00110011 << 12 | 0b1 << 11 | 0b1110001110 << 1]
		// cannot compile due to V compiler bug: https://github.com/vlang/v/issues/16705
		// u32(0b1_1110001110_1_00110011) << 12, 0b1111_1111_1111_00110011_1_1110001110
	]
	for i in 0 .. test_cases.len {
		inst := u32(test_cases[i][0])
		j := JType{InstructionBase{inst}}
		ans := u32(test_cases[i][1])
		assert j.imm() == ans
	}
}

fn test_stype_imm() {
	test_cases := [
		[0b111_0000 << 25 | 0b11111 << 7, 0b1111_111_0000_11111],
	]
	for i in 0 .. test_cases.len {
		inst := u32(test_cases[i][0])
		s := SType{InstructionBase{inst}}
		ans := u64(i64(i16(test_cases[i][1])))
		assert s.imm_sext() == ans
	}
}

fn test_btype_imm() {
	test_cases := [
		[0b1_110011 << 25 | 0b10001 << 7, 0b111_1_1_110011_1000_0],
	]
	for i in 0 .. test_cases.len {
		inst := u32(test_cases[i][0])
		b := BType{InstructionBase{inst}}
		ans := u32(i32(i16(test_cases[i][1])))
		assert b.imm() == ans
	}
}
