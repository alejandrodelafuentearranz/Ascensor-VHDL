library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Añadimos un divisor de frecuencia debido a la alta frecuencia que tiene el reloj de la FPGA

entity CLK_DIVIDER is
    generic (
        CLKIN_FREQ  : positive;
        CLKOUT_FREQ : positive
    );
    port (
        CLKIN  : in  std_logic;  --CLKIN coreesponde con la entrada del reloj a 100HZ
        CLKOUT : out std_logic -- Esta salida correponde con la salida con la frecuencia ya cambiada
    );
end CLK_DIVIDER;

architecture BEHAVIORAL of CLK_DIVIDER is
   signal clksgnl: std_logic := '0';
begin
    process (CLKIN) --cada vez que cambia una entra en el process
        constant TICKS_PER_SEMIPERIOD : positive := CLKIN_FREQ / (2 * CLKOUT_FREQ);  --Calculamos el numero de veces que tenemos que reducir la frecuencia hasta dejarlo a nuestra frecuencia deseada
        subtype counter_t is integer range 0 to TICKS_PER_SEMIPERIOD - 1;
        variable cnt : counter_t := counter_t'high;
    begin
        if rising_edge(CLKIN) then  --En el momento que detectamos un flanco positivo del reloj
            if cnt = 0 then
                cnt := counter_t'high;    --si el contador esta a 0, asignamos a counter_t`high el valor de cnt
                clksgnl <= not clksgnl;    -- y ademas cambiamos la señal del reloj de 0 a 1, o de 1 a 0
            else
                cnt := cnt - 1;   -- si cnt no esta igual a 0, restamos 1 en el contador cnt
            end if;
        end if;
    end process;

    CLKOUT <= clksgnl;   --asignamos el valor de la señal del reloj con la salida de este modulo
end BEHAVIORAL;
