LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY led IS
    GENERIC
    (
        g_sys_clk_hz : integer
    );
    PORT
    (
        i_clk        : IN    std_logic;

        o_led        :   OUT std_logic
    );
END led;
