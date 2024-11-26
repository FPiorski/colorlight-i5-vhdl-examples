LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY bram IS
    GENERIC
    (
        g_width          : positive :=  8;
        g_depth_log2     : positive := 10;
        g_reset_val      : integer  :=  0
    );
    PORT
    (
        i_clk            : IN    std_logic;

        i_wr_addr        : IN    std_logic_vector(g_depth_log2-1 downto 0);
        i_wr_data        : IN    std_logic_vector(g_width-1 downto 0);
        i_wr_ena         : IN    std_logic;

        i_rd_addr        : IN    std_logic_vector(g_depth_log2-1 downto 0);
        o_rd_data        :   OUT std_logic_vector(g_width-1 downto 0);
        i_rd_ena         : IN    std_logic
    );
END bram;

ARCHITECTURE RTL OF bram IS

    CONSTANT C_depth    : integer := 2**g_depth_log2;

    TYPE     T_bram_arr IS ARRAY (0 TO C_depth-1) OF std_logic_vector(g_width-1 downto 0);
    SIGNAL   r_bram_arr : T_bram_arr := (OTHERS => std_logic_vector(to_unsigned(g_reset_val, g_width)));

    SIGNAL   r_out_buff : std_logic_vector(g_width-1 downto 0) := (OTHERS => '0');

BEGIN

    o_rd_data <= r_out_buff;

    P_write : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (i_wr_ena = '1') THEN
                r_bram_arr(to_integer(unsigned(i_wr_addr))) <= i_wr_data;
            END IF;
        END IF;
    END PROCESS;

    P_read : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (i_rd_ena = '1') THEN
                r_out_buff <= r_bram_arr(to_integer(unsigned(i_rd_addr)));
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;
