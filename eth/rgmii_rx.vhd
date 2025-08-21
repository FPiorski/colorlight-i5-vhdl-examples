LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY rgmii_rx IS
    PORT
    (
        i_clk           : IN    std_logic;

        i_rx_ctl        : IN    std_logic;
        i_rx_data       : IN    std_logic_vector(3 downto 0);

        o_fifo_wr_data  :   OUT std_logic_vector(7 downto 0);
        o_fifo_wr_ena   :   OUT std_logic
    );
END rgmii_rx;

ARCHITECTURE RTL OF rgmii_rx IS

    COMPONENT IDDRX1F IS
        GENERIC
        (
            GSR  : string := "ENABLED"
        );
        PORT
        (
            D    : IN    std_logic;
            SCLK : IN    std_logic;
            RST  : IN    std_logic;
            Q0   :   OUT std_logic;
            Q1   :   OUT std_logic
        );
    END COMPONENT;

BEGIN

    iddr_tx_ctl : IDDRX1F
    PORT MAP
    (
        D    => i_rx_ctl,
        SCLK => i_clk,
        RST  => '0',
        Q0   => o_fifo_wr_ena,
        Q1   => OPEN
    );

    --for some reason, TXD[3] is the least signifficant bit in a nibble,
    -- so this confusing swap happens here and only here,
    -- the entire rest of the codebase is sane.
    iddr_tx_data_3 : iDDRX1F
    PORT MAP
    (
        D    => i_rx_data(3),
        SCLK => i_clk,
        RST  => '0',
        Q0   => o_fifo_wr_data(0),
        Q1   => o_fifo_wr_data(4)
    );

    iddr_tx_data_2 : iDDRX1F
    PORT MAP
    (
        D    => i_rx_data(2),
        SCLK => i_clk,
        RST  => '0',
        Q0   => o_fifo_wr_data(1),
        Q1   => o_fifo_wr_data(5)
    );

    iddr_tx_data_1 : iDDRX1F
    PORT MAP
    (
        D    => i_rx_data(1),
        SCLK => i_clk,
        RST  => '0',
        Q0   => o_fifo_wr_data(2),
        Q1   => o_fifo_wr_data(6)
    );

    iddr_tx_data_0 : iDDRX1F
    PORT MAP
    (
        D    => i_rx_data(0),
        SCLK => i_clk,
        RST  => '0',
        Q0   => o_fifo_wr_data(3),
        Q1   => o_fifo_wr_data(7)
    );

END ARCHITECTURE;
