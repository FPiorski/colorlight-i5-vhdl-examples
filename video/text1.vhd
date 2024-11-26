ARCHITECTURE text0 OF pattern_generator IS

    CONSTANT C_debug              : integer := 0;

    SIGNAL   r_red                : std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL   r_green              : std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL   r_blue               : std_logic_vector(7 downto 0) := (OTHERS => '0');

    --Since syncs and de are derived synchronously one level up,
    -- they are one cycle behind i_x, i_y and i_t. That's good,
    -- since with anything more than a simple test pattern we take a couple
    -- of cycles to calculate color values anyway, just make sure to set
    -- this constant to one less than the number of cycles it will take to
    -- generate color values datato sure everything stays in sync
    CONSTANT C_delay              : natural :=  4;
    SIGNAL   r_hsync              : std_logic_vector(C_delay-1 downto 0) := (OTHERS => '0');
    SIGNAL   r_vsync              : std_logic_vector(C_delay-1 downto 0) := (OTHERS => '0');
    SIGNAL   r_de                 : std_logic_vector(C_delay-1 downto 0) := (OTHERS => '0');

    SIGNAL   w_uart_rx_data       : std_logic_vector(7 downto 0);
    SIGNAL   w_uart_rx_data_valid : std_logic;

    FUNCTION f_log2_ceil(i_val : positive) RETURN natural IS
        VARIABLE i : natural := 0;
    BEGIN
        WHILE ((2**i < i_val) AND i < 31) LOOP i := i + 1; END LOOP;
        RETURN i;
    END FUNCTION;

    CONSTANT C_char_w             : integer := 8;
    CONSTANT C_char_h             : integer := 8;
    CONSTANT C_char_num_log2      : integer := f_log2_ceil((g_x_active/C_char_h)*(g_y_active/C_char_w));

    --Cursor
    CONSTANT C_ax_mod             : integer := g_x_active/C_char_w;
    SIGNAL   r_ax                 : integer RANGE 0 TO C_ax_mod-1 := 0;
    CONSTANT C_ay_mod             : integer := g_y_active/C_char_h;
    SIGNAL   r_ay                 : integer RANGE 0 TO C_ay_mod-1 := 0;

    --Character
    CONSTANT C_cx_mod             : integer := g_x_active/C_char_w;
    SIGNAL   r_cx                 : integer RANGE 0 TO C_cx_mod-1 := 0;
    CONSTANT C_cy_mod             : integer := g_y_active/C_char_h;
    SIGNAL   r_cy                 : integer RANGE 0 TO C_cy_mod-1 := 0;

    SIGNAL   r_cx_prev            : integer RANGE 0 TO C_cx_mod-1 := 0;
    SIGNAL   r_cx_prev_prev       : integer RANGE 0 TO C_cx_mod-1 := 0;

    SIGNAL   r_read_char          : std_logic := '0';
    SIGNAL   r_read_char_prev     : std_logic := '0';
    SIGNAL   r_read_char_prev_prev: std_logic := '0';

    SIGNAL   w_char_data          : std_logic_vector(7 downto 0);

    SIGNAL   r_uart_rx_data       : std_logic_vector(7 downto 0)  := (OTHERS => '0');
    SIGNAL   r_uart_rx_data_prev  : std_logic_vector(7 downto 0)  := (OTHERS => '0');

    SIGNAL   r_write_to_bram      : std_logic := '0';

    SIGNAL   r_wr_addr            : std_logic_vector(C_char_num_log2-1 downto 0) := (OTHERS => '0');
    SIGNAL   r_rd_addr            : std_logic_vector(C_char_num_log2-1 downto 0) := (OTHERS => '0');

    --ASCII, so just 256 codes, sorry, no unicode, tee-hee
    CONSTANT C_code_num           : integer := 256;
    CONSTANT C_cram_depth_log2    : integer := f_log2_ceil(C_code_num * C_char_h);

    SIGNAL   r_cram_rd_addr       : std_logic_vector(C_cram_depth_log2-1 downto 0) := (OTHERS => '0');
    SIGNAL   w_cram_rd_data       : std_logic_vector(         C_char_w-1 downto 0);

    SIGNAL   r_px_cnt             : integer RANGE 0 TO C_char_w-1 := C_char_w-1;

