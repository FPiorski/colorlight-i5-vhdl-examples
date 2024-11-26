--Naive TMDS encoder, pretty much the DVI spec graph in the form of HDL code
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tmds_encoder IS
    PORT
    (
        i_clk     : IN    std_logic;

        i_data    : IN    std_logic_vector(7 downto 0);
        i_de      : IN    std_logic;
        --C0 and C1 are control data, see DVI spec rev 1.0 pages 26, 28
        i_control : IN    std_logic_vector(1 downto 0);

        o_data    :   OUT std_logic_vector(9 downto 0)
    );
END tmds_encoder;

ARCHITECTURE RTL OF tmds_encoder IS

    --N1{x}, N0{x} - number of ones/zeros in a vector, DVI spec p. 28
    FUNCTION f_n(i_sym : std_logic; i_vec : std_logic_vector) RETURN integer IS
        VARIABLE v_ret : integer := 0;
    BEGIN
        FOR i IN i_vec'RANGE LOOP
            IF (i_vec(i) = i_sym) THEN
                v_ret := v_ret + 1;
            END IF;
        END LOOP;
        RETURN v_ret;
    END FUNCTION;

    --These used to be one-liners, but my syntax highlighting wasn't too happy about that :D
    FUNCTION f_n1(i_vec : std_logic_vector) RETURN integer IS BEGIN RETURN f_n('1', i_vec);
    END FUNCTION;
    FUNCTION f_n0(i_vec : std_logic_vector) RETURN integer IS BEGIN RETURN f_n('0', i_vec);
    END FUNCTION;

    SIGNAL   r_output_data : std_logic_vector(9 downto 0) := (OTHERS => '0');

    SIGNAL   r_cnt         : integer RANGE -128 TO 127 := 0;

    --I don't know what q_m stands for, maybe middle?
    SIGNAL   r_m           : std_logic_vector(8 downto 0) := (OTHERS => '0');

BEGIN

    o_data <= r_output_data;

    --Use either XOR or XNOR, depending on which will yield the lower number of transitions
    P_calculate_q_m : PROCESS(i_data)
        VARIABLE v_b : boolean;
    BEGIN
        v_b := (f_n1(i_data) > 4 OR (f_n1(i_data) = 4 AND i_data(0) = '0'));

        r_m(0) <= i_data(0);
        FOR i IN 1 TO 7 LOOP
            IF (v_b) THEN
                r_m(i) <= r_m(i-1) XNOR i_data(i);
            ELSE
                r_m(i) <= r_m(i-1) XOR  i_data(i);
            END IF;
        END LOOP;
        IF (v_b) THEN
            r_m(8) <= '0';
        ELSE
            r_m(8) <= '1';
        END IF;
    END PROCESS;

    P_do_the_rest : PROCESS(i_clk)
    BEGIN
        IF (rising_edge(i_clk)) THEN
            IF (i_de = '0') THEN
                r_cnt <= 0;
                --notice the assignemnts in the graph in the DVI spec p. 28 go q_out[0:9]
                -- and our r_output_data is (9 downto 0), hence the mirroring
                CASE (i_control) IS
                    WHEN "00" =>
                        --r_output_data <= "0010101011";
                        r_output_data <= "1101010100";
                    WHEN "01" =>
                        --r_output_data <= "1101010100";
                        r_output_data <= "0010101011";
                    WHEN "10" =>
                        --r_output_data <= "0010101010";
                        r_output_data <= "0101010100";
                    WHEN "11" =>
                        --r_output_data <= "1101010101";
                        r_output_data <= "1010101011";
                    WHEN OTHERS =>
                        NULL;
                END CASE;
            ELSE --DE == HIGH
                IF ( r_cnt = 0 OR f_n1(r_m(7 downto 0)) = f_n0(r_m(7 downto 0)) ) THEN
                    r_output_data(9) <= NOT r_m(8);
                    r_output_data(8) <=     r_m(8);
                    IF (r_m(8) = '1') THEN
                        r_output_data(7 downto 0) <=     r_m(7 downto 0);
                    ELSE
                        r_output_data(7 downto 0) <= NOT r_m(7 downto 0);
                    END IF;
                    IF (r_m(8) = '0') THEN
                        r_cnt <= r_cnt + f_n0(r_m(7 downto 0)) - f_n1(r_m(7 downto 0));
                    ELSE
                        r_cnt <= r_cnt - f_n0(r_m(7 downto 0)) + f_n1(r_m(7 downto 0));
                    END IF;
                ELSE
                    --There's a superfluous "(" at the beginning of the second line
                    -- of the block this IF represents, in the TMDS encoder in the
                    -- DVI rev 1.0 standard (I wasn't able to find a newer revision
                    -- but other sources available online confirmed this)
                    IF ( ( r_cnt > 0 AND f_n1(r_m(7 downto 0)) > f_n0(r_m(7 downto 0)) ) OR
                         ( r_cnt < 0 AND f_n1(r_m(7 downto 0)) < f_n0(r_m(7 downto 0)) ) )
                    THEN
                        r_output_data(9) <= '1';
                        r_output_data(8) <= r_m(8);
                        r_output_data(7 downto 0) <= NOT r_m(7 downto 0);
                        IF (r_m(8) = '1') THEN
                            r_cnt <= r_cnt + 2 + f_n0(r_m(7 downto 0)) - f_n1(r_m(7 downto 0));
                        ELSE
                            r_cnt <= r_cnt     + f_n0(r_m(7 downto 0)) - f_n1(r_m(7 downto 0));
                        END IF;
                    ELSE
                        r_output_data(9) <= '0';
                        r_output_data(8) <= r_m(8);
                        r_output_data(7 downto 0) <=     r_m(7 downto 0);
                        IF (r_m(8) = '0') THEN
                            r_cnt <= r_cnt - 2 - f_n0(r_m(7 downto 0)) - f_n1(r_m(7 downto 0));
                        ELSE
                            r_cnt <= r_cnt     - f_n0(r_m(7 downto 0)) + f_n1(r_m(7 downto 0));
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;
