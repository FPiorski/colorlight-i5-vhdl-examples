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

    CONSTANT C_clk_period  : time      := 40 ns;
    CONSTANT C_mcd_clk     : integer   := 1_000_000;

    SIGNAL   clk           : std_logic;

    SIGNAL   phy_addr      : std_logic_vector( 4 downto 0);
    SIGNAL   reg_addr      : std_logic_vector( 4 downto 0);

    SIGNAL   wr_data       : std_logic_vector(15 downto 0);
    SIGNAL   rd_not_wr     : std_logic;
    SIGNAL   valid_in      : std_logic;

    SIGNAL   rd_data       : std_logic_vector(15 downto 0);
    SIGNAL   valid_out     : std_logic;

    SIGNAL   idle_out      : std_logic;

    SIGNAL   mdc           : std_logic;
    SIGNAL   mdio          : std_logic;

BEGIN

    UUT : ENTITY rtl_work.mdio_master
        GENERIC MAP
        (
            g_sys_clk_hz    => 25_000_000,
            g_mdc_clk_hz    => C_mcd_clk
        )
        PORT MAP
        (
            i_clk           => clk,

            i_phy_addr      => phy_addr,
            i_reg_addr      => reg_addr,
            i_wr_data       => wr_data,
            i_rd_not_wr     => rd_not_wr,
            i_data_valid    => valid_in,

            o_rd_data       => rd_data,
            o_rd_data_valid => valid_out,

            o_idle          => idle_out,

            o_mdc           => mdc,
            io_mdio         => mdio
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

        WAIT FOR C_clk_period/2;

        REPORT "Testbench start";

        phy_addr    <= "01011";
        reg_addr    <= "11000";
        wr_data     <= "1001000000001111";
        rd_not_wr   <= '0';
        valid_in    <= '0';

        WAIT FOR 101 * C_clk_period;

        REPORT "Asserting in data valid";

        valid_in <= '1';

        WAIT FOR C_clk_period;

        REPORT "Deasserting in data valid";
        valid_in <= '0';

        WAIT FOR C_clk_period;

        phy_addr    <= "01011";
        reg_addr    <= "11000";
        wr_data     <= "1001000000001111";
        rd_not_wr   <= '1';
        valid_in    <= '0';

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

END ARCHITECTURE;
