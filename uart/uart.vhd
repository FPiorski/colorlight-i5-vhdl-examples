LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY uart IS
    GENERIC
    (
        g_sys_clk_hz : integer;
        g_uart_baud  : integer := 9600
    );
    PORT
    (
        i_clk        : IN    std_logic;

        i_uart_rx    : IN    std_logic;
        o_uart_tx    :   OUT std_logic
    );
END uart;
