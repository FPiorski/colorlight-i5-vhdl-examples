LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pattern_generator IS
    GENERIC
    (
        g_sys_clk_hz : integer;
        g_x_active   : integer;
        g_x_fp       : integer;
        g_x_bp       : integer;
        g_x_sync     : integer;
        g_y_active   : integer;
        g_y_fp       : integer;
        g_y_bp       : integer;
        g_y_sync     : integer
    );
    PORT
    (
        i_clk        : IN    std_logic;

        o_led        :   OUT std_logic;
        i_uart_rx    : IN    std_logic;
        o_uart_tx    :   OUT std_logic;

        i_hsync      : IN    std_logic;
        i_vsync      : IN    std_logic;
        i_de         : IN    std_logic;

        i_x          : IN    integer RANGE 0 TO g_x_active + g_x_fp + g_x_bp + g_x_sync-1;
        i_y          : IN    integer RANGE 0 TO g_y_active + g_y_fp + g_y_bp + g_y_sync-1;
        i_frame      : IN    integer;

        o_hsync      :   OUT std_logic;
        o_vsync      :   OUT std_logic;
        o_de         :   OUT std_logic;

        o_r          :   OUT std_logic_vector(7 downto 0);
        o_g          :   OUT std_logic_vector(7 downto 0);
        o_b          :   OUT std_logic_vector(7 downto 0)
    );
END pattern_generator;
