--------------------------------------------------------------------------------
-- Project:       fpjswis
-- File:          fifo.vhd
--
-- Creation date: 2022-05-02
--
-- Author:        FPiorski
-- License:       CERN-OHL-W-2.0
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY fifo IS
    GENERIC
    (
        g_width          : positive :=  8;
        g_depth_log2     : positive := 10;
        g_empty_headroom : positive := 16;
        g_full_headroom  : positive := 16
    );
    PORT
    (
        --Write port
        i_wr_clk         : IN    std_logic;
        i_wr_data        : IN    std_logic_vector(g_width-1 downto 0);
        i_wr_ena         : IN    std_logic;

        --Read port
        i_rd_clk         : IN    std_logic;
        o_rd_data        :   OUT std_logic_vector(g_width-1 downto 0);
        i_rd_ena         : IN    std_logic;

        --Status signal (asynchronous, need to be synchronized externally)
        o_almost_empty   :   OUT std_logic;
        o_empty          :   OUT std_logic;
        o_almost_full    :   OUT std_logic
    );
END fifo;

ARCHITECTURE RTL OF fifo IS

    CONSTANT C_depth              : integer := 2**g_depth_log2;

    TYPE     T_fifo_arr IS ARRAY (0 TO C_depth-1) OF std_logic_vector(g_width-1 downto 0);
    SIGNAL   r_fifo_arr           : T_fifo_arr;

    SIGNAL   r_rd_pointer         : integer RANGE 0 TO C_depth-1 := 0;
    SIGNAL   r_wr_pointer         : integer RANGE 0 TO C_depth-1 := 0;

    SIGNAL   w_wr_pointer_wrapped : integer RANGE 0 TO C_depth-1+C_depth;

BEGIN

    o_rd_data            <= r_fifo_arr(r_rd_pointer);

    w_wr_pointer_wrapped <= r_wr_pointer WHEN (r_wr_pointer >= r_rd_pointer) ELSE
                            r_wr_pointer + C_depth;

    o_almost_empty       <= '1' WHEN (w_wr_pointer_wrapped - r_rd_pointer <=          g_empty_headroom) ELSE
                            '0';
    o_empty              <= '1' WHEN (w_wr_pointer_wrapped - r_rd_pointer  =                         0) ELSE
                            '0';
    o_almost_full        <= '1' WHEN (w_wr_pointer_wrapped - r_rd_pointer >= C_depth-1-g_full_headroom) ELSE
                            '0';

    P_write : PROCESS(i_wr_clk)
    BEGIN
        IF (rising_edge(i_wr_clk)) THEN
            IF(i_wr_ena = '1') THEN
                r_fifo_arr(r_wr_pointer) <= i_wr_data;

                IF (r_wr_pointer < C_depth-1) THEN
                    r_wr_pointer <= r_wr_pointer + 1;
                ELSE
                    r_wr_pointer <= 0;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    P_read : PROCESS(i_rd_clk)
    BEGIN
        IF (rising_edge(i_rd_clk)) THEN
            IF(i_rd_ena = '1') THEN
                IF (r_rd_pointer < C_depth-1) THEN
                    r_rd_pointer <= r_rd_pointer + 1;
                ELSE
                    r_rd_pointer <= 0;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    ASSERT (2**g_depth_log2 > g_empty_headroom + g_full_headroom) REPORT
        "FIFO: Almost empty/almost full thresholds cover the entire FIFO memory, " &
              "decrease them or increase the memory depth" SEVERITY failure;

END ARCHITECTURE;
