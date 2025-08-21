--------------------------------------------------------------------------------
-- Project:       fpjswis
-- File:          synchronizer_chain.vhd
--
-- Creation date: 2022-05-02
--
-- Author:        FPiorski
-- License:       CERN-OHL-W-2.0
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY synchronizer_chain IS
    GENERIC
    (
        g_len  : positive := 2
    );
    PORT
    (
        i_clk  : IN    std_logic;
        i_data : IN    std_logic;
        o_data :   OUT std_logic
    );
END synchronizer_chain;

ARCHITECTURE RTL OF synchronizer_chain IS

    SIGNAL r_chain : std_logic_vector(g_len-1 downto 0);

BEGIN

    o_data <= r_chain(g_len-1);

    P_shift : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_chain <= r_chain(g_len-2 downto 0) & i_data;
        END IF;
    END PROCESS;

END ARCHITECTURE;
