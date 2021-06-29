library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Este bloque tiene la funcion de actualizar el piso donde se encuentra 

entity REQ_REGISTER is
    port (
        CLK       : in  std_logic;
        RESET     : in  std_logic;
        BUTTONS   : in  std_logic_vector(3 downto 0);
        MOTOR_UP  : in  std_logic;
        MOTOR_DN  : in  std_logic;
        REQ_FLOOR : out std_logic_vector(3 downto 0));
end REQ_REGISTER;

architecture BEHAVIORAL of REQ_REGISTER is
signal REQ_FLOOR_i : unsigned(BUTTONS'range);
begin
    process (CLK, RESET)
    begin
        if RESET = '1' then
            REQ_FLOOR_i <= "0001";   -- al pulsar reset ponemos el registro del ascensor en el piso principal
        elsif rising_edge(CLK) then
            if (MOTOR_UP = '1' and MOTOR_DN = '1') then --Está en movimiento el ascensor
                REQ_FLOOR_i <= REQ_FLOOR_i;        -- asignamos la nueva posicion del piso donde esta            
            else
                case BUTTONS is
                    when "0001" | "0010" | "0100" | "1000" =>           --si buttons cambia se le asigna a req_floor                            
                        REQ_FLOOR_i <= unsigned(BUTTONS);                   
                    when others =>                                                
                        REQ_FLOOR_i <= REQ_FLOOR_i; 
                end case; 
            end if;                                                                      
        end if;
    end process;
    REQ_FLOOR <= std_logic_vector(REQ_FLOOR_i);
end BEHAVIORAL;
-- REQ_FLOOR debe actualizarse a BUTTONS si y sólo si:
-- El ascensor no se está moviendo y algún botón está pulsado, pero sólo uno.
-- En caso contrario, debe conservar su valor.