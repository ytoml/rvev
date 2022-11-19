module mem

import consts

interface MemoryBase {
	addr_to_offset(addr u64) int
	name() string
}

interface MemoryWrite {
	MemoryBase
mut:
	mem []u8
}

interface MemoryRead {
	MemoryBase
	mem []u8
}

interface Memory {
	MemoryWrite
	MemoryRead
}

// size unit is bit
fn (mut m MemoryWrite) store(addr u64, value u64, size u8) ! {
	offset := m.addr_to_offset(addr)
	match size {
		consts.byte_ {
			m.write8(offset, value)
		}
		consts.half_word {
			m.write16(offset, value)
		}
		consts.word {
			m.write32(offset, value)
		}
		consts.double_word {
			m.write64(offset, value)
		}
		else {
			return error('Write (${m.name()}): invalid size ${size}')
		}
	}
}

// size unit is bit
fn (m MemoryRead) load(addr u64, size u8) !u64 {
	offset := m.addr_to_offset(addr)
	match size {
		consts.byte_ {
			return m.read8(offset)
		}
		consts.half_word {
			return m.read16(offset)
		}
		consts.word {
			return m.read32(offset)
		}
		consts.double_word {
			return m.read64(offset)
		}
		else {
			return error('Read (${m.name()}): invalid size ${size}')
		}
	}
}

// Reads/Writes are all in LITTLE ENDIAN
fn (mut m MemoryWrite) write8(i int, value u64) {
	m.mem[i] = u8(value & byte_mask)
}

fn (mut m MemoryWrite) write16(i int, value u64) {
	m.mem[i] = u8(value & byte_mask)
	m.mem[i + 1] = u8((value >> 8) & byte_mask)
}

fn (mut m MemoryWrite) write32(i int, value u64) {
	for off in 0 .. 4 {
		s := off * 8
		m.mem[i + off] = u8((value >> s) & byte_mask)
	}
}

fn (mut m MemoryWrite) write64(i int, value u64) {
	for off in 0 .. 8 {
		s := off * 8
		m.mem[i + off] = u8((value >> s) & byte_mask)
	}
}

fn (m MemoryRead) read8(i int) u64 {
	return m.mem[i]
}

fn (m MemoryRead) read16(i int) u64 {
	return m.mem[i] + u64(m.mem[i + 1]) << 8
}

fn (m MemoryRead) read32(i int) u64 {
	mut value := u64(0)
	for off in 0 .. 4 {
		s := off * 8
		value += u64(m.mem[i + off]) << s
	}
	return value
}

fn (m MemoryRead) read64(i int) u64 {
	mut value := u64(0)
	for off in 0 .. 8 {
		s := off * 8
		value += u64(m.mem[i + off]) << s
	}
	return value
}
