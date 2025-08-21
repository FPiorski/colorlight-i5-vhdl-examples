LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY rgmii_tx_fixed IS
    PORT
    (
        i_clk           : IN    std_logic;

        o_eth1_tx_clk   :   OUT std_logic;
        o_eth1_tx_ctl   :   OUT std_logic;
        o_eth1_tx_data  :   OUT std_logic_vector(3 downto 0)
    );
END rgmii_tx_fixed;

ARCHITECTURE RTL OF rgmii_tx_fixed IS

    CONSTANT C_rgmii_clk_hz : positive := 125_000_000;
    CONSTANT C_idle_cnt_mod : positive := C_rgmii_clk_hz * 1; --1s
    SIGNAL   r_idle_cnt     : integer RANGE 0 TO C_idle_cnt_mod-1 := 0;

    TYPE     T_packet_arr IS ARRAY (integer RANGE <>) OF std_logic_vector(7 downto 0);
    CONSTANT C_packet_arr : T_packet_arr :=
    (
        "01010101", "01010101", "01010101", "01010101", "01010101", "01010101", "01010101", --preamble
        "11010101", --start frame delimeter
        X"00", X"E0", X"4C", X"39", X"7D", X"96", --destination MAC address
        X"B9", X"BA", X"ED", X"A5", X"7B", X"2B", --source MAC address
        X"00", X"2A", --Ethertype
        std_logic_vector(to_unsigned(character'POS('C'), 8)), std_logic_vector(to_unsigned(character'POS('o'), 8)), std_logic_vector(to_unsigned(character'POS('s'), 8)),
        std_logic_vector(to_unsigned(character'POS(' '), 8)), std_logic_vector(to_unsigned(character'POS('s'), 8)), std_logic_vector(to_unsigned(character'POS('i'), 8)),
        std_logic_vector(to_unsigned(character'POS('e'), 8)), std_logic_vector(to_unsigned(character'POS(' '), 8)), std_logic_vector(to_unsigned(character'POS('p'), 8)),
        std_logic_vector(to_unsigned(character'POS('o'), 8)), std_logic_vector(to_unsigned(character'POS('p'), 8)), std_logic_vector(to_unsigned(character'POS('s'), 8)),
        std_logic_vector(to_unsigned(character'POS('u'), 8)), std_logic_vector(to_unsigned(character'POS('l'), 8)), std_logic_vector(to_unsigned(character'POS('o'), 8)),
        std_logic_vector(to_unsigned(character'POS(' '), 8)), std_logic_vector(to_unsigned(character'POS('i'), 8)), std_logic_vector(to_unsigned(character'POS(' '), 8)),
        std_logic_vector(to_unsigned(character'POS('n'), 8)), std_logic_vector(to_unsigned(character'POS('i'), 8)), std_logic_vector(to_unsigned(character'POS('e'), 8)),
        std_logic_vector(to_unsigned(character'POS(' '), 8)), std_logic_vector(to_unsigned(character'POS('b'), 8)), std_logic_vector(to_unsigned(character'POS('y'), 8)),
        std_logic_vector(to_unsigned(character'POS('l'), 8)), std_logic_vector(to_unsigned(character'POS('o'), 8)), std_logic_vector(to_unsigned(character'POS(' '), 8)),
        std_logic_vector(to_unsigned(character'POS('m'), 8)), std_logic_vector(to_unsigned(character'POS('n'), 8)), std_logic_vector(to_unsigned(character'POS('i'), 8)),
        std_logic_vector(to_unsigned(character'POS('e'), 8)), std_logic_vector(to_unsigned(character'POS(' '), 8)), std_logic_vector(to_unsigned(character'POS('s'), 8)),
        std_logic_vector(to_unsigned(character'POS('l'), 8)), std_logic_vector(to_unsigned(character'POS('y'), 8)), std_logic_vector(to_unsigned(character'POS('c'), 8)),
        std_logic_vector(to_unsigned(character'POS('h'), 8)), std_logic_vector(to_unsigned(character'POS('a'), 8)), std_logic_vector(to_unsigned(character'POS('c'), 8)),
        std_logic_vector(to_unsigned(character'POS('.'), 8)), std_logic_vector(to_unsigned(character'POS('.'), 8)), std_logic_vector(to_unsigned(character'POS('.'), 8)),
        X"82", X"2B", X"03", X"84", --FCS
        X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00", X"00" --interpacket gap
    );

    CONSTANT C_byte_cnt_mod : integer := C_packet_arr'LENGTH;
    SIGNAL   r_byte_cnt     : integer RANGE 0 TO C_byte_cnt_mod-1 :=  0;

    SIGNAL   r_tx_data    : std_logic_vector(7 downto 0);
    SIGNAL   r_tx_enable  : std_logic;

    COMPONENT ODDRX1F IS
        GENERIC
        (
            GSR  : string := "ENABLED"
        );
        PORT
        (
            SCLK : IN    std_logic;
            RST  : IN    std_logic;
            D0   : IN    std_logic;
            D1   : IN    std_logic;
            Q    :   OUT std_logic
        );
    END COMPONENT;

BEGIN

    ASSERT (1 = 0) REPORT "C_byte_cnt_mod = " & integer'IMAGE(C_byte_cnt_mod) SEVERITY note;

    P_byte_counter_and_tx_enable : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN

            r_tx_data <= C_packet_arr(r_byte_cnt);

            r_tx_enable <= '0';

            IF (r_byte_cnt /= 0 OR r_idle_cnt >= C_idle_cnt_mod-1) THEN

                r_tx_enable <= '1';

                IF (r_byte_cnt < C_byte_cnt_mod-1) THEN
                    r_byte_cnt <= r_byte_cnt + 1;
                ELSE
                    r_byte_cnt <= 0;
                END IF;

            END IF;

        END IF;
    END PROCESS;

    P_idle_counter : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_idle_cnt < C_idle_cnt_mod-1) THEN
                r_idle_cnt <= r_idle_cnt + 1;
            ELSE
                r_idle_cnt <= 0;
            END IF;
        END IF;
    END PROCESS;

    oddr_tx_clk : ODDRX1F
    PORT MAP
    (
        SCLK => i_clk,
        RST  => '0',
        D0   => '1',
        D1   => '0',
        Q    => o_eth1_tx_clk
    );

    oddr_tx_ctl : ODDRX1F
    PORT MAP
    (
        SCLK => i_clk,
        RST  => '0',
        D0   => r_tx_enable,
        D1   => r_tx_enable,
        Q    => o_eth1_tx_ctl
    );

    --for some reason, TXD[3] is the least signifficant bit in a nibble,
    -- so this confusing swap happens here and only here,
    -- the entire rest of the codebase is sane.
    oddr_tx_data_3 : ODDRX1F
    PORT MAP
    (
        SCLK => i_clk,
        RST  => '0',
        D0   => r_tx_data(0),
        D1   => r_tx_data(4),
        Q    => o_eth1_tx_data(3)
    );

    oddr_tx_data_2 : ODDRX1F
    PORT MAP
    (
        SCLK => i_clk,
        RST  => '0',
        D0   => r_tx_data(1),
        D1   => r_tx_data(5),
        Q    => o_eth1_tx_data(2)
    );

    oddr_tx_data_1 : ODDRX1F
    PORT MAP
    (
        SCLK => i_clk,
        RST  => '0',
        D0   => r_tx_data(2),
        D1   => r_tx_data(6),
        Q    => o_eth1_tx_data(1)
    );

    oddr_tx_data_0 : ODDRX1F
    PORT MAP
    (
        SCLK => i_clk,
        RST  => '0',
        D0   => r_tx_data(3),
        D1   => r_tx_data(7),
        Q    => o_eth1_tx_data(0)
    );

END ARCHITECTURE;
