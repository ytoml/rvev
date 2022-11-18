module devices

const source_num = 1024

// Platform Level Interrupt Controller
pub struct Plic {
	priority  [source_num]u32
	pending   [32]u32
	enable    [64]u32
	threshold [2]u32
	claim     [2]u32
}
