LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY STD;
USE STD.ENV.ALL;

LIBRARY rtl_work;
USE rtl_work.ALL;

ENTITY tb_top IS
END ENTITY tb_top;

ARCHITECTURE TB OF tb_top IS

    CONSTANT C_clk_period     : time      := 40 ns;
    CONSTANT C_uart_baud      : integer   := 115_200;
    CONSTANT C_uart_symbol    : time      := (1000 ms) / C_uart_baud;

    SIGNAL   clk              : std_logic;

    SIGNAL   valid_in         : std_logic;
    SIGNAL   data_in          : std_logic_vector(7 downto 0);
    SIGNAL   idle_out         : std_logic;
    SIGNAL   data_out         : std_logic;

    SIGNAL   received_out       : std_logic_vector(7 downto 0);
    SIGNAL   received_valid_out : std_logic;

BEGIN

    UUT : ENTITY rtl_work.uart_rx
    GENERIC MAP
    (
        g_sys_clk_hz => 25_000_000,
        g_uart_baud  => C_uart_baud
    )
    PORT MAP
    (
        i_clk        => clk,
        i_uart_rx    => data_out,
        o_data       => received_out,
        o_data_valid => received_valid_out
    );

    uart_tx_inst : ENTITY rtl_work.uart_tx
    GENERIC MAP
    (
        g_sys_clk_hz => 25_000_000,
        g_uart_baud  => C_uart_baud
    )
    PORT MAP
    (
        i_clk        => clk,
        i_data       => data_in,
        i_data_valid => valid_in,
        o_idle       => idle_out,
        o_uart_tx    => data_out
    );

    P_generate_clock : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR C_clk_period/2;
        clk <= '1';
        WAIT FOR C_clk_period/2;
    END PROCESS;

    P_main : PROCESS

    BEGIN
        valid_in <= '0';

        data_in <= X"CF";

        WAIT FOR C_clk_period/2;

        REPORT "C_uart_symbol = " & time'IMAGE(C_uart_symbol);

        REPORT "Testbench start";

        WAIT FOR 101 * C_clk_period;

        REPORT "Asserting in data valid";

        valid_in <= '1';

        WAIT FOR C_clk_period;

        REPORT "Deasserting in data valid";
        valid_in <= '0';

        WAIT FOR C_clk_period;

        data_in <= X"25";

        WAIT UNTIL idle_out = '1';

        REPORT "Idle out = '1'";

        WAIT FOR C_clk_period/2;
        WAIT FOR C_clk_period;

        REPORT "Asserting in data valid";

        valid_in <= '1';

        WAIT FOR C_clk_period;

        REPORT "Deasserting in data valid";

        valid_in <= '0';

        WAIT FOR C_clk_period;

        WAIT UNTIL idle_out = '1';

        REPORT "Idle out = '1'";

        WAIT FOR C_clk_period/2;
        WAIT FOR C_clk_period;

        WAIT FOR 100 * C_clk_period;

        REPORT "Testbench end";

        std.env.stop;
        WAIT;

    END PROCESS;

    P_decode_uart : PROCESS
        VARIABLE v_char : std_logic_vector(7 downto 0);
    BEGIN
        WAIT UNTIL falling_edge(data_out);
        WAIT FOR C_uart_symbol/2;
        FOR i IN 0 TO 7 LOOP
            WAIT FOR C_uart_symbol;
            v_char(i) := data_out;
        END LOOP;
        WAIT FOR C_uart_symbol;
        ASSERT (data_out = '1') REPORT "Stop bit not equal to '1'" SEVERITY warning;
        REPORT "Received: " &
                integer'IMAGE(to_integer(unsigned'('0' & v_char(7)))) &
                integer'IMAGE(to_integer(unsigned'('0' & v_char(6)))) &
                integer'IMAGE(to_integer(unsigned'('0' & v_char(5)))) &
                integer'IMAGE(to_integer(unsigned'('0' & v_char(4)))) &
                integer'IMAGE(to_integer(unsigned'('0' & v_char(3)))) &
                integer'IMAGE(to_integer(unsigned'('0' & v_char(2)))) &
                integer'IMAGE(to_integer(unsigned'('0' & v_char(1)))) &
                integer'IMAGE(to_integer(unsigned'('0' & v_char(0)))) &
                ", " &
                character'IMAGE(character'VAL(to_integer(unsigned(v_char))));

    END PROCESS;

END ARCHITECTURE;
