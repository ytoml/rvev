module dram

import os { File }

import consts

const byte_mask = 0xff

fn addr_to_offset(addr u64) int {
	return int(addr - consts.dram_base)
}

pub struct Dram {
pub mut:
	m []u8
}
pub fn new(f File) !Dram {
	mut m := []u8{len: int(consts.dram_size), init: 0}
	f.read(mut m) or {
		return error('Initializing DRAM: ${err}')
	}
	return Dram { m }
}
pub fn (mut d Dram) write(addr u64, value u64, size u8) ! {
	match size {
		consts.byte_ {
			d.write8(addr, value)
		}
		consts.half_word {
			d.write16(addr, value)
		}
		consts.word {
			d.write32(addr, value)
		}
		consts.double_word {
			d.write64(addr, value)
		}
		else {
			return error("DRAM write: invalid size ${size}")
		}
	}
}
pub fn (mut d Dram) read(addr u64, size u8) !u64 {
	match size {
		consts.byte_ {
			return d.read8(addr)
		}
		consts.half_word {
			return d.read16(addr)
		}
		consts.word {
			return d.read32(addr)
		}
		consts.double_word {
			return d.read64(addr)
		}
		else {
			return error("DRAM read: invalid size ${size}")
		}
	}
}
// Reads/Writes are all in LITTLE ENDIAN
fn (mut d Dram) write8(addr u64, value u64) {
	i := addr_to_offset(addr)
	d.m[i] = u8(value & byte_mask)
}
fn (mut d Dram) write16(addr u64, value u64) {
	i := addr_to_offset(addr)
	d.m[i] = u8(value & byte_mask)
	d.m[i+1] = u8((value >> 8) & byte_mask)
}
fn (mut d Dram) write32(addr u64, value u64) {
	i := addr_to_offset(addr)
	for off in 0..4 {
		s := off * 8
		d.m[i+off] = u8((value >> s) & byte_mask)
	}
}
fn (mut d Dram) write64(addr u64, value u64) {
	i := addr_to_offset(addr)
	for off in 0..8 {
		s := off * 8
		d.m[i+off] = u8((value >> s) & byte_mask)
	}
}
fn (mut d Dram) read8(addr u64) u64 {
	i := addr_to_offset(addr)
	return d.m[i]
}
fn (mut d Dram) read16(addr u64) u64 {
	i := addr_to_offset(addr)
	return d.m[i] + u64(d.m[i+1]) << 8
}
fn (mut d Dram) read32(addr u64) u64 {
	i := addr_to_offset(addr)
	mut value := u64(0)
	for off in 0..4 {
		s := off * 8
		value += u64(d.m[i+off]) << s
	}
	return value
}
fn (mut d Dram) read64(addr u64) u64 {
	i := addr_to_offset(addr)
	mut value := u64(0)
	for off in 0..8 {
		s := off * 8
		value += u64(d.m[i+off]) << s
	}
	return value
}