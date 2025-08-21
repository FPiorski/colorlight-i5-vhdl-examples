ARCHITECTURE rxtest OF eth IS

    SIGNAL   w_mdio_rd_data          : std_logic_vector(15 downto 0);
    SIGNAL   w_mdio_rd_data_valid    : std_logic;

    SIGNAL   r_led                   : std_logic := '0';

    SIGNAL   w_uart_idle             : std_logic;

    SIGNAL   w_fifo_wr_data          : std_logic_vector( 7 downto 0);
    SIGNAL   w_fifo_wr_ena           : std_logic;
    SIGNAL   w_fifo_rd_data          : std_logic_vector( 7 downto 0);
    SIGNAL   w_fifo_rd_ena           : std_logic;
    SIGNAL   w_fifo_empty            : std_logic;
    SIGNAL   w_fifo_almost_full      : std_logic;
    SIGNAL   w_fifo_empty_sync       : std_logic;
    SIGNAL   w_fifo_almost_full_sync : std_logic;

    SIGNAL   w_not_fifo_empty_sync   : std_logic;

BEGIN

    o_eth1_ledr <= r_led;
    o_eth1_ledl <= r_led;

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

    w_fifo_rd_ena         <= '1' WHEN (w_uart_idle = '1' AND w_fifo_empty_sync = '0') ELSE '0';
    w_not_fifo_empty_sync <= NOT w_fifo_empty_sync;

    uart_tx_inst : ENTITY work.uart_tx
    GENERIC MAP
    (
        g_sys_clk_hz => g_sys_clk_hz,
        g_uart_baud  => g_uart_baud
    )
    PORT MAP
    (
        i_clk        => i_clk,
        i_data       => w_fifo_rd_data,
        --i_data       => w_mdio_rd_data(15 downto 8),
        --i_data       => w_mdio_rd_data(7 downto 0),
        i_data_valid => w_not_fifo_empty_sync,
        o_idle       => w_uart_idle,
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

    rgmii_rx_inst : ENTITY work.rgmii_rx
    PORT MAP
    (
        i_clk          => i_eth1_rx_clk,

        i_rx_ctl       => i_eth1_rx_ctl,
        i_rx_data      => i_eth1_rx_data,

        o_fifo_wr_data => w_fifo_wr_data,
        o_fifo_wr_ena  => w_fifo_wr_ena
    );

    fifo_inst : ENTITY work.fifo
    GENERIC MAP
    (
        g_width          =>  8,
        g_depth_log2     => 11,
        g_empty_headroom => 16,
        g_full_headroom  => 16
    )
    PORT MAP
    (
        i_wr_clk         => i_eth1_rx_clk,
        i_wr_data        => w_fifo_wr_data,
        i_wr_ena         => w_fifo_wr_ena,

        i_rd_clk         => i_clk,
        o_rd_data        => w_fifo_rd_data,
        i_rd_ena         => w_fifo_rd_ena,

        o_almost_empty   => OPEN,
        o_empty          => w_fifo_empty,
        o_almost_full    => w_fifo_almost_full
    );

    empty_synchronizer_chain : ENTITY work.synchronizer_chain
    GENERIC MAP
    (
        g_len  => 4
    )
    PORT MAP
    (
        i_clk  => i_clk,
        i_data => w_fifo_empty,
        o_data => w_fifo_empty_sync
    );

    almost_full_synchronizer_chain : ENTITY work.synchronizer_chain
    GENERIC MAP
    (
        g_len  => 4
    )
    PORT MAP
    (
        i_clk  => i_eth1_rx_clk,
        i_data => w_fifo_almost_full,
        o_data => w_fifo_almost_full_sync
    );

END ARCHITECTURE;
