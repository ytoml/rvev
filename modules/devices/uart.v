module devices

const uart_size = 0x100

pub struct Uart {
	interrupting bool
mut:
	ua [uart_size]u8
}

pub fn (mut u Uart) write(addr u64, value u64, size u8) ! {
	panic('TODO: Uart.write')
}

pub fn (u Uart) read(addr u64, size u8) !u64 {
	panic('TODO: Uart.read')
}
