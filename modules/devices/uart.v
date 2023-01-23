module devices

import consts

pub const size = 0x100

const (
	// Receive holding register (for input bytes)
	rhr    = consts.uart_base
	// Transmit holding register (for input bytes)
	thr    = consts.uart_base
	// Interrupt enabling register
	ier    = consts.uart_base + 1
	// FIFO controll register
	fcr    = consts.uart_base + 2
	// Interrupt status register
	isr    = consts.uart_base + 2
	// Line control register
	lcr    = consts.uart_base + 3
	// Line status register
	lsr    = consts.uart_base + 5
	lsr_rx = u8(1)
	lsr_tx = u8(1 << 5)
)

pub struct Uart {
	interrupting bool
mut:
	ua [size]u8
}

pub fn (mut u Uart) write(addr u64, value u64, size u8) ! {
	panic('TODO: Uart.write')
}

pub fn (u Uart) read(addr u64, size u8) !u64 {
	panic('TODO: Uart.read')
}
