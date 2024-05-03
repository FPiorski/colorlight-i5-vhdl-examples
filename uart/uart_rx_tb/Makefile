all: build run display

rtl_work:
	mkdir rtl_work

build: rtl_work
	ghdl -i --std=08 -frelaxed -frelaxed-rules -Wno-library  --work=rtl_work --workdir=rtl_work ../uart_tx.vhd
	ghdl -i --std=08 -frelaxed -frelaxed-rules -Wno-library  --work=rtl_work --workdir=rtl_work ../uart_rx.vhd
	ghdl -i --std=08 -frelaxed -frelaxed-rules -Wno-library  --work=rtl_work --workdir=rtl_work tb_top.vhd
	ghdl -m --std=08 -frelaxed -Wno-library --work=rtl_work --workdir=rtl_work tb_top

run: build
	ghdl -r --std=08 -v -frelaxed --work=rtl_work --workdir=rtl_work tb_top --stop-delta=10000 --wave=wave.ghw 2>&1

display: run
	gtkwave wave.ghw view.gtkw 2>&1

clean:
	rm -rf rtl_work wave.ghw

.PHONY: all build run display clean
