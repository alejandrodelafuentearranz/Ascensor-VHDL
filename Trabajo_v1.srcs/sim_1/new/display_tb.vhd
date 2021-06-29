library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DISPLAY_DECODER_TB is
end DISPLAY_DECODER_TB;

architecture TEST of DISPLAY_DECODER_TB is

    component DISPLAY_DECODER is
        port (
            SENSORS  : in  std_logic_vector(3 downto 0);
            SEGMENTS : out std_logic_vector(6 downto 0)
        );
    end component;

    type testpair is record
        code     : std_logic_vector(3 downto 0);
        segments : std_logic_vector(6 downto 0);
    end record;

    type testpair_vector is array(positive range <>) of testpair;
    constant testdata : testpair_vector := (
        (code => "0001", segments => "1001111"),
        (code => "0010", segments => "0010010"),
        (code => "0100", segments => "0000110"),
        (code => "1000", segments => "1001100"),
        (code => "0101", segments => "1111110")
    );

    signal sensors  : std_logic_vector(3 DOWNTO 0);
    signal segments : std_logic_vector(6 DOWNTO 0);

begin
    uut: DISPLAY_DECODER 
        port map (
           SENSORS  => SENSORS,
           SEGMENTS => SEGMENTS
       );

    process
    begin
        for i in testdata'range loop
            sensors <= testdata(i).code;
            wait for 10 ns;
            assert segments = testdata(i).segments
                report "[FAILURE]: wrong segments."
                severity failure;
        end loop;

        wait for 10 ns;
        assert false
            report "[SUCCESS]: simulation finished."
            severity failure;
    end process;
end TEST;