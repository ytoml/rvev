module cpu

import math
import bus { Bus }
import consts

const (
	n_regs = 32
)

pub struct XRegisters {
mut:
	r [n_regs]u64
}

fn x_regs_init() XRegisters {
	mut r := [cpu.n_regs]u64{}
	r[2] = consts.dram_base + consts.dram_size
	r[11] = consts.pointer_to_dtb
	return XRegisters{r}
}

pub fn (r XRegisters) read(i u64) u64 {
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

pub fn (r FRegisters) read(i u64) f64 {
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
	debug           bool
pub mut:
	x_regs XRegisters = x_regs_init()
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

fn (mut c Cpu) debug(name string, inst Instruction) {
	if c.debug {
		c.inst_counter[name]++
		fmt := inst_format(inst)
		eprintln('[DEBUG] instruction decode ok: ${name} (${fmt})')
		eprintln('[DEBUG] cpu state: ${c}')
	}
}

fn (mut c Cpu) x_write(i u64, val u64) {
	c.x_regs.write(i, val)
}

fn (c Cpu) x_read(i u64) u64 {
	return c.x_regs.read(i)
}

fn (mut c Cpu) f_write(i u64, val f64) {
	c.f_regs.write(i, val)
}

fn (c Cpu) f_read(i u64) f64 {
	return c.f_regs.read(i)
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

fn bad_inst(expected string, inst Instruction) ! {
	fmt := inst_format(inst)
	return error('Bad inst (${expected}: ${fmt})')
}

fn bad_inst_generic(inst Instruction) ! {
	return bad_inst('Unkown', inst)
}

fn signed_extend_8(val u64) u64 {
	return u64(i64(i8(val)))
}

fn signed_extend_16(val u64) u64 {
	return u64(i64(i16(val)))
}

fn signed_extend_32(val u64) u64 {
	return u64(i64(int(val)))
}

fn inst_format(i Instruction) string {
	f7 := i.funct7()
	rs2 := i.rs2()
	rs1 := i.rs1()
	f3 := i.funct3()
	rd := i.rd()
	op := i.opcode()
	return '${f7:07b}_${rs2:05b}_${rs1:05b}_${f3:03b}_${rd:05b}_${op:07b}'
}

fn (mut c Cpu) decode(raw_inst u32) !Instruction {
	inst := InstructionBase{raw_inst}
	match inst.opcode() {
		0b000_0011 {
			i := IType{inst}
			addr := c.x_read(inst.rs1()) + i.imm_sext()
			rd := inst.rd()
			match inst.funct3() {
				0b000 {
					c.debug('lb', inst)
					val := c.bus.load(addr, consts.byte_)!
					c.x_write(rd, signed_extend_8(val))
				}
				0b001 {
					c.debug('lh', inst)
					val := c.bus.load(addr, consts.half_word)!
					c.x_write(rd, signed_extend_16(val))
				}
				0b010 {
					c.debug('lw', inst)
					val := c.bus.load(addr, consts.word)!
					c.x_write(rd, signed_extend_32(val))
				}
				0b011 {
					c.debug('ld', inst)
					val := c.bus.load(addr, consts.double_word)!
					c.x_write(rd, val)
				}
				0b100 {
					c.debug('lbu', inst)
					val := c.bus.load(addr, consts.byte_)!
					c.x_write(rd, val)
				}
				0b101 {
					c.debug('lhu', inst)
					val := c.bus.load(addr, consts.half_word)!
					c.x_write(rd, val)
				}
				0b110 {
					c.debug('lwu', inst)
					val := c.bus.load(addr, consts.word)!
					c.x_write(rd, val)
				}
				else {
					bad_inst('load', inst)!
				}
			}
		}
		0b000_0111 {
			d := DType{IType{inst}}
			addr := c.x_read(inst.rs1()) + d.imm_sext()
			rd := inst.rd()
			match inst.funct3() {
				0b010 {
					c.debug('flw', inst)
					val := c.bus.load(addr, consts.word)!
					c.f_write(rd, f64(math.f32_from_bits(u32(val))))
				}
				0b011 {
					c.debug('fld', inst)
					val := c.bus.load(addr, consts.word)!
					c.f_write(rd, math.f64_from_bits(val))
				}
				else {
					bad_inst('flw|fld', inst)!
				}
			}
		}
		0b000_1111 {
			f := Fence{IType{inst}}
			f.verify()!
			match inst.funct3() {
				0b000 {
					c.debug('fence', inst)
				}
				0b001 {
					c.debug('fence.i', inst)
				}
				else {
					bad_inst('fence', inst)!
				}
			}
		}
		0b001_0011 {
			i := IType{inst}
			rs1_val := c.x_read(inst.rs1())
			rd := inst.rd()
			match inst.funct3() {
				0b000 {
					c.debug('addi', inst)
					// note that vlang's addition is 'wrapping add'
					val := rs1_val + i.imm()
					c.x_write(rd, val)
				}
				0b010 {
					c.debug('slti', inst)
					val := rs1_val < i64(i.imm())
					c.x_write(rd, u64(val))
				}
				0b011 {
					c.debug('sltiu', inst)
					val := rs1_val < i.imm()
					c.x_write(rd, u64(val))
				}
				0b100 {
					c.debug('xori', inst)
					val := rs1_val ^ i.imm()
					c.x_write(rd, val)
				}
				0b110 {
					c.debug('ori', inst)
					val := rs1_val | i.imm()
					c.x_write(rd, val)
				}
				0b111 {
					c.debug('andi', inst)
					val := rs1_val & i.imm()
					c.x_write(rd, val)
				}
				0b001 {
					c.debug('slli', inst)
					shamt := LogicalShift{i}.shamt()
					val := rs1_val << shamt
					c.x_write(rd, val)
				}
				0b101 {
					shamt := LogicalShift{i}.shamt()
					match inst.funct7() {
						0b000_0000 {
							c.debug('srli', inst)
							val := rs1_val >> shamt
							c.x_write(rd, val)
						}
						0b010_0000 {
							c.debug('srai', inst)
							val := u64(i64(rs1_val) >> shamt)
							c.x_write(rd, val)
						}
						else {
							bad_inst('srli|srai', inst)!
						}
					}
				}
				else {
					return error('fatal: funct3 bug (${inst.funct3()})')
				}
			}
		}
		0b010_0011 {
			// RV32I
			s := SType{inst}
			addr := c.x_read(inst.rs1()) + s.imm_sext()
			rs2_val := c.x_read(inst.rs2())
			match inst.funct3() {
				0b000 {
					c.debug('sb', inst)
					c.bus.store(addr, rs2_val, consts.byte_)!
				}
				0b001 {
					c.debug('sh', inst)
					c.bus.store(addr, rs2_val, consts.half_word)!
				}
				0b010 {
					c.debug('sw', inst)
					c.bus.store(addr, rs2_val, consts.word)!
				}
				0b011 {
					c.debug('sd', inst)
					c.bus.store(addr, rs2_val, consts.double_word)!
				}
				else {
					bad_inst('store', inst)!
				}
			}
		}
		0b010_0111 {
			// RV32F / RV64F
			s := SType{inst}
			addr := c.x_read(inst.rs1()) + s.imm_sext()
			rs2_val := c.f_read(inst.rs2())
			match inst.funct3() {
				0b010 {
					c.debug('fsw', inst)
					c.bus.store(addr, u64(math.f32_bits(f32(rs2_val))), consts.word)!
				}
				0b011 {
					c.debug('fsd', inst)
					c.bus.store(addr, math.f64_bits(rs2_val), consts.double_word)!
				}
				else {
					bad_inst('f store', inst)!
				}
			}
		}
		0b001_0111 {
			return error('auipc: RV32I is not supported')
		}
		else {
			panic('TODO: decode')
		}
	}
	return inst
}

pub fn (mut c Cpu) exec() !u64 {
	panic('TODO: exec')
}

pub fn (mut c Cpu) exec_compressed(inst u64) !u64 {
	panic('TODO: exec_compressed')
}
