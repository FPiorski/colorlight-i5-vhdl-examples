LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pseudo_diff_outb IS
    PORT
    (
        i_clk    : IN    std_logic;

        i_data   : IN    std_logic_vector(3 downto 0);

        o_data_p :   OUT std_logic_vector(3 downto 0);
        o_data_n :   OUT std_logic_vector(3 downto 0)
    );
END pseudo_diff_outb;

ARCHITECTURE RTL OF pseudo_diff_outb IS

    SIGNAL r_buf_p : std_logic_vector(3 downto 0) := (OTHERS => '0');
    SIGNAL r_buf_n : std_logic_vector(3 downto 0) := (OTHERS => '0');

BEGIN

    o_data_p <= r_buf_p;
    o_data_n <= r_buf_n;

    P_register_outputs : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_buf_p <=     i_data;
            r_buf_n <= NOT i_data;
        END IF;
    END PROCESS;

END ARCHITECTURE;
