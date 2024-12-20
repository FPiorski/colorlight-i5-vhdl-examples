LPF = ../common/$(BOARD).lpf
PACKAGE = CABGA381
NEXTPNR_FLAGS = --25k --freq 100

CLK_FREQ = 25_000_000

GHDL_GENERICS += -gg_sys_clk_hz=$(CLK_FREQ)

all: $(PROJ).bit

%.json: $(EX_NAME).vhd %.vhd $(ADDITIONAL_SOURCES)
	yosys -m ghdl -p 'ghdl $(GHDL_GENERICS) $^ -e $(EX_NAME); synth_ecp5 -json $@'

$(PROJ)_out.config: $(PROJ).json $(LPF)
	nextpnr-ecp5 $(NEXTPNR_FLAGS) --package $(PACKAGE) --speed 6 --randomize-seed \
	 --json $< --textcfg $@ --lpf $(LPF)

$(PROJ).bit: $(PROJ)_out.config
	ecppack --compress --svf ${PROJ}.svf $< $@

${PROJ}.svf : ${PROJ}.bit

just_pnr : $(PROJ)_out.config

PROGRAMMER?=cmsisdap

prog: ${PROJ}.bit
	openFPGALoader -c $(PROGRAMMER) $(PROJ).bit

clean:
	rm -f *.svf *.bit *.config *.json *.cf

.PHONY: all prog clean just_pnr
