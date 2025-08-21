LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY mdio_master IS
    GENERIC
    (
        g_sys_clk_hz    : positive;
        g_mdc_clk_hz    : positive
    );
    PORT
    (
        i_clk           : IN    std_logic;

        i_phy_addr      : IN    std_logic_vector( 4 downto 0);
        i_reg_addr      : IN    std_logic_vector( 4 downto 0);

        i_wr_data       : IN    std_logic_vector(15 downto 0);
        i_rd_not_wr     : IN    std_logic;
        i_data_valid    : IN    std_logic;

        o_rd_data       :   OUT std_logic_vector(15 downto 0);
        o_rd_data_valid :   OUT std_logic;

        o_idle          :   OUT std_logic;

        o_mdc           :   OUT std_logic;
       io_mdio          : INOUT std_logic
    );
END mdio_master;

ARCHITECTURE RTL OF mdio_master IS

    TYPE     T_state IS (IDLE, WRITE, READ);
    SIGNAL   r_state_cur          : T_state                            := IDLE;
    SIGNAL   w_state_next         : T_state;

    CONSTANT C_clk_cnt_mod        : integer                            := g_sys_clk_hz / g_mdc_clk_hz;
    SIGNAL   r_clk_cnt            : integer RANGE 0 TO C_clk_cnt_mod-1 :=  0;

    CONSTANT C_bit_cnt_mod        : integer                            := 65;
    SIGNAL   r_bit_cnt            : integer RANGE 0 TO C_bit_cnt_mod-1 :=  0;

    SIGNAL   r_data_in            : std_logic_vector(63 downto 0)      := (OTHERS => '0');

    SIGNAL   r_data_out           : std_logic                          := '1';
    SIGNAL   r_out_en             : std_logic                          := '0';

    SIGNAL   r_rd_data            : std_logic_vector(15 downto 0)      := (OTHERS => '0');
    SIGNAL   r_rd_data_valid      : std_logic                          := '0';

    SIGNAL   r_read_not_write     : std_logic                          := '0';

    SIGNAL   r_mdc                : std_logic                          := '0';

BEGIN

    io_mdio         <= r_data_out WHEN r_out_en = '1' ELSE 'Z';
    o_mdc           <= r_mdc;

    o_rd_data       <= r_rd_data;
    o_rd_data_valid <= r_rd_data_valid;

    o_idle          <= '1' WHEN w_state_next = IDLE ELSE '0';


    P_update_state : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_state_cur <= w_state_next;
        END IF;
    END PROCESS;

    P_decide_next_state : PROCESS(r_state_cur,
                                  i_data_valid,
                                  r_clk_cnt,
                                  r_bit_cnt)
    BEGIN

        w_state_next <= r_state_cur;

        CASE r_state_cur IS
            WHEN IDLE =>
                IF (i_data_valid = '1') THEN
                    w_state_next <= WRITE;
                END IF;

            WHEN WRITE =>
                IF (r_bit_cnt = 46 AND r_read_not_write = '1') THEN
                    w_state_next <= READ;
                END IF;
                IF (r_bit_cnt = 64) THEN
                    w_state_next <= IDLE;
                END IF;

            WHEN READ =>
                IF (r_bit_cnt = 63) THEN
                    w_state_next <= IDLE;
                END IF;
            WHEN OTHERS =>
                w_state_next <= IDLE;

        END CASE;

    END PROCESS;

    P_latch_data : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_state_cur = IDLE AND i_data_valid = '1') THEN
                r_read_not_write <= i_rd_not_wr;
                r_data_in <= X"FFFFFFFF" & "01" & i_rd_not_wr & NOT i_rd_not_wr & i_phy_addr & i_reg_addr & "10" & i_wr_data;
            ELSIF (r_state_cur /= IDLE AND r_clk_cnt >= C_clk_cnt_mod-1) THEN
                r_data_in <= r_data_in(r_data_in'HIGH-1 downto r_data_in'LOW) & '0';
            END IF;
        END IF;
    END PROCESS;

    P_output_data : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_data_out <= r_data_in(r_data_in'HIGH);
            IF (r_state_cur = WRITE) THEN
                r_out_en <= '1';
            ELSE
                r_out_en <= '0';
            END IF;
        END IF;
    END PROCESS;

    P_input_data : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_clk_cnt >= C_clk_cnt_mod-1) THEN
                r_rd_data <= r_rd_data(r_rd_data'HIGH-1 downto r_rd_data'LOW) & io_mdio;
            END IF;
            IF (r_state_cur = READ AND w_state_next = IDLE) THEN
                r_rd_data_valid <= '1';
            ELSE
                r_rd_data_valid <= '0';
            END IF;
        END IF;
    END PROCESS;

    P_mdc : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_clk_cnt < C_clk_cnt_mod/2) THEN
                r_mdc <= '0';
            ELSE
                r_mdc <= '1';
            END IF;
        END IF;
    END PROCESS;

    P_bit_cnt : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_state_cur /= IDLE) THEN
                IF (r_clk_cnt >= C_clk_cnt_mod-1) THEN
                    IF (r_bit_cnt < C_bit_cnt_mod-1) THEN
                        r_bit_cnt <= r_bit_cnt + 1;
                    END IF;
                END IF;
            ELSE
                r_bit_cnt <= 0;
            END IF;
        END IF;
    END PROCESS;

    P_mdio_clk : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_state_cur /= IDLE) THEN
                IF (r_clk_cnt < C_clk_cnt_mod-1) THEN
                    r_clk_cnt <= r_clk_cnt + 1;
                ELSE
                    r_clk_cnt <= 0;
                END IF;
            ELSE
                r_clk_cnt <= 0;
            END IF;
        END IF;
    END PROCESS;


END ARCHITECTURE;
