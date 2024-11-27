ARCHITECTURE tx OF uart IS

    CONSTANT C_uart_baud    : integer   := g_uart_baud;
    CONSTANT C_char_ms      : integer   :=  10;

    CONSTANT C_char_cnt_mod : integer   := g_sys_clk_hz / 1000 * C_char_ms;
    SIGNAL   r_char_cnt     : integer RANGE 0 TO C_char_cnt_mod-1 := 0;

    SIGNAL   r_send         : std_logic := '0';

BEGIN

    P_mostly_wait_around : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_send <= '0';
            IF (r_char_cnt < C_char_cnt_mod-1) THEN
                r_char_cnt <= r_char_cnt + 1;
            ELSE
                r_char_cnt <=  0;
                r_send     <= '1';
            END IF;
        END IF;
    END PROCESS;

    uart_tx_inst : ENTITY work.uart_tx
    GENERIC MAP
    (
        g_sys_clk_hz => g_sys_clk_hz,
        g_uart_baud  => C_uart_baud
    )
    PORT MAP
    (
        i_clk        => i_clk,
        i_data       => std_logic_vector(to_unsigned(character'POS('F'), 8)),
        i_data_valid => r_send,
        o_idle       => OPEN,
        o_uart_tx    => o_uart_tx
    );

END ARCHITECTURE;
