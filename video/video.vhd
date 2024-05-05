LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY video IS
    GENERIC
    (
        g_sys_clk_hz : integer
    );
    PORT
    (
        i_clk        : IN    std_logic;

        o_led        :   OUT std_logic;

        i_uart_rx    : IN    std_logic;
        o_uart_tx    :   OUT std_logic;

        o_video_r_dp :   OUT std_logic;
        o_video_r_dn :   OUT std_logic;
        o_video_g_dp :   OUT std_logic;
        o_video_g_dn :   OUT std_logic;
        o_video_b_dp :   OUT std_logic;
        o_video_b_dn :   OUT std_logic;
        o_video_c_dp :   OUT std_logic;
        o_video_c_dn :   OUT std_logic
    );
END video;

ARCHITECTURE RTL OF video IS

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
    SIGNAL   r_frame      : integer := 0;

    SIGNAL   w_red        : std_logic_vector(7 downto 0);
    SIGNAL   w_green      : std_logic_vector(7 downto 0);
    SIGNAL   w_blue       : std_logic_vector(7 downto 0);

    SIGNAL   w_hsync      : std_logic;
    SIGNAL   w_vsync      : std_logic;
    SIGNAL   w_de         : std_logic;

BEGIN

    P_counters_and_syncs : PROCESS(w_pixel_clk)
    BEGIN
        IF (rising_edge(w_pixel_clk)) THEN
            IF (r_x < C_x_mod-1) THEN
                r_x <= r_x + 1;
            ELSE
                r_x <= 0;
                IF (r_y < C_y_mod-1) THEN
                    r_y     <= r_y + 1;
                ELSE
                    r_y     <= 0;
                    r_frame <= r_frame + 1;
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

    pattern_generator_inst : ENTITY work.pattern_generator
    GENERIC MAP
    (
        g_sys_clk_hz => g_sys_clk_hz,
        g_x_active   => C_x_active,
        g_x_fp       => C_x_fp,
        g_x_bp       => C_x_bp,
        g_x_sync     => C_x_sync,
        g_y_active   => C_y_active,
        g_y_fp       => C_y_fp,
        g_y_bp       => C_y_bp,
        g_y_sync     => C_y_sync
    )
    PORT MAP
    (
        i_clk        => w_pixel_clk,

        o_led        => o_led,
        i_uart_rx    => i_uart_rx,
        o_uart_tx    => o_uart_tx,

        i_hsync      => r_hsync,
        i_vsync      => r_vsync,
        i_de         => r_de,

        i_x          => r_x,
        i_y          => r_y,
        i_frame      => r_frame,

        o_hsync      => w_hsync,
        o_vsync      => w_vsync,
        o_de         => w_de,

        o_r          => w_red,
        o_g          => w_green,
        o_b          => w_blue
    );

    video_encoder_inst : ENTITY work.video_encoder
    PORT MAP
    (
        i_clk        => w_pixel_clk,
        i_fast_clk   => w_tmds_clk,
        i_pll_locked => w_pll_locked,

        i_r          => w_red,
        i_g          => w_green,
        i_b          => w_blue,
        i_hsync      => w_hsync,
        i_vsync      => w_vsync,
        i_de         => w_de,

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
