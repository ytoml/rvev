module cpu

fn test_jtype() {
	test_cases := [
		0
		// cannot compile due to V compiler bug: https://github.com/vlang/v/issues/16705
		// u32(0b1_1110001110_0_00110011) << 12
	]
	answers := [
		0
		// 0b1111_1111_1111_00110011_0_1110001110
	]
	for i in 0 .. test_cases.len {
		inst := test_cases[i]
		j := JType{InstructionBase{i}}
		assert j.imm() == answers[i]
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
