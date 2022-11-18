module bus

import devices { Clint, Plic, Uart, Virtio }
import dram { Dram }

pub struct Bus {
	dram Dram
pub mut:
	clint  Clint
	plic   Plic
	uart   Uart
	virtio Virtio
}
