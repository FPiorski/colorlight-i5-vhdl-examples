LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY video_encoder IS
    PORT
    (
        i_clk        : IN    std_logic;
        i_fast_clk   : IN    std_logic;
        i_pll_locked : IN    std_logic;

        i_r          : IN    std_logic_vector(7 downto 0);
        i_g          : IN    std_logic_vector(7 downto 0);
        i_b          : IN    std_logic_vector(7 downto 0);
        i_hsync      : IN    std_logic;
        i_vsync      : IN    std_logic;
        i_de         : IN    std_logic;

        o_r          :   OUT std_logic;
        o_g          :   OUT std_logic;
        o_b          :   OUT std_logic;
        o_c          :   OUT std_logic

    );
END video_encoder;

ARCHITECTURE RTL OF video_encoder IS

    SIGNAL   w_tmds_r           : std_logic_vector(9 downto 0);
    SIGNAL   w_tmds_g           : std_logic_vector(9 downto 0);
    SIGNAL   w_tmds_b           : std_logic_vector(9 downto 0);

    SIGNAL   r_shift_reg_r      : std_logic_vector(9 downto 0) := (OTHERS => '0');
    SIGNAL   r_shift_reg_g      : std_logic_vector(9 downto 0) := (OTHERS => '0');
    SIGNAL   r_shift_reg_b      : std_logic_vector(9 downto 0) := (OTHERS => '0');
    SIGNAL   r_shift_reg_c      : std_logic_vector(9 downto 0) := (OTHERS => '0');

    CONSTANT C_clk_cnt_mod      : integer := 10;
    SIGNAL   r_clk_cnt          : integer RANGE 0 TO C_clk_cnt_mod-1 := 0;

    --This additional register stage helps with timing
    SIGNAL   r_reset_clk_cnt    : std_logic := '0';

BEGIN

    o_r <= r_shift_reg_r(0);
    o_g <= r_shift_reg_g(0);
    o_b <= r_shift_reg_b(0);
    o_c <= r_shift_reg_c(0);

    P_count_clock_cycles : PROCESS(i_fast_clk)
    BEGIN
        IF (rising_edge(i_fast_clk)) THEN
            IF (r_clk_cnt = C_clk_cnt_mod-2) THEN
                r_reset_clk_cnt <= '1';
            ELSE
                r_reset_clk_cnt <= '0';
            END IF;

            IF (r_reset_clk_cnt = '0') THEN
                r_clk_cnt          <= r_clk_cnt + 1;
            ELSE
                r_clk_cnt          <=  0;
            END IF;
        END IF;
    END PROCESS;

    P_shift_registers : PROCESS(i_fast_clk)
    BEGIN
        IF (rising_edge(i_fast_clk)) THEN
            IF (r_reset_clk_cnt = '1') THEN
                r_shift_reg_r <= w_tmds_r;
                r_shift_reg_g <= w_tmds_g;
                r_shift_reg_b <= w_tmds_b;
                r_shift_reg_c <= "0000011111";
            ELSE
                r_shift_reg_r <= "0" & r_shift_reg_r(9 downto 1);
                r_shift_reg_g <= "0" & r_shift_reg_g(9 downto 1);
                r_shift_reg_b <= "0" & r_shift_reg_b(9 downto 1);
                r_shift_reg_c <= "0" & r_shift_reg_c(9 downto 1);
            END IF;
        END IF;
    END PROCESS;

    --hsync and vsync get sent using C0 and C1 control bits on channel 0 (blue)
    tmds_encoder_red : ENTITY work.tmds_encoder
    PORT MAP
    (
        i_clk        => i_clk,
        i_data       => i_r,
        i_de         => i_de,
        i_control    => "00",
        o_data       => w_tmds_r
    );
    tmds_encoder_green : ENTITY work.tmds_encoder
    PORT MAP
    (
        i_clk        => i_clk,
        i_data       => i_g,
        i_de         => i_de,
        i_control    => "00",
        o_data       => w_tmds_g
    );
    tmds_encoder_blue : ENTITY work.tmds_encoder
    PORT MAP
    (
        i_clk        => i_clk,
        i_data       => i_b,
        i_de         => i_de,
        i_control(1) => i_vsync,
        i_control(0) => i_hsync,
        o_data       => w_tmds_b
    );

END ARCHITECTURE;
