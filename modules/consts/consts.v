module consts

pub const (
	dram_base      = u64(0x8000_0000)
	// 1GiB
	dram_size      = u64(0x4000_0000)
	page_size      = 4096
	byte_          = u8(8)
	half_word      = u8(16)
	word           = u8(32)
	double_word    = u8(64)
	pointer_to_dtb = 0x1020
	// MMIO
	mask_rom_base  = u64(0x0000_1000)
	clint_base     = u64(0x0200_0000)
	plic_base      = u64(0x0c00_0000)
	uart_base      = u64(0x1000_0000)
	virtio_base    = u64(0x1000_1000)
)
