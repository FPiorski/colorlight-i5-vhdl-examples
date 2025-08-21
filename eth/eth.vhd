LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY eth IS
    GENERIC
    (
        g_sys_clk_hz   : integer;
        g_uart_baud    : integer := 9600
    );
    PORT
    (
        i_clk          : IN    std_logic;

        i_uart_rx      : IN    std_logic;
        o_uart_tx      :   OUT std_logic;

       io_eth_mdio     : INOUT std_logic;
        o_eth_mdc      :   OUT std_logic;

        o_eth1_ledr    :   OUT std_logic;
        o_eth1_ledl    :   OUT std_logic;
        o_eth1_tx_clk  :   OUT std_logic;
        o_eth1_tx_ctl  :   OUT std_logic;
        o_eth1_tx_data :   OUT std_logic_vector(3 downto 0);
        i_eth1_rx_clk  : IN    std_logic;
        i_eth1_rx_ctl  : IN    std_logic;
        i_eth1_rx_data : IN    std_logic_vector(3 downto 0)
    );
END eth;
