ARCHITECTURE blink OF led IS

    CONSTANT C_led_blink_hz : integer := 3;

    CONSTANT C_led_cnt_mod  : integer := g_sys_clk_hz / C_led_blink_hz / 2;
    SIGNAL   r_led_cnt      : integer RANGE 0 TO C_led_cnt_mod-1 := 0;

    SIGNAL   r_led          : std_logic := '0';

BEGIN

    o_led <= r_led;

    P_blink_led : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_led_cnt < C_led_cnt_mod-1) THEN
                r_led_cnt <= r_led_cnt + 1;
            ELSE
                r_led_cnt <= 0;
                r_led     <= NOT r_led;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;
