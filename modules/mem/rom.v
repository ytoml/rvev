module mem

import os { Process }

const dts_file = 'rvev.dts'

const dtb_file = 'rvev.dtb'

pub struct Rom {
	mem []u8
}

pub fn new_rom() !Rom {
	mem := get_dtb() or {
		println('[WARN] failed to read a device tree binary (${err})')
		println('[WARN] maybe need to install `dtc`')
		[]u8{}
	}
	cleanup()
	return Rom{mem}
}

fn (r Rom) addr_to_offset(addr u64) int {
	return int(addr)
}

fn (r Rom) name() string {
	return 'ROM'
}

pub fn (r Rom) load(addr u64, size u8) !u64 {
	m := MemoryRead(r)
	return m.load(addr, size)
}

fn get_dtb() ![]u8 {
	create_dts() or { return err }
	compile_dts() or { return err }
	return read_dtb()
}

fn create_dts() ! {
	// TODO: Make this content more flexible depending on the number of cpus.
	// Original: https://github.com/d0iasm/rvemu/blob/9a6aa8d3ec5c42ca5d87d29213b4b449c3c799d1/src/rom.rs
	content := '/dts-v1/;
/ {
    #address-cells = <0x02>;
    #size-cells = <0x02>;
    compatible = "riscv-virtio";
    model = "riscv-virtio,qemu";

    chosen {
        bootargs = "root=/dev/vda ro console=ttyS0";
        stdout-path = "/uart@10000000";
    };

    uart@10000000 {
        interrupts = <0xa>;
        interrupt-parent = <0x03>;
        clock-frequency = <0x384000>;
        reg = <0x0 0x10000000 0x0 0x100>;
        compatible = "ns16550a";
    };

    virtio_mmio@10001000 {
        interrupts = <0x01>;
        interrupt-parent = <0x03>;
        reg = <0x0 0x10001000 0x0 0x1000>;
        compatible = "virtio,mmio";
    };

    cpus {
        #address-cells = <0x01>;
        #size-cells = <0x00>;
        timebase-frequency = <0x989680>;

        cpu-map {
            cluster0 {
                core0 {
                    cpu = <0x01>;
                };
            };
        };

        cpu@0 {
            phandle = <0x01>;
            device_type = "cpu";
            reg = <0x00>;
            status = "okay";
            compatible = "riscv";
            riscv,isa = "rv64imafdcsu";
            mmu-type = "riscv,sv48";

            interrupt-controller {
                #interrupt-cells = <0x01>;
                interrupt-controller;
                compatible = "riscv,cpu-intc";
                phandle = <0x02>;
            };
        };
    };

	memory@80000000 {
		device_type = "memory";
		reg = <0x0 0x80000000 0x0 0x8000000>;
	};

    soc {
        #address-cells = <0x02>;
        #size-cells = <0x02>;
        compatible = "simple-bus";
        ranges;

        interrupt-controller@c000000 {
            phandle = <0x03>;
            riscv,ndev = <0x35>;
            reg = <0x00 0xc000000 0x00 0x4000000>;
            interrupts-extended = <0x02 0x0b 0x02 0x09>;
            interrupt-controller;
            compatible = "riscv,plic0";
            #interrupt-cells = <0x01>;
            #address-cells = <0x00>;
        };

        clint@2000000 {
            interrupts-extended = <0x02 0x03 0x02 0x07>;
            reg = <0x00 0x2000000 0x00 0x10000>;
            compatible = "riscv,clint0";
        };
    };
};'
	mut f := os.create(mem.dts_file) or { return error('Failed to create dts file (${err})') }
	defer {
		f.close()
	}
	f.write_string(content) or { return error('Failed to write dts file (${err})') }
}

fn compile_dts() ! {
	mut cmd := Process{
		filename: 'dtc'
		args: ['-I', 'dts', '-O', 'dtb', '-o', mem.dtb_file, mem.dts_file]
	}
	defer {
		cmd.close()
	}
	cmd.run()
	if cmd.err != '' {
		return error('Failed to compile dts (${cmd.err})')
	}
}

fn read_dtb() ![]u8 {
	mut dtb := []u8{}
	mut f := os.open(mem.dtb_file) or { return error('Failed to open dtb file (${err})') }
	f.read(mut dtb) or { return error('Failed to read dtb file (${err})') }
	return dtb
}

fn cleanup() {
	os.rm(mem.dts_file) or { println('[WARN] ROM: Failed to create') }
}
