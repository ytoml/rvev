module csr

const n_csr = 4096

type CsrAddr = u16

enum RegisterSpec {
	// Reserved writes ignored, reads ignore values
	wiri
	// Reserved writes preserve values, reads ignore values
	wpri
	// Write/read only legal values
	wlrl
	// Write any values, reads legal values
	warl
}

// Machine interrupt pending
pub const (
	misa = CsrAddr(0x0301)
	mip  = CsrAddr(0x0344)
	time = CsrAddr(0x0c01)
)

pub struct State {
mut:
	csr [n_csr]u64
}

pub fn new_state() State {
	mut regs := [csr.n_csr]u64{}
	regs[csr.misa] = (2 << 62) | // MXL[1:0]=2 (XLEN is 64)
	(1 << 20) | // User mode implemented
	(1 << 18) | // Supervisor mode implemented
	(1 << 12) | // Integer Multiply/Divide extension
	(1 << 8) | // RV32I/64I/128I base ISA
	(1 << 5) | // Single-precision floating-point extension
	(1 << 3) | // Double-precision floating-point extension
	(1 << 2) | // Compressed extension
	1 // Atomic extension
	return State{
		csr: regs
	}
}

pub fn (mut s State) increment_time() {
	s.csr[csr.time]++
}

pub fn (mut s State) write(addr CsrAddr, value u64) {
	match addr2spec(addr) {
		.wiri {}
		.wpri {}
		.wlrl {}
		.warl {}
	}
	panic('TODO: csr.State.write')
}

pub fn (mut s State) read(addr CsrAddr) u64 {
	match addr2spec(addr) {
		.wiri {}
		.wpri {}
		.wlrl {}
		.warl {}
	}
	panic('TODO: csr.State.read')
}

fn addr2spec(addr CsrAddr) RegisterSpec {
	panic('TODO: csr.addr2spec')
}
