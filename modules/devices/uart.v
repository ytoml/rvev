module devices

const uart_size = 0x100

pub struct Uart {
	ua           [uart_size]u8
	interrupting bool
}
