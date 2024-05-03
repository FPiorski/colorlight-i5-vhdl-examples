ARCHITECTURE morse OF led IS

    CONSTANT C_message : string := "HELLO FROM COLORLIGHT I5]]]";

    CONSTANT C_max_letter_length : integer := 20;

    FUNCTION f_encode_message RETURN std_logic_vector IS
        VARIABLE v_return     : std_logic_vector(C_message'LENGTH*(C_max_letter_length+3)-1 downto 0);
        VARIABLE v_preencoded : std_logic_vector(4 downto 0);
        VARIABLE v_t          : integer := 0;
        VARIABLE v_l          : integer;
    BEGIN
        FOR v_i IN C_message'LOW TO C_message'HIGH LOOP
            CASE (C_message(v_i)) IS
                WHEN 'A' => v_preencoded := "000" & "01"; v_l := 2;
                WHEN 'B' => v_preencoded := "0" & "1000"; v_l := 4;
                WHEN 'C' => v_preencoded := "0" & "1010"; v_l := 4;
                WHEN 'D' => v_preencoded := "00" & "100"; v_l := 3;
                WHEN 'E' => v_preencoded := "0000" & "0"; v_l := 1;
                WHEN 'F' => v_preencoded := "0" & "0010"; v_l := 4;
                WHEN 'G' => v_preencoded := "00" & "110"; v_l := 3;
                WHEN 'H' => v_preencoded := "0" & "0000"; v_l := 4;
                WHEN 'I' => v_preencoded := "000" & "00"; v_l := 2;
                WHEN 'J' => v_preencoded := "0" & "0111"; v_l := 4;
                WHEN 'K' => v_preencoded := "00" & "101"; v_l := 3;
                WHEN 'L' => v_preencoded := "0" & "0100"; v_l := 4;
                WHEN 'M' => v_preencoded := "000" & "11"; v_l := 2;
                WHEN 'N' => v_preencoded := "000" & "10"; v_l := 2;
                WHEN 'O' => v_preencoded := "00" & "111"; v_l := 3;
                WHEN 'P' => v_preencoded := "0" & "0110"; v_l := 4;
                WHEN 'Q' => v_preencoded := "0" & "1101"; v_l := 4;
                WHEN 'R' => v_preencoded := "00" & "010"; v_l := 3;
                WHEN 'S' => v_preencoded := "00" & "000"; v_l := 3;
                WHEN 'T' => v_preencoded := "0000" & "1"; v_l := 1;
                WHEN 'U' => v_preencoded := "00" & "001"; v_l := 3;
                WHEN 'V' => v_preencoded := "0" & "0001"; v_l := 4;
                WHEN 'W' => v_preencoded := "00" & "011"; v_l := 3;
                WHEN 'X' => v_preencoded := "0" & "1001"; v_l := 4;
                WHEN 'Y' => v_preencoded := "0" & "1011"; v_l := 4;
                WHEN 'Z' => v_preencoded := "0" & "1100"; v_l := 4;
                WHEN '1' => v_preencoded :=      "01111"; v_l := 5;
                WHEN '2' => v_preencoded :=      "00111"; v_l := 5;
                WHEN '3' => v_preencoded :=      "00011"; v_l := 5;
                WHEN '4' => v_preencoded :=      "00001"; v_l := 5;
                WHEN '5' => v_preencoded :=      "00000"; v_l := 5;
                WHEN '6' => v_preencoded :=      "10000"; v_l := 5;
                WHEN '7' => v_preencoded :=      "11000"; v_l := 5;
                WHEN '8' => v_preencoded :=      "11100"; v_l := 5;
                WHEN '9' => v_preencoded :=      "11110"; v_l := 5;
                WHEN '0' => v_preencoded :=      "11111"; v_l := 5;
                WHEN ' ' =>
                WHEN ']' =>

                WHEN OTHERS =>
                    ASSERT (1 = 0) REPORT "Can't encode character " &
                                           character'IMAGE(C_message(v_i)) &
                                           " at position " &
                                           integer'IMAGE(v_i)
                                           SEVERITY error;
            END CASE;

            IF (C_message(v_i) = ' ') THEN
                v_return(v_t+6-1 downto v_t) := (OTHERS => '0');
                v_t := v_t + 6;
            ELSIF (C_message(v_i) = ']') THEN
                v_return(v_t+C_max_letter_length-1 downto v_t) := (OTHERS => '0');
                v_t := v_t + C_max_letter_length;
            ELSE
                FOR v_j IN v_l-1 DOWNTO 0 LOOP
                    IF (v_preencoded(v_j) = '0') THEN
                        v_return(v_t+2-1 downto v_t) := "01";
                        v_t := v_t + 2;
                    ELSE
                        v_return(v_t+4-1 downto v_t) := "0111";
                        v_t := v_t + 4;
                    END IF;
                END LOOP;
                v_return(v_t+2-1 downto v_t) := "00";
                v_t := v_t + 2;
            END IF;
            ASSERT (1 = 0) REPORT  "Encoded character " &
                                    character'IMAGE(C_message(v_i)) &
                                    " at position " &
                                    integer'IMAGE(v_i) &
                                    "v_t = " &
                                    integer'IMAGE(v_t)
                                    SEVERITY warning;
        END LOOP;
        RETURN v_return(v_t-1 downto 0);
    END FUNCTION;

    CONSTANT C_message_encoded : std_logic_vector := f_encode_message;

    CONSTANT C_morse_unit_ms   : integer := 40;

    CONSTANT C_unit_cnt_mod    : integer := g_sys_clk_hz / 1000 * C_morse_unit_ms;
    SIGNAL   r_unit_cnt        : integer RANGE 0 TO C_unit_cnt_mod-1 := 0;

    CONSTANT C_symbol_cnt_mod  : integer := C_message_encoded'LENGTH;
    SIGNAL   r_symbol_cnt      : integer RANGE 0 TO C_symbol_cnt_mod-1 := 0;

    SIGNAL   r_led             : std_logic := '0';

BEGIN

    --Oops, the other end of the LED is connected to VDD and not GND
    o_led <= NOT r_led;

    P_count_unit : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_unit_cnt < C_unit_cnt_mod-1) THEN
                r_unit_cnt <= r_unit_cnt + 1;
            ELSE
                r_unit_cnt <= 0;
            END IF;
        END IF;
    END PROCESS;

    P_count_character : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (r_unit_cnt = C_unit_cnt_mod-1) THEN
                r_led <= C_message_encoded(r_symbol_cnt);
                IF (r_symbol_cnt < C_symbol_cnt_mod-1) THEN
                    r_symbol_cnt <= r_symbol_cnt + 1;
                ELSE
                    r_symbol_cnt <= 0;
                END IF;
            ELSE
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;
