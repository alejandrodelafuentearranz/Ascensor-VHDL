library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity CLK_DIVIDER_TB is
end CLK_DIVIDER_TB;
 
architecture TEST of CLK_DIVIDER_TB is

    component CLK_DIVIDER
        generic (
            CLKIN_FREQ  : positive;
            CLKOUT_FREQ : positive
        );
        port (
            CLKIN  : in  std_logic;
            CLKOUT : out std_logic
        );
   end component;
        
   signal clkin  : std_logic := '0';
   signal clkout : std_logic;

   constant CLKIN_FREQ  : positive := 100_000_000;
   constant CLKOUT_FREQ : positive :=  10_000_000;

   constant CLKIN_PERIOD  : time := 1 sec / CLKIN_FREQ;
   constant CLKOUT_PERIOD : time := 1 sec / CLKOUT_FREQ;

begin
    uut: CLK_DIVIDER
        generic map (
            CLKIN_FREQ  => CLKIN_FREQ,
            CLKOUT_FREQ => CLKOUT_FREQ
        )
        port map (
            CLKIN  => clkin,
            CLKOUT => clkout
        );
    
   clkin <= not clkin after 0.5 * CLKIN_PERIOD;

    stim_proc: process
        variable tref : time;
    begin
        wait until clkout = '1';
        tref := now;
        wait until clkout = '0';
        assert now - tref = 0.5 * CLKOUT_PERIOD
            report "[FAILURE]: wrong time at low level."
            severity failure;

        tref := now;
        wait until clkout = '1';
        assert now - tref = 0.5 * CLKOUT_PERIOD
            report "[FAILURE]: wrong time at high level."
            severity failure;

        wait for 2 * CLKIN_PERIOD;
        assert false
            report "[SUCCESS]: simulation finished."
            severity failure;
    end process;
end architecture TEST;
