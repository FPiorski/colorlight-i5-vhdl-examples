PROJ = tx
# PROJ = echo

EX_NAME=uart

ADDITIONAL_SOURCES = uart_tx.vhd uart_rx.vhd

UART_BAUD = 9600
GHDL_GENERICS += -gg_uart_baud=$(UART_BAUD)

include ../common/board_selection.mk
include ../common/common.mk
