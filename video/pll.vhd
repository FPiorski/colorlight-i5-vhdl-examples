LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY pll IS
    PORT
    (
        i_clk        : IN    std_logic;
        o_clk_1      :   OUT std_logic;
        o_clk_2      :   OUT std_logic;
        o_pll_locked :   OUT std_logic
    );
END pll;

ARCHITECTURE boilerplate OF pll IS

    COMPONENT EHXPLLL IS
    GENERIC
    (
        CLKI_DIV         : integer :=          1;
        CLKFB_DIV        : integer :=          1;
        CLKOP_DIV        : integer :=          8;
        CLKOS_DIV        : integer :=          8;
        CLKOS2_DIV       : integer :=          8;
        CLKOS3_DIV       : integer :=          8;
        CLKOP_ENABLE     : string  :=  "ENABLED";
        CLKOS_ENABLE     : string  := "DISABLED";
        CLKOS2_ENABLE    : string  := "DISABLED";
        CLKOS3_ENABLE    : string  := "DISABLED";
        CLKOP_CPHASE     : integer :=          0;
        CLKOS_CPHASE     : integer :=          0;
        CLKOS2_CPHASE    : integer :=          0;
        CLKOS3_CPHASE    : integer :=          0;
        CLKOP_FPHASE     : integer :=          0;
        CLKOS_FPHASE     : integer :=          0;
        CLKOS2_FPHASE    : integer :=          0;
        CLKOS3_FPHASE    : integer :=          0;
        FEEDBK_PATH      : string  :=    "CLKOP";
        CLKOP_TRIM_POL   : string  :=   "RISING";
        CLKOP_TRIM_DELAY : integer :=          0;
        CLKOS_TRIM_POL   : string  :=   "RISING";
        CLKOS_TRIM_DELAY : integer :=          0;
        OUTDIVIDER_MUXA  : string  :=     "DIVA";
        OUTDIVIDER_MUXB  : string  :=     "DIVB";
        OUTDIVIDER_MUXC  : string  :=     "DIVC";
        OUTDIVIDER_MUXD  : string  :=     "DIVD";
        PLL_LOCK_MODE    : integer :=          0;
        PLL_LOCK_DELAY   : integer :=        200;
        STDBY_ENABLE     : string  := "DISABLED";
        REFIN_RESET      : string  := "DISABLED";
        SYNC_ENABLE      : string  := "DISABLED";
        INT_LOCK_STICKY  : string  :=  "ENABLED";
        DPHASE_SOURCE    : string  := "DISABLED";
        PLLRST_ENA       : string  := "DISABLED";
        INTFB_WAKE       : string  := "DISABLED"
    );
    PORT
    (
        CLKI             : IN    std_logic;
        CLKFB            : IN    std_logic;
        PHASESEL1        : IN    std_logic;
        PHASESEL0        : IN    std_logic;
        PHASEDIR         : IN    std_logic;
        PHASESTEP        : IN    std_logic;
        PHASELOADREG     : IN    std_logic;
        STDBY            : IN    std_logic;
        PLLWAKESYNC      : IN    std_logic;
        RST              : IN    std_logic;
        ENCLKOP          : IN    std_logic;
        ENCLKOS          : IN    std_logic;
        ENCLKOS2         : IN    std_logic;
        ENCLKOS3         : IN    std_logic;
        CLKOP            :   OUT std_logic;
        CLKOS            :   OUT std_logic;
        CLKOS2           :   OUT std_logic;
        CLKOS3           :   OUT std_logic;
        LOCK             :   OUT std_logic;
        INTLOCK          :   OUT std_logic;
        REFCLK           :   OUT std_logic;
        CLKINTFB         :   OUT std_logic
    );
    END COMPONENT;

    SIGNAL w_clk_1_out : std_logic;

BEGIN

    o_clk_1 <= w_clk_1_out;

    ehxplll_inst : EHXPLLL
    GENERIC MAP
    (
        CLKI_DIV        => 1,
        CLKFB_DIV       => 10,
        CLKOP_DIV       => 2,
        CLKOS_DIV       => 20,
        CLKOP_ENABLE    => "ENABLED",
        CLKOS_ENABLE    => "ENABLED",
        CLKOP_CPHASE    => 0,
        CLKOS_CPHASE    => 0,
        CLKOP_FPHASE    => 0,
        CLKOS_FPHASE    => 0,
        FEEDBK_PATH     => "CLKOP",
        OUTDIVIDER_MUXA => "DIVA",
        OUTDIVIDER_MUXB => "DIVB",
        OUTDIVIDER_MUXC => "DIVC",
        OUTDIVIDER_MUXD => "DIVD",
        STDBY_ENABLE    => "DISABLED",
        DPHASE_SOURCE   => "DISABLED",
        PLLRST_ENA      => "DISABLED",
        INTFB_WAKE      => "DISABLED"
    )
    PORT MAP
    (
        CLKI         => i_clk,
        CLKFB        => w_clk_1_out,
        PHASESEL0    => '0',
        PHASESEL1    => '0',
        PHASEDIR     => '1',
        PHASESTEP    => '1',
        PHASELOADREG => '1',
        STDBY        => '0',
        PLLWAKESYNC  => '0',
        RST          => '0',
        ENCLKOP      => '0',
        ENCLKOS      => '0',
        ENCLKOS2     => '0',
        ENCLKOS3     => '0',
        CLKOP        => w_clk_1_out,
        CLKOS        => o_clk_2,
        LOCK         => o_pll_locked,
        CLKINTFB     => OPEN
    );

END ARCHITECTURE;
