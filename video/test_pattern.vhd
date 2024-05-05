ARCHITECTURE blank OF video IS

    SIGNAL   r_hsync      : std_logic := '0';
    SIGNAL   r_vsync      : std_logic := '0';
    SIGNAL   r_de         : std_logic := '0';

    SIGNAL   w_tmds_clk   : std_logic;
    SIGNAL   w_pixel_clk  : std_logic;
    SIGNAL   w_pll_locked : std_logic;

    SIGNAL   w_r          : std_logic;
    SIGNAL   w_g          : std_logic;
    SIGNAL   w_b          : std_logic;
    SIGNAL   w_c          : std_logic;

    CONSTANT C_x_active   : integer := 640;
    CONSTANT C_x_fp       : integer := 16;
    CONSTANT C_x_bp       : integer := 48;
    CONSTANT C_x_sync     : integer := 96;
    CONSTANT C_y_active   : integer := 480;
    CONSTANT C_y_fp       : integer := 10;
    CONSTANT C_y_bp       : integer := 33;
    CONSTANT C_y_sync     : integer := 2;

    CONSTANT C_x_mod      : integer := C_x_active + C_x_fp + C_x_bp + C_x_sync;
    SIGNAL   r_x          : integer RANGE 0 TO C_x_mod-1 := 0;
    CONSTANT C_y_mod      : integer := C_y_active + C_y_fp + C_y_bp + C_y_sync;
    SIGNAL   r_y          : integer RANGE 0 TO C_y_mod-1 := 0;
    SIGNAL   r_t          : integer := 0;

    SIGNAL   r_red        : std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL   r_green      : std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL   r_blue       : std_logic_vector(7 downto 0) := (OTHERS => '0');

BEGIN

    --Unused
    o_uart_tx <= '1';
    o_led     <= '0';

    P_counters_and_syncs : PROCESS(w_pixel_clk)
    BEGIN
        IF (rising_edge(w_pixel_clk)) THEN
            IF (r_x < C_x_mod-1) THEN
                r_x <= r_x + 1;
            ELSE
                r_x <= 0;
                IF (r_y < C_y_mod-1) THEN
                    r_y <= r_y + 1;
                ELSE
                    r_y <= 0;
                    r_t <= r_t + 1;
                END IF;
            END IF;
            IF (r_x >= C_x_active + C_x_fp AND r_x < C_x_active + C_x_fp + C_x_sync) THEN
                r_hsync <= '1';
            ELSE
                r_hsync <= '0';
            END IF;
            IF (r_y >= C_y_active + C_y_fp AND r_x < C_y_active + C_y_fp + C_y_sync) THEN
                r_vsync <= '1';
            ELSE
                r_vsync <= '0';
            END IF;
            IF (r_x <  C_x_active AND r_y < C_y_active) THEN
                r_de <= '1';
            ELSE
                r_de <= '0';
            END IF;
        END IF;
    END PROCESS;

    P_generate_pattern : PROCESS(w_pixel_clk)
    BEGIN
        IF (rising_edge(w_pixel_clk)) THEN
            r_red   <= std_logic_vector(to_unsigned(r_x + r_t, 8));
            r_green <= std_logic_vector(to_unsigned(r_y + 2*r_t, 8));
            r_blue  <= std_logic_vector(to_unsigned(r_x + r_t/4, 8) XOR to_unsigned(r_y, 8));
        END IF;
    END PROCESS;

    video_encoder_inst : ENTITY work.video_encoder
    PORT MAP
    (
        i_clk        => w_pixel_clk,
        i_fast_clk   => w_tmds_clk,
        i_pll_locked => w_pll_locked,

        i_r          => r_red,
        i_g          => r_green,
        i_b          => r_blue,
        i_hsync      => r_hsync,
        i_vsync      => r_vsync,
        i_de         => r_de,

        o_r          => w_r,
        o_g          => w_g,
        o_b          => w_b,
        o_c          => w_c
    );

    pseudo_diff_outb_inst : ENTITY work.pseudo_diff_outb
    PORT MAP
    (
        i_clk       => w_tmds_clk,

        i_data(3)   => w_c,
        i_data(2)   => w_b,
        i_data(1)   => w_g,
        i_data(0)   => w_r,

        o_data_p(3) => o_video_c_dp,
        o_data_p(2) => o_video_b_dp,
        o_data_p(1) => o_video_g_dp,
        o_data_p(0) => o_video_r_dp,

        o_data_n(3) => o_video_c_dn,
        o_data_n(2) => o_video_b_dn,
        o_data_n(1) => o_video_g_dn,
        o_data_n(0) => o_video_r_dn
    );

    --25 MHz * 10 = 250 MHz
    pll_inst : ENTITY work.pll
    PORT MAP
    (
        i_clk        => i_clk,
        o_clk_1      => w_tmds_clk,
        o_clk_2      => w_pixel_clk,
        o_pll_locked => w_pll_locked
    );

END ARCHITECTURE;
