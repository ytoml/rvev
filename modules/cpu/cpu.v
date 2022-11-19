module cpu

import bus { Bus }
import consts

const (
	n_regs = 32
)

pub struct XRegisters {
mut:
	r [n_regs]u64
}

fn xregs_init() XRegisters {
	mut r := [cpu.n_regs]u64{}
	r[2] = consts.dram_base + consts.dram_size
	r[11] = consts.pointer_to_dtb
	return XRegisters{r}
}

pub fn (mut r XRegisters) read(i u64) u64 {
	return r.r[i]
}

pub fn (mut r XRegisters) write(i u64, val u64) {
	r.r[i] = val
}

fn xreg_name(i int) string {
	return match i {
		0 { 'zero' }
		1 { 'ra' }
		2 { 'sp' }
		3 { 'gp' }
		4 { 'tp' }
		5...7 { 't${i - 5}' }
		8...9 { 's${i - 8}' }
		10...17 { 'a${i - 10}' }
		18...27 { 's${i - 16}' }
		28...31 { 't${i - 25}' }
		else { 'invalid' }
	}
}

pub fn (r XRegisters) str() string {
	// regnames
	abi := [cpu.n_regs]string{init: xreg_name(it)}
	mut display := 'XRegisters\n'
	for i, name in abi {
		x := 'x${i}'
		nameattr := '${x:5}(${name})'
		display += '${nameattr:-12}0x${r.r[i]:010x}\n'
	}
	return display
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

fn freg_name(i int) string {
	return match i {
		// temporal registers
		0...7 { 'ft${i}' }
		8...9 { 'fs${i - 8}' }
		// float arguments(fa0,fa1 also for return)
		10...17 { 'fa${i - 10}' }
		18...27 { 'fs${i - 16}' }
		28...31 { 'ft${i - 20}' }
		else { 'invalid' }
	}
}

pub fn (r FRegisters) str() string {
	// regnames
	abi := [cpu.n_regs]string{init: freg_name(it)}
	mut display := 'FRegisters'
	for i, name in abi {
		f := 'f${i}'
		nameattr := '${f:5}(${name})'
		display += '\n${nameattr:-12}${r.r[i]:10.8f}'
	}
	return display
}

enum Mode {
	user = 0b00
	supervisor = 0b01
	machine = 0b11
}

pub struct Cpu {
	enable_paging   bool
	page_table      u64
	reservation_set []u64
pub mut:
	x_regs XRegisters = xregs_init()
	f_regs FRegisters
	bus    Bus
	pc     u64
	idle   bool
	// for debug
	inst_counter map[string]u64
	pre_inst     u64
}

pub fn new() Cpu {
	return Cpu{}
}

pub fn (mut c Cpu) fetch(size u8) !u64 {
	match size {
		consts.half_word | consts.word {
			return c.bus.load(c.pc, size)
		}
		else {
			return error('CPU: Invalid fetch size')
		}
	}
}

fn decode(inst u32) Instruction {
	panic('TODO: decode')
}

pub fn (mut c Cpu) exec() !u64 {
	panic('TODO: exec')
}

pub fn (mut c Cpu) exec_compressed(inst u64) !u64 {
	panic('TODO: exec_compressed')
}
