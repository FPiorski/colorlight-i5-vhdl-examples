#PROJ = blank
#PROJ = test_pattern
PROJ = text0
#PROJ = text1

EX_NAME=video

ADDITIONAL_SOURCES = ../uart/uart_rx.vhd ../uart/uart_tx.vhd \
					 pattern_generator.vhd \
				     pll.vhd video_encoder.vhd tmds_encoder.vhd pseudo_diff_outb.vhd \
				     bram.vhd character_ram.vhd

include ../common/board_selection.mk
include ../common/common.mk
