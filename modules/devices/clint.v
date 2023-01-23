module devices

import consts
import csr { State }

const (
	msip         = consts.clint_base
	msip_end     = msip + 0x4
	mtimecmp     = msip + 0x4000
	mtimecmp_end = mtimecmp + 0x8
	mtime        = msip + 0xbff8
	mtime_end    = mtime + 0x8
)

// Core-local Interrupter
pub struct Clint {
mut:
	msip     u32
	mtimecmp u64
	mtime    u64
}

pub fn (mut c Clint) increment(mut state State) {
	c.mtime += 1
	if c.msip & 1 != 0 {
	}
	if c.mtimecmp > c.mtime {
	} else {
	}
}

pub fn (mut c Clint) write(addr u64, value u64, size u8) ! {
	match true {
		devices.msip <= addr && addr <= devices.msip_end {}
		devices.mtimecmp <= addr && addr <= devices.mtimecmp_end {}
		devices.mtime <= addr && addr <= devices.mtime_end {}
		else {}
	}
	panic('TODO: Clint.write')
}

pub fn (c Clint) read(addr u64, size u8) !u64 {
	match true {
		devices.msip <= addr && addr <= devices.msip_end {}
		devices.mtimecmp <= addr && addr <= devices.mtimecmp_end {}
		devices.mtime <= addr && addr <= devices.mtime_end {}
		else {}
	}
	panic('TODO: Clint.read')
}
