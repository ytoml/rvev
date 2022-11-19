module devices

const source_num = 1024

// Platform Level Interrupt Controller
pub struct Plic {
mut:
	priority  [source_num]u32
	pending   [32]u32
	enable    [64]u32
	threshold [2]u32
	claim     [2]u32
}

pub fn (mut p Plic) write(addr u64, value u64, size u8) ! {
	panic('TODO: Plic.write')
}

pub fn (p Plic) read(addr u64, size u8) !u64 {
	panic('TODO: Plic.read')
}
