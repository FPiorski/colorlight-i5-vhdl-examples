ARCHITECTURE test_pattern OF pattern_generator IS

    SIGNAL   r_red        : std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL   r_green      : std_logic_vector(7 downto 0) := (OTHERS => '0');
    SIGNAL   r_blue       : std_logic_vector(7 downto 0) := (OTHERS => '0');

BEGIN

    --Unused
    o_uart_tx <= '1';
    o_led     <= '0';

    o_hsync   <= i_hsync;
    o_vsync   <= i_vsync;
    o_de      <= i_de;

    o_r       <= r_red;
    o_g       <= r_green;
    o_b       <= r_blue;

    P_generate_pattern : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            r_red   <= std_logic_vector(to_unsigned(i_x + i_frame, 8));
            r_green <= std_logic_vector(to_unsigned(i_y + 2*i_frame, 8));
            r_blue  <= std_logic_vector(to_unsigned(i_x + i_frame/4, 8) XOR to_unsigned(i_y, 8));
        END IF;
    END PROCESS;

END ARCHITECTURE;
