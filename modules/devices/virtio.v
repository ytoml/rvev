module devices

pub struct Virtio {}

pub fn (mut v Virtio) write(addr u64, value u64, size u8) ! {
	panic('TODO: Virtio.write')
}

pub fn (v Virtio) read(addr u64, size u8) !u64 {
	panic('TODO: Virtio.read')
}
