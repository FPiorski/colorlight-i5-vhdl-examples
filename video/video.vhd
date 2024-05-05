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
