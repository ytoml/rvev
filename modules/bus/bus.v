module bus

import consts
import devices { Clint, Plic, Uart, Virtio }
import mem { Dram, Rom }

const (
	mask_rom_end = consts.mask_rom_base + 0xf000
	clint_end    = consts.clint_base + 0x0001_0000
	plic_end     = consts.plic_base + 0x0020_8000
	uart_end     = consts.uart_base + 0x0100
	virtio_end   = consts.virtio_base + 0x1000
	dram_end     = consts.dram_base + consts.dram_size
)

pub struct Bus {
mut:
	dram Dram
	rom  Rom
pub mut:
	clint  Clint
	plic   Plic
	uart   Uart
	virtio Virtio
}

pub fn new(dram Dram, rom Rom) Bus {
	return Bus{}
}

pub fn (mut b Bus) store(addr u64, value u64, size u8) ! {
	match true {
		consts.clint_base <= addr && addr <= bus.clint_end {
			return b.clint.write(addr, value, size)
		}
		consts.plic_base <= addr && addr <= bus.plic_end {
			return b.plic.write(addr, value, size)
		}
		consts.uart_base <= addr && addr <= bus.uart_end {
			return b.uart.write(addr, value, size)
		}
		consts.virtio_base <= addr && addr <= bus.virtio_end {
			return b.virtio.write(addr, value, size)
		}
		consts.dram_base <= addr && addr <= bus.dram_end {
			return b.dram.store(addr, value, size)
		}
		else {
			return error('Store address fault (0x${addr:08x})')
		}
	}
}

pub fn (b Bus) load(addr u64, size u8) !u64 {
	match true {
		consts.mask_rom_base <= addr && addr <= bus.mask_rom_end {
			return b.rom.load(addr, size)
		}
		consts.clint_base <= addr && addr <= bus.clint_end {
			return b.clint.read(addr, size)
		}
		consts.plic_base <= addr && addr <= bus.plic_end {
			return b.plic.read(addr, size)
		}
		consts.uart_base <= addr && addr <= bus.uart_end {
			return b.uart.read(addr, size)
		}
		consts.virtio_base <= addr && addr <= bus.virtio_end {
			return b.virtio.read(addr, size)
		}
		consts.dram_base <= addr && addr <= bus.dram_end {
			return b.dram.load(addr, size)
		}
		else {
			return error('Load address fault (0x${addr:08x})')
		}
	}
}
