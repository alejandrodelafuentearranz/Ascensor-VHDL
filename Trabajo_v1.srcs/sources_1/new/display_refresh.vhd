library ieee;
use ieee.std_logic_1164.all;

entity DISPLAY_REFRESH is
    port (
        CLK      : in  std_logic;
        RESET    : in  std_logic;
        CODE     : in  std_logic_vector(6 downto 0);
        SEGMENTS : out std_logic_vector(6 downto 0);
        ANODES   : out std_logic_vector(7 downto 0)
    );
end DISPLAY_REFRESH;

architecture BEHAVIORAL of DISPLAY_REFRESH is
begin
    muestra_displays: process (CLK, RESET)
    begin
        if RESET = '1' then 
            SEGMENTS <= (others => '1');
            ANODES   <= (others => '1');
        elsif rising_edge(CLK) then
            SEGMENTS <= CODE;
            ANODES   <= (0 => '0', others => '1');
        end if;
    end process;
end behavioral;