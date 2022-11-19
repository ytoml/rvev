module devices

pub struct Clint {
mut:
	msip     u32
	mtimecmp u64
	mtime    u64
}

pub fn (c Clint) write(addr u64, value u64, size u8) ! {
	panic('TODO: Clint.write')
}

pub fn (c Clint) read(addr u64, size u8) !u64 {
	panic('TODO: Clint.read')
}
