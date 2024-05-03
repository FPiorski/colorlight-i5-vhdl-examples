#PROJ = tx
PROJ = echo

ADDITIONAL_SOURCES = uart_tx.vhd uart_rx.vhd

LPF = ../common/io.lpf
PACKAGE = CABGA381
NEXTPNR_FLAGS = --25k --freq 100

CLK_FREQ = 25_000_000

GHDL_GENERICS = -gg_sys_clk_hz=$(CLK_FREQ)

all: $(PROJ).bit

%.json: uart.vhd %.vhd
	yosys -m ghdl -p 'ghdl $(GHDL_GENERICS) $^ $(ADDITIONAL_SOURCES) -e uart; synth_ecp5 -json $@'

$(PROJ)_out.config: $(PROJ).json $(LPF) $(ADDITIONAL_SOURCES)
	nextpnr-ecp5 $(NEXTPNR_FLAGS) --package $(PACKAGE) --speed 6 --json $< --textcfg $@ --lpf $(LPF)

$(PROJ).bit: $(PROJ)_out.config
	ecppack --svf ${PROJ}.svf $< $@

${PROJ}.svf : ${PROJ}.bit

prog: ${PROJ}.bit
	openFPGALoader -b colorlight-i5 $(PROJ).bit

prog-blaster: ${PROJ}.bit
	openFPGALoader -c usb-blaster $(PROJ).bit

clean:
	rm -f *.svf *.bit *.config *.json

.PHONY: all prog prog-blaster clean
