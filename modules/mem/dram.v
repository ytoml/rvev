module mem

import os { File }
import consts

const byte_mask = 0xff

struct DramBase {}

pub struct Dram {
mut:
	mem []u8
}

pub fn new_dram(f File) !Dram {
	mut mem := []u8{len: int(consts.dram_size), init: 0}
	f.read(mut mem) or { return error('Initializing DRAM: ${err}') }
	return Dram{mem}
}

fn (d Dram) addr_to_offset(addr u64) int {
	return int(addr - consts.dram_base)
}

fn (d Dram) name() string {
	return 'DRAM'
}

pub fn (mut d Dram) store(addr u64, value u64, size u8) ! {
	mut m := MemoryWrite(d)
	return m.store(addr, value, size)
}

pub fn (d Dram) load(addr u64, size u8) !u64 {
	m := MemoryRead(d)
	return m.load(addr, size)
}
