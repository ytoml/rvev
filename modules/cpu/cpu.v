module cpu

import dram
import bus

pub const (
	n_regs = 32
)

const (
	page_size = 4096

	half_word = 16
	word = 32
	double_word = 64
	pointer_to_dtb = 0x1020
)

pub struct XRegisters {
mut: 
	r [n_regs]u64
}
fn xregs_init() XRegisters {
	mut r := [n_regs]u64{}
	r[2] = bus.dram_base + dram.dram_size
	r[11] = pointer_to_dtb
	return XRegisters { r }
}
pub fn (mut r XRegisters) read(i u64) u64 {
	return r.r[i]
}
pub fn (mut r XRegisters) write(i u64, val u64) {
	r.r[i] = val
}

struct FRegisters {
mut:
	r [n_regs]f64
}
pub fn (mut r FRegisters) read(i u64) f64 {
	return r.r[i]
}
pub fn (mut r FRegisters) write(i u64, val f64) {
	r.r[i] = val
}

enum Mode {
	user = 0b00
	supervisor = 0b01
	machine = 0b11
}

pub struct Cpu {
	enable_paging bool
	page_table u64
	reservation_set []u64
pub mut:
	x_regs XRegisters = xregs_init()
	f_regs FRegisters
	pc u64
	idle bool
	// for debug
	inst_counter map[string]u64
	pre_inst u64
}

pub fn new() Cpu {
	return Cpu {}
}

pub fn (mut cpu Cpu) exec() !u64 {
	return 0
}

pub fn (mut cpu Cpu) exec_compressed(inst u64) !u64 {
	return 0
}