BEGIN

    --Unused
    o_uart_tx <= '1';
    o_led     <= '0';

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
                    IF (w_uart_rx_data = X"0A") THEN
                        IF (r_ay < C_ay_mod-1) THEN
                            r_ay <= r_ay + 1;
                        ELSE
                            r_ay <= 0;
                        END IF;
                    ELSIF (w_uart_rx_data = X"0D") THEN
                        r_ax <= 0;
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
        END IF;
    END PROCESS;

    P_generate_pattern : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_read_char      <= '0';
            r_read_char_prev <= r_read_char;
            r_read_char_prev_prev <= r_read_char_prev;
            r_cx_prev        <= r_cx;
            r_cx_prev_prev   <= r_cx_prev;
            IF (r_read_char_prev_prev = '1') THEN
                r_px_cnt <= C_char_w-1;
            ELSE
                IF (r_px_cnt > 0) THEN
                    r_px_cnt <= r_px_cnt-1;
                END IF;
            END IF;
            IF (i_x < g_x_active AND i_y < g_y_active) THEN
                r_cx <= i_x/C_char_w;
                r_cy <= i_y/C_char_h;
                IF (i_x REM C_char_w = 0) THEN
                    r_read_char <= '1';
                END IF;
                --Techincally, I should use i_y from a few cycles earlier, but since
                -- the active region starts at 0 and syncs and porches at all at the end,
                -- that would be equal to i_y anyway
                r_cram_rd_addr <= std_logic_vector(
                                   to_unsigned(
                                    to_integer(unsigned(w_char_data))*C_char_h + (i_y REM C_char_h),
                                   r_cram_rd_addr'LENGTH));
            END IF;
            IF (C_debug /= 0) THEN
                IF (r_px_cnt = C_char_w-1) THEN
                    r_red   <= X"FF";
                ELSE
                    r_red   <= (OTHERS => w_cram_rd_data(r_px_cnt));
                END IF;
                IF (r_cx_prev_prev < 8) THEN
                    r_green <= (OTHERS => r_uart_rx_data(r_cx_prev_prev));
                ELSE
                    r_green <= (OTHERS => '0');
                END IF;
                r_blue  <= r_cram_rd_addr(7 downto 0);
            ELSE
                r_red   <= (OTHERS => w_cram_rd_data(r_px_cnt));
                r_green <= (OTHERS => w_cram_rd_data(r_px_cnt));
                r_blue  <= (OTHERS => w_cram_rd_data(r_px_cnt));
            END IF;
        END IF;
    END PROCESS;

    --Calculating addresses like that takes one cycle longer than just going with
    -- std_logic_vector(to_unsigned(r_ax, 7) & to_unsigned(r_ay, 6)) like in text0.vhd.
    -- I could also just forgo r_ax and r_ay all together, but I might want to use them
    -- for something later, plus it was a nice exercise in getting all the delays right
    -- before adding the character pixel ROM
    P_calculate_rw_addresses : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_rd_addr <= std_logic_vector(to_unsigned(C_cx_mod*r_cy+r_cx, C_char_num_log2));
            r_wr_addr <= std_logic_vector(to_unsigned(C_cx_mod*r_ay+r_ax, C_char_num_log2));
        END IF;
    END PROCESS;

    G_gen_delay_pos : IF (C_delay > 0) GENERATE
        o_hsync   <= r_hsync(0);
        o_vsync   <= r_vsync(0);
        o_de      <= r_de(0);
        P_delay_syncs : PROCESS(i_clk)
        BEGIN
            IF (rising_edge(i_clk)) THEN
                --Interesting, ghdl doesn't seem to mind C_delay=1 and interprets (0 downto 1) as nothing?
                r_hsync <= i_hsync & r_hsync(C_delay-1 downto 1);
                r_vsync <= i_vsync & r_vsync(C_delay-1 downto 1);
                r_de    <= i_de    &    r_de(C_delay-1 downto 1);
            END IF;
        END PROCESS;
    END GENERATE;
    G_gen_delay_zero : IF (C_delay = 0) GENERATE
        o_hsync   <= i_hsync;
        o_vsync   <= i_vsync;
        o_de      <= i_de;
    END GENERATE;

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

    bram_inst : ENTITY work.bram
    GENERIC MAP
    (
        g_width      => 8,
        g_depth_log2 => C_char_num_log2,
        g_reset_val  => 32
    )
    PORT MAP
    (
        i_clk        => i_clk,

        i_wr_addr    => r_wr_addr,
        i_wr_data    => w_uart_rx_data,
        i_wr_ena     => r_write_to_bram,

        i_rd_addr    => r_rd_addr,
        o_rd_data    => w_char_data,
        i_rd_ena     => r_read_char_prev
    );

    character_ram_inst : ENTITY work.character_ram
    GENERIC MAP
    (
        g_depth_log2 => C_cram_depth_log2,
        g_char_w     => C_char_w,
        g_char_h     => C_char_h
    )
    PORT MAP
    (
        i_clk        => i_clk,

        i_wr_addr    => (OTHERS => '0'),
        i_wr_data    => (OTHERS => '0'),
        i_wr_ena     => '0',
        --i_wr_addr    => r_cram_wr_addr,
        --i_wr_data    => r_cram_wr_data,
        --i_wr_ena     => r_cram_wr_ena,

        i_rd_addr    => r_cram_rd_addr,
        o_rd_data    => w_cram_rd_data
    );

END ARCHITECTURE;
