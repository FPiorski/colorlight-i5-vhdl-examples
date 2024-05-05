#PROJ = blank
PROJ = test_pattern

ADDITIONAL_SOURCES = ../uart/uart_rx.vhd ../uart/uart_tx.vhd pll.vhd video_encoder.vhd tmds_encoder.vhd pseudo_diff_outb.vhd

LPF = ../common/io.lpf
PACKAGE = CABGA381
NEXTPNR_FLAGS = --25k --freq 100

CLK_FREQ = 25_000_000

GHDL_GENERICS = -gg_sys_clk_hz=$(CLK_FREQ)

all: $(PROJ).bit

%.json: video.vhd pattern_generator.vhd %.vhd $(ADDITIONAL_SOURCES)
	yosys -m ghdl -p 'ghdl $(GHDL_GENERICS) $^ -e video; synth_ecp5 -json $@'

$(PROJ)_out.config: $(PROJ).json $(LPF)
	nextpnr-ecp5 $(NEXTPNR_FLAGS) --package $(PACKAGE) --placer-heap-cell-placement-timeout 4 --speed 6 --randomize-seed --json $< --textcfg $@ --lpf $(LPF)

$(PROJ).bit: $(PROJ)_out.config
	ecppack --compress --svf ${PROJ}.svf $< $@

${PROJ}.svf : ${PROJ}.bit

prog: ${PROJ}.bit
	openFPGALoader -b colorlight-i5 $(PROJ).bit

prog-blaster: ${PROJ}.bit
	openFPGALoader -c usb-blaster $(PROJ).bit

just_pnr : $(PROJ)_out.config

clean:
	rm -f *.svf *.bit *.config *.json

.PHONY: all prog prog-blaster clean just_pnr
