ARCHITECTURE mdio OF eth IS

    SIGNAL   w_mdio_rd_data       : std_logic_vector(15 downto 0);
    SIGNAL   w_mdio_rd_data_valid : std_logic;

    SIGNAL   r_led                : std_logic := '0';

BEGIN

    o_eth1_ledr <= r_led;
    o_eth1_ledl <= r_led;

    o_eth1_tx_clk  <= 'Z';
    o_eth1_tx_ctl  <= 'Z';
    o_eth1_tx_data <= 'Z';

    --uart_rx_inst : ENTITY work.uart_rx
    --GENERIC MAP
    --(
    --    g_sys_clk_hz => g_sys_clk_hz,
    --    g_uart_baud  => g_uart_baud
    --)
    --PORT MAP
    --(
    --    i_clk        => i_clk,

    --    i_uart_rx    => i_uart_rx,

    --    o_data       => w_received,
    --    o_data_valid => w_received_valid
    --);

    uart_tx_inst : ENTITY work.uart_tx
    GENERIC MAP
    (
        g_sys_clk_hz => g_sys_clk_hz,
        g_uart_baud  => g_uart_baud
    )
    PORT MAP
    (
        i_clk        => i_clk,
        i_data       => w_mdio_rd_data(15 downto 8),
        --i_data       => w_mdio_rd_data(7 downto 0),
        i_data_valid => w_mdio_rd_data_valid,
        o_idle       => OPEN,
        o_uart_tx    => o_uart_tx
    );

    P_drive_led : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (w_mdio_rd_data_valid = '1') THEN
                r_led <= w_mdio_rd_data(2);
            END IF;
        END IF;
    END PROCESS;

    mdio_master_inst : ENTITY work.mdio_master
    GENERIC MAP
    (
        g_sys_clk_hz    => g_sys_clk_hz,
        g_mdc_clk_hz    => 1_000_000
    )
    PORT MAP
    (
        i_clk           => i_clk,

        i_phy_addr      => "00001",
        i_reg_addr      => "00001",

        i_wr_data       => (OTHERS => '0'),
        i_rd_not_wr     => '1',
        i_data_valid    => '1',

        o_rd_data       => w_mdio_rd_data,
        o_rd_data_valid => w_mdio_rd_data_valid,

        o_idle          => OPEN,

       io_mdio          => io_eth_mdio,
        o_mdc           => o_eth_mdc
    );

END ARCHITECTURE;
