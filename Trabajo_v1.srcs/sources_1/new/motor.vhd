--Este modulo controlara el funcionamiento del motor

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MOTOR is
    generic (
        TICKS_PER_FLOOR : positive := 2_000
    );
    port (
        CLK       : in  std_logic;
        RESET     : in  std_logic;
        MOTOR_UP  : in  std_logic;
        MOTOR_DN  : in  std_logic;
        LMT_SNSRS : out std_logic_vector(3 downto 0)
    );
end MOTOR;

architecture BEHAVIORAL of MOTOR is
    constant FLOOR_QTY : positive := 4;

    subtype height_t is integer range 0 to (FLOOR_QTY - 1) * TICKS_PER_FLOOR;
    signal height, height_nxt : height_t;

    signal motor_ctrl : std_logic_vector(1 downto 0);
    
begin
    motor_ctrl <= (MOTOR_UP, MOTOR_DN);  -- A la señal que controla el motor le asignamos los bits de MOTOR_UP, MOTOR_DN

    state_register: process (CLK, RESET)
    begin
        if RESET = '1' then   -- si pulsamos el reset  automaticamente la altura (height) se pondra a cero
            height <= 0;
        elsif rising_edge(CLK) then  -- con la señal del reloj se producira el cambio a ala siguiente altura
            height <= height_nxt;
        end if;
    end process;

    next_state_decoder: process (height, motor_ctrl)
    begin
        height_nxt <= height;   -- asignacion de heigh_nxt con height para producir el cambio
        case motor_ctrl is      -- utilizamos un switch case en funcion de la variacion de la señal motor_ctrl
            when "01" =>
                if height /= 0 then  -- en el caso en que se active MOTOR_DN el ascensor bajara y se restara una altura
                    height_nxt <= height - 1;
                end if;

            when "10" =>  -- -- en el caso en que se active MOTOR_UP el ascensor subira y se sumara una altura, en caso de no poder seguir subiendo, no se sumara mas
                if height /= height_t'high then
                    height_nxt <= height + 1;
                end if;

            when others =>
                height_nxt <= height;
        end case;
    end process;

    output_decoder: process (height)   -- desde aqui controlaremos la salida, sabiendo en todo momento en que altura estamos para la maquina de estados
    begin
        LMT_SNSRS  <= (others => '0');
        case height is
            when 0 =>
                LMT_SNSRS <= "0001";
            when TICKS_PER_FLOOR =>
                LMT_SNSRS <= "0010";
            when 2 * TICKS_PER_FLOOR =>
                LMT_SNSRS <= "0100";
            when 3 * TICKS_PER_FLOOR =>
                LMT_SNSRS <= "1000";
            when others =>
                LMT_SNSRS <= "0000";
        end case;
    end process;
end BEHAVIORAL;
