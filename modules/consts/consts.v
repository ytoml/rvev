module consts

pub const (
	dram_base = u64(0x80000000)
	// 1GiB
	dram_size = u64(0x40000000)
	page_size      = 4096
	byte_     = u8(8)
	half_word      = u8(16)
	word           = u8(32)
	double_word    = u8(64)
	pointer_to_dtb = 0x1020
)