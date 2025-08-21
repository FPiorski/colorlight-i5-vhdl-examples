# PROJ = mdio
PROJ = txtest
# PROJ = rxtest

EX_NAME=eth

ADDITIONAL_SOURCES = ../uart/uart_tx.vhd ../uart/uart_rx.vhd mdio_master.vhd rgmii_tx_fixed.vhd rgmii_rx.vhd fifo.vhd synchronizer_chain.vhd

UART_BAUD = 115200
GHDL_GENERICS += -gg_uart_baud=$(UART_BAUD)

include ../common/board_selection.mk
include ../common/common.mk
