library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MAQUINA_ESTADOS_TB is
end MAQUINA_ESTADOS_TB;

architecture TEST of MAQUINA_ESTADOS_TB is

    component MAQUINA_ESTADOS
        port (
            CLK       : in  std_logic;
            RESET     : in  std_logic;
            SENSORS   : in  std_logic_vector(3 downto 0);
            REQ_FLOOR : in  std_logic_vector(3 downto 0);
            MOTOR_UP  : out std_logic;
            MOTOR_DN  : out std_logic;
            CUR_FLOOR : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Inputs
    signal clk       : std_logic := '0'; 
    signal reset     : std_logic; 
    signal sensors   : std_logic_vector(3 downto 0);
    signal req_floor : std_logic_vector(3 downto 0);

    -- Outputs
    signal motor_up  : std_logic;
    signal motor_dn  : std_logic;
    signal cur_floor : std_logic_vector(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
     uut: MAQUINA_ESTADOS
        port map (
            CLK       => clk,
            RESET     => reset,
            SENSORS   => sensors,
            REQ_FLOOR => req_floor,
            MOTOR_UP  => motor_up,
            MOTOR_DN  => motor_dn,
            CUR_FLOOR => cur_floor
        );
                                 
    clk <= not clk after 0.5 * CLK_PERIOD;

    reset <= '1' after 0.25 * CLK_PERIOD, '0' after 0.75 * CLK_PERIOD;

    stim_proc: process
    begin
        sensors   <= "0001";
        req_floor <= "0001";

        -- Check reset
        wait until reset = '0';
        assert motor_up = '0' and motor_dn = '0'
            report "[FAILURE]: reset malfunction."
            severity failure;

        -- Check going up
        req_floor <= "1000";
        wait until clk = '1';
        wait for 0.01 * CLK_PERIOD;
        assert motor_up = '1' and motor_dn = '0'
            report "[FAILURE]: should be going up."
            severity failure;

        for floor in 1 to 3 loop
            for t in 1 to 10 loop
                wait until clk = '1';
                sensors <= (others => '0');
            end loop;
            sensors <= cur_floor(cur_floor'high - 1 downto 0) & '0';
        end loop;

        wait until clk = '1';
        wait until clk = '1';
        wait for 0.01 * CLK_PERIOD;
        assert motor_up = '0' and motor_dn = '0'
            report "[FAILURE]: should be stopped now."
            severity failure;

        -- Check going down
        wait until clk = '1';
        req_floor <= "0010";
        wait until clk = '1';
        wait for 0.01 * CLK_PERIOD;
        assert motor_up = '0' and motor_dn = '1'
            report "[FAILURE]: should be going up."
            severity failure;

        for floor in 1 to 2 loop
            for t in 1 to 10 loop
                wait until clk = '1';
                sensors <= (others => '0');
            end loop;
            sensors <= '0' & cur_floor(cur_floor'high downto 1);
        end loop;

        wait until clk = '1';
        wait until clk = '1';
        wait for 0.01 * CLK_PERIOD;
        assert motor_up = '0' and motor_dn = '0'
            report "[FAILURE]: should be stopped now."
            severity failure;

        wait for 2 * CLK_PERIOD;
        assert false
            report "[SUCCESS]: simulation finished."
            severity failure;
    end process;
end TEST;