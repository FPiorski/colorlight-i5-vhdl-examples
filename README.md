# colorlight-i5-vhdl-examples

I managed to get the toolchain set-up, so it's time for some fun. For more information, see `README.md` files in project directories.

`make prog` uses cmsis-dap by default (the USB <-> JTAG adapter present on the extension board), if you're using a different JTAG cable, pass it using the `PROGRAMMER` environment variable - either by running (for example) `PROGRAMMER=ft232 make prog` every time or `export PROGRAMMER=ft232` once.

## Requirements
* [ghdl](https://github.com/ghdl/ghdl)
* [ghdl-yosys-plugin](https://github.com/ghdl/ghdl-yosys-plugin)
* [yosys](https://github.com/YosysHQ/yosys)
* [nextpnr](https://github.com/YosysHQ/nextpnr)
* [Project Trellis](https://github.com/YosysHQ/prjtrellis)
* (optionally) [openFPGALoader](https://github.com/trabucayre/openFPGALoader)
* (optionally) [GTKWave](https://github.com/gtkwave/gtkwave)

##### (My) RTL code in this repo is licensed under CERN-OHL-W-2.0 (see LICENSE file)
