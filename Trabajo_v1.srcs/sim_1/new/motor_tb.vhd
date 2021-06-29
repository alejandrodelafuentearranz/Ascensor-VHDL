library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MOTOR_TB is
end MOTOR_TB;

architecture TEST of MOTOR_TB is
    component MOTOR
        generic (
            TICKS_PER_FLOOR : positive
        );
        port (
            CLK        : in  std_logic;
            RESET      : in  std_logic;
            MOTOR_UP   : in  std_logic;
            MOTOR_DN   : in  std_logic;
            LMT_SNSRS : out std_logic_vector(3 downto 0)
        );
    end component;
    
    -- Inputs
    signal clk        : std_logic;
    signal reset      : std_logic;
    signal motor_up   : std_logic;
    signal motor_dn   : std_logic;

    -- Outputs
    signal lmt_snsrs : std_logic_vector(3 downto 0);

    constant CLK_PERIOD      : time := 10 ns;
    constant TICKS_PER_FLOOR : positive := 10;

begin
    uut: MOTOR 
        generic map (
            TICKS_PER_FLOOR => TICKS_PER_FLOOR
        )
        port map (
            CLK        => clk,
            RESET      => reset,
            MOTOR_UP   => motor_up,
            MOTOR_DN   => motor_dn,
            LMT_SNSRS  => lmt_snsrs
        );

    clkgen: process
    begin
        clk <= '0';
        wait for 0.5 *CLK_PERIOD;
        clk <= '1';
        wait for 0.5 *CLK_PERIOD;
    end process;

    reset <= '1' after 0.25 *CLK_PERIOD, '0' after 0.75 *CLK_PERIOD;

    process
    begin
        -- Start stopped
        motor_up <= '0';
        motor_dn <= '0';

        -- Check reset
        wait until reset = '0';
        wait for 0.01 * CLK_PERIOD;
        assert lmt_snsrs = "0001"
            report "[FAILURE]: reset malfunction."
            severity failure;

        -- Check stop
        for i in 1 to TICKS_PER_FLOOR loop
            wait until clk = '1';
        end loop;
        wait for 0.01 * CLK_PERIOD;
        assert lmt_snsrs = "0001"
           report "[FAILURE]: motor should be stopped."
           severity failure;

        -- Check going up
        wait until clk = '1';
        motor_up <= '1';
        motor_dn <= '0';
        for i in 1 to TICKS_PER_FLOOR - 1 loop
            wait until clk = '1';
            wait for 0.01 * CLK_PERIOD;
            assert lmt_snsrs = "0000"
                report "[FAILURE]: ground floor sensor malfunction."
                severity failure;
        end loop;

        wait until clk = '1';
        wait for 0.01 * CLK_PERIOD;
        assert lmt_snsrs = "0010"
            report "[FAILURE]: first floor sensor malfunction."
            severity failure;
        for i in 1 to TICKS_PER_FLOOR - 1 loop
            wait until clk = '1';
            wait for 0.01 * CLK_PERIOD;
            assert lmt_snsrs = "0000"
                report "[FAILURE]: first floor sensor malfunction."
                severity failure;
        end loop;

        wait until clk = '1';
        wait for 0.01 * CLK_PERIOD;
        assert lmt_snsrs = "0100"
            report "[FAILURE]: second floor sensor malfunction."
            severity failure;
        for i in 1 to TICKS_PER_FLOOR - 1 loop
            wait until clk = '1';
            wait for 0.01 * CLK_PERIOD;
            assert lmt_snsrs = "0000"
                report "[FAILURE]: second floor sensor malfunction."
                severity failure;
        end loop;

        wait until clk = '1';
        wait for 0.01 * CLK_PERIOD;
        assert lmt_snsrs = "1000"
            report "[FAILURE]: third floor sensor malfunction."
            severity failure;

        -- Check going down
        wait until clk = '1';
        motor_up <= '0';
        motor_dn <= '1';

        for i in 1 to TICKS_PER_FLOOR - 1 loop
            wait until clk = '1';
            wait for 0.01 * CLK_PERIOD;
            assert lmt_snsrs = "0000"
                report "[FAILURE]: second floor sensor malfunction."
                severity failure;
        end loop;
        wait until clk = '1';
        wait for 0.01 * CLK_PERIOD;
        assert lmt_snsrs = "0100"
            report "[FAILURE]: second floor sensor malfunction."
            severity failure;

        wait for 2 * CLK_PERIOD;
        assert false
            report "[SUCCESS]: simulation finished."
            severity failure;
    end process;
end TEST;