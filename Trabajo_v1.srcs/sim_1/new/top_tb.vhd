library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP_TB is
end TOP_TB;

architecture TEST of TOP_TB is

    constant TB_CLOCK_FREQ   : positive := 4_000;
    constant TB_CLOCK_PERIOD : time := 1 sec / TB_CLOCK_FREQ;

    component TOP
        generic (
            CLKIN_FREQ : positive
        );
        port (
            CLK100MHZ      : in  std_logic;  -- Nexys4 DDR on-board clock
            CPU_RESETN     : in  std_logic;  -- Nexys4 DDR CPU_RESETN pushbutton (negated)
            SW             : in  std_logic_vector(3 downto 0);  -- Nexys4 DDR switches
            LED            : out std_logic_vector(3 downto 0);  -- Nexys4 DDR RGB green leds
            LED16_G        : out std_logic;  -- Nexys4 DDR RGB led 16 green (going up)
            LED16_R        : out std_logic;  -- Nexys4 DDR RGB led 16 red (going down)
            CA, CB, CC, CD : out std_logic;  -- Nexys4 DDR 7-segment display segments (negated)
            CE, CF, CG, DP : out std_logic;
            AN             : out std_logic_vector(7 downto 0)   -- Nexys4 DDR 7-segment display anodes (negated)
        );       
    end component;

    -- Inputs
    signal clk100mhz  : std_logic := '0';
    signal cpu_resetn : std_logic;
    signal sw         : std_logic_vector(3 downto 0);

    -- Outputs
    signal led        : std_logic_vector(3 downto 0);
    signal led16_g    : std_logic;
    signal led16_r    : std_logic;
    signal ca, cb, cc : std_logic;
    signal cd, ce, cf : std_logic;
    signal dp         : std_logic;
    signal an         : std_logic_vector(7 downto 0);

 begin
    uut: top
        generic map (
            CLKIN_FREQ => TB_CLOCK_FREQ
        )
        port map(
            CLK100MHZ  => clk100mhz,
            CPU_RESETN => cpu_resetn,
            SW         => sw,
            LED        => led,
            LED16_G    => led16_g,
            LED16_R    => led16_r,
            CA         => ca,
            CB         => cb,
            CC         => cc,
            CD         => cd,
            CE         => ce,
            CF         => cf,
            DP         => dp,
            AN         => an
        );

    clk100mhz <= not clk100mhz after 0.5 * TB_CLOCK_PERIOD;

    cpu_resetn <= '0', '1' after 100 ms;

    stim_proc: process
    begin
        sw <= "0000";

        -- send to third floor
        wait for 500 ms;
        SW <= "1000";
        wait for 500 ms;
        SW <= "0000";

        -- Wait until arrived or timeout
        wait until LED16_G = '0' for 10 sec;

        -- send to third floor
        wait for 500 ms;
        SW <= "0010";
        wait for 500 ms;
        SW <= "0000";

        -- Wait until arrived or timeout
        wait until LED16_R = '0' for 10 sec;

        wait for 1 sec;
        assert false
            report "[SUCCESS]: simulation finished."
            severity failure;
    end process;
end TEST;