library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Uso del diaplay para visualizr en el display en todo momento el piso donde esta el ascensor

entity DISPLAY_DECODER is
    port (
        SENSORS  : in  std_logic_vector(3 downto 0);
        SEGMENTS : out std_logic_vector(6 downto 0)
    );
end DISPLAY_DECODER;

architecture DATAFLOW of DISPLAY_DECODER is
    begin
        with SENSORS select
                      -- abcdefg
            SEGMENTS <= "1001111" WHEN "0001",  -- 1
                        "0010010" WHEN "0010",  -- 2
                        "0000110" WHEN "0100",  -- 3
                        "1001100" WHEN "1000",  -- 4
                        "1111110" WHEN others;
end architecture DATAFLOW;
