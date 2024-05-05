ARCHITECTURE text0 OF pattern_generator IS

    SIGNAL   r_red                : std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL   r_green              : std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL   r_blue               : std_logic_vector(7 downto 0) := (OTHERS => '0');

    --Since syncs and de are derived synchronously one level up,
    -- they are one cycle behind i_x, i_y and i_t. That's good,
    -- since with anything more than a simple test pattern we take a couple
    -- of cycles to calculate color values anyway, just make sure to set
    -- this constant to the number of pipeline stages to make sure everything
    -- stays in sync
    CONSTANT C_delay              : positive :=  1;
    SIGNAL   r_hsync              : std_logic_vector(C_delay-1 downto 0) := (OTHERS => '0');
    SIGNAL   r_vsync              : std_logic_vector(C_delay-1 downto 0) := (OTHERS => '0');
    SIGNAL   r_de                 : std_logic_vector(C_delay-1 downto 0) := (OTHERS => '0');

    SIGNAL   w_uart_rx_data       : std_logic_vector(7 downto 0);
    SIGNAL   w_uart_rx_data_valid : std_logic;

    --Cursor
    CONSTANT C_ax_mod             : integer := g_x_active/8;
    SIGNAL   r_ax                 : integer RANGE 0 TO C_ax_mod-1 := 0;
    CONSTANT C_ay_mod             : integer := g_y_active/8;
    SIGNAL   r_ay                 : integer RANGE 0 TO C_ay_mod-1 := 0;

    --Character
    CONSTANT C_cx_mod             : integer := g_x_active/8;
    SIGNAL   r_cx                 : integer RANGE 0 TO C_cx_mod-1 := 0;
    CONSTANT C_cy_mod             : integer := g_y_active/8;
    SIGNAL   r_cy                 : integer RANGE 0 TO C_cy_mod-1 := 0;

    SIGNAL   r_read_char          : std_logic := '0';

    SIGNAL   w_char_data          : std_logic_vector(7 downto 0);

    SIGNAL   r_uart_rx_data       : std_logic_vector(7 downto 0)  := (OTHERS => '0');
    SIGNAL   r_uart_rx_data_prev  : std_logic_vector(7 downto 0)  := (OTHERS => '0');

    SIGNAL   r_write_to_bram      : std_logic := '0';

    SIGNAL   w_wr_addr            : std_logic_vector(13-1 downto 0);
    SIGNAL   w_rd_addr            : std_logic_vector(13-1 downto 0);

BEGIN

    --Unused
    o_uart_tx <= '1';
    o_led     <= '0';

    o_hsync   <= r_hsync(0);
    o_vsync   <= r_vsync(0);
    o_de      <= r_de(0);

    o_r       <= r_red;
    o_g       <= r_green;
    o_b       <= r_blue;

    P_arrows : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_write_to_bram <= '0';
            IF (w_uart_rx_data_valid = '1') THEN
                r_uart_rx_data_prev <= r_uart_rx_data;
                r_uart_rx_data      <= w_uart_rx_data;
                --Arrow keys
                IF (r_uart_rx_data_prev = X"1B" AND r_uart_rx_data = X"5B") THEN
                    CASE (w_uart_rx_data) IS
                        WHEN X"41" =>
                            IF (r_ay > 0) THEN
                                r_ay <= r_ay - 1;
                            END IF;
                        WHEN X"44" =>
                            IF (r_ax > 0) THEN
                                r_ax <= r_ax - 1;
                            END IF;
                        WHEN X"42" =>
                            IF (r_ay < C_ay_mod-1) THEN
                                r_ay <= r_ay + 1;
                            END IF;
                        WHEN X"43" =>
                            IF (r_ax < C_ax_mod-1) THEN
                                r_ax <= r_ax + 1;
                            END IF;
                        WHEN OTHERS =>
                            NULL;
                    END CASE;
                ELSE
                    IF (NOT (w_uart_rx_data = X"1B" OR (w_uart_rx_data = X"5B" AND r_uart_rx_data = X"1B"))) THEN
                        IF (r_ax < C_ax_mod-1) THEN
                            r_ax <= r_ax + 1;
                        ELSE
                            r_ax <= 0;
                            IF (r_ay < C_ay_mod-1) THEN
                                r_ay <= r_ay + 1;
                            ELSE
                                r_ay <= 0;
                            END IF;
                        END IF;
                        r_write_to_bram <= '1';
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    P_generate_pattern : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_read_char <= '0';
            IF (i_x < g_x_active AND i_y < g_y_active) THEN
                r_cx <= i_x/8;
                r_cy <= i_y/8;
                IF (to_unsigned(i_x, 3) = "000") THEN
                    r_read_char <= '1';
                END IF;
            END IF;
            IF (r_read_char = '1') THEN
                r_red   <= X"FF";
            ELSE
                r_red   <= X"00";
            END IF;
            IF (r_cx < 8) THEN
                r_green <= (OTHERS => r_uart_rx_data(r_cx));
            ELSE
                r_green <= (OTHERS => '0');
            END IF;
            r_blue  <= w_char_data;
        END IF;
    END PROCESS;

    P_delay_syncs : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            --Interesting, ghdl doesn't seem to mind C_delay=1 and interprets (0 downto 1) as nothing?
            r_hsync <= i_hsync & r_hsync(C_delay-1 downto 1);
            r_vsync <= i_vsync & r_vsync(C_delay-1 downto 1);
            r_de    <= i_de    &    r_de(C_delay-1 downto 1);
        END IF;
    END PROCESS;

    uart_rx_inst : ENTITY work.uart_rx
    GENERIC MAP
    (
        g_sys_clk_hz => g_sys_clk_hz,
        g_uart_baud  => 9600
    )
    PORT MAP
    (
        i_clk        => i_clk,

        i_uart_rx    => i_uart_rx,

        o_data       => w_uart_rx_data,
        o_data_valid => w_uart_rx_data_valid
    );

    w_wr_addr <= std_logic_vector(to_unsigned(r_ax, 7) & to_unsigned(r_ay, 6));
    w_rd_addr <= std_logic_vector(to_unsigned(r_cx, 7) & to_unsigned(r_cy, 6));

    bram_inst : ENTITY work.bram
    GENERIC MAP
    (
        g_width      => 8,
        g_depth_log2 => 7+6
    )
    PORT MAP
    (
        i_clk        => i_clk,

        i_wr_addr    => w_wr_addr,
        i_wr_data    => w_uart_rx_data,
        i_wr_ena     => r_write_to_bram,

        i_rd_addr    => w_rd_addr,
        o_rd_data    => w_char_data,
        i_rd_ena     => r_read_char
    );

END ARCHITECTURE;
