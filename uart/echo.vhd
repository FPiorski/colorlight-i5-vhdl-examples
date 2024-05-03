ARCHITECTURE echo OF uart IS

    CONSTANT C_uart_baud      : integer   := 9600;

    SIGNAL   w_received       : std_logic_vector(7 downto 0);
    SIGNAL   w_received_valid : std_logic;

BEGIN

    uart_rx_inst : ENTITY work.uart_rx
    GENERIC MAP
    (
        g_sys_clk_hz => g_sys_clk_hz,
        g_uart_baud  => C_uart_baud
    )
    PORT MAP
    (
        i_clk        => i_clk,

        i_uart_rx    => i_uart_rx,

        o_data       => w_received,
        o_data_valid => w_received_valid
    );

    uart_tx_inst : ENTITY work.uart_tx
    GENERIC MAP
    (
        g_sys_clk_hz => g_sys_clk_hz,
        g_uart_baud  => C_uart_baud
    )
    PORT MAP
    (
        i_clk        => i_clk,
        i_data       => w_received,
        i_data_valid => w_received_valid,
        o_idle       => OPEN,
        o_uart_tx    => o_uart_tx
    );

END ARCHITECTURE;
