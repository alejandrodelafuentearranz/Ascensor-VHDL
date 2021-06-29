library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--En este bloque definiremos el funcionamiento de la maquina de estados
--Le llegaran señales del reloj con la frecuencia ya reducida y sincronizada junto con la señal de entrada que sera
-- los sensores y el REQ_FLOOR donde manejamos el registro
-- Como salida utilizaremos una Puerta que se pondra a 1 cuando el ascensor este parado, lo que significa que las puerta estan abiertas
-- y el motor que sabremos si esta subiendo o bajando dependiendo del piso al que vaya

entity MAQUINA_ESTADOS is
    port (
        CLK       : in  std_logic;
        RESET     : in  std_logic;
        SENSORS   : in  std_logic_vector(3 downto 0);
        REQ_FLOOR : in  std_logic_vector(3 downto 0);
        
        PUERTA  : out std_logic;
        MOTOR_UP  : out std_logic;
        MOTOR_DN  : out std_logic;
        CUR_FLOOR : out std_logic_vector(3 downto 0)
    );
end MAQUINA_ESTADOS;
 
architecture BEHAVIORAL of MAQUINA_ESTADOS is

    type state_t IS (
        S0_STOP,  -- Parado
        S1_GODN,  -- Bajando
        S2_GOUP   -- Subiendo
    );
    signal state, next_state : state_t;

    signal cur_floor_i : std_logic_vector(CUR_FLOOR'range);

begin
    CUR_FLOOR <= cur_floor_i;

    state_register: process (CLK, RESET, SENSORS)  --Definimos el inicio, que al pulsar el boton de reset, el bloque pase directamente a parada
    begin
        if RESET = '1' then
            state       <= S0_STOP;
            cur_floor_i <= SENSORS;
        elsif rising_edge(CLK) then   --En cambio si lo que detecta es el flanco positivo del reloj, pasara al siguiente estado
            state <= next_state;
            if SENSORS /= "0000" then
                cur_floor_i <= SENSORS;
            end if;
        end if;
    end process;

    next_state_decoder: process (state, REQ_FLOOR, cur_floor_i)  -- Aqui definiremos el funcionamiento como tal de la maquina
    begin
        next_state <= state;
        case state is
            when S0_STOP =>                         -- Estando en reposo, si nos viene la señal del registro que es menor que el piso donde estamos, se activa la bajada
                if REQ_FLOOR < cur_floor_i then
                    next_state <= S1_GODN;
                elsif REQ_FLOOR > cur_floor_i then   -- en cambio si es mayor, se activa la subida
                    next_state <= S2_GOUP;
                else 
                    next_state <= S0_STOP;    -- si seleccionas el mismo piso, se queda donde esta
                end if;

            when S1_GODN =>
                if REQ_FLOOR >= cur_floor_i then  -- si estas bajando y llegas al piso de destino, el ascensor se parara
                    next_state  <= S0_STOP;
                else 
                    next_state <= S1_GODN;      -- si no es el piso de destino, seguira bajando
                end if;

            when S2_GOUP =>
                if REQ_FLOOR <= cur_floor_i then   -- aqui pasa al contrario, si esta subiendo y llega al destino, cambia a parada
                    next_state  <= S0_STOP;
                else 
                    next_state <= S2_GOUP;      -- pero si no es el piso de destino seguir bajando
                end if;
        end case;
    end process;

    output_decoder: process (state)     -- desde aqui controlaremos las salida
    begin
        case state is
            when S0_STOP =>             -- si esta parada el motor no se mueve, y las puerts estan abiertas
                PUERTA <= '1';
                MOTOR_UP <= '0';
                MOTOR_DN <= '0'; 

            when S1_GODN =>             -- si el ascensor esta bajando, se enciende el motor de bajada y puertas cerradas
                PUERTA <= '0';
                MOTOR_UP <= '0';
                MOTOR_DN <= '1'; 

            when S2_GOUP =>             ---- si el ascensor esta subiendo, se enciende el motor de subida y puertas cerradas
                PUERTA <= '0';
                MOTOR_UP <= '1';
                MOTOR_DN <= '0'; 
        end case;
    end process;
end BEHAVIORAL;
