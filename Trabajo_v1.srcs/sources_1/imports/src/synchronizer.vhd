-- Sincronizador de entrada asíncrona
--
-- El siguiente código es un ejemplo de la sincronización de una entrada asíncrona
-- de un diseño para reducir las probabilidades de que el circuito se vea afectado por la metaestabilidad
--
--  ASYNC_REG="TRUE" - Especifica que los registros recibirán entrada de datos asícnronos
--                     para permitir que las herramientas lo reporten y así mejorar la metaestabilidad
--
-- The following constants are available for customization:
--
--   SYNC_STAGES     - Valor entero para el number de registros sincronizadores,debe ser 2 o superior
--   PIPELINE_STAGES - Valor entero para el number de registros en la salida del  sincronizador
--                     con el propósito de mejorar el rendimiento.
--   INIT            - Valor inicial de los registros del sincronizador antes del inicio, 1'b0 o 1'b1.

library ieee;
use ieee.std_logic_1164.all;

entity SYNCHRONIZER is
    generic (
        WIDTH           : positive;
        SYNC_STAGES     : integer := 3;
        PIPELINE_STAGES : integer := 1;
        INIT            : std_logic_vector
    );
    port (
        CLK      : in  std_logic;
        ASYNC_IN : in  std_logic_vector(WIDTH - 1 downto 0);
        SYNC_OUT : out std_logic_vector(WIDTH - 1 downto 0)
    );
end SYNCHRONIZER;

architecture BEHAVIORAL of SYNCHRONIZER is
begin
    synchros: for i in ASYNC_IN'range generate
        signal sreg : std_logic_vector(SYNC_STAGES - 1 downto 0) := (others => INIT(i));
        attribute async_reg : string;
        attribute async_reg of sreg : signal is "true";
        signal sreg_pipe : std_logic_vector(PIPELINE_STAGES - 1 downto 0) := (others => INIT(i));
        attribute shreg_extract : string;
        attribute shreg_extract of sreg_pipe : signal is "false";
    begin
        process(CLK)
        begin
            if rising_edge(CLK) then
                sreg <= sreg(SYNC_STAGES - 2 downto 0) & ASYNC_IN(i);  -- Entrada asíncrona async_in
            end if;
        end process;

        no_pipeline: if PIPELINE_STAGES = 0 generate
        begin
            SYNC_OUT(i) <= sreg(SYNC_STAGES - 1);
        end generate;

        one_pipeline: if PIPELINE_STAGES = 1 generate
        begin
            process(CLK)
            begin
                if rising_edge(CLK) then
                    SYNC_OUT(i) <= sreg(SYNC_STAGES - 1);
                end if;
            end process;
        end generate;

        multiple_pipeline: if PIPELINE_STAGES > 1 generate
        begin
            process(clk)
            begin
                if rising_edge(CLK) then
                    sreg_pipe <= sreg_pipe(PIPELINE_STAGES - 2 downto 0) & sreg(SYNC_STAGES - 1);
                end if;
            end process;
            SYNC_OUT(i) <= sreg_pipe(PIPELINE_STAGES - 1);
        end generate;
    end generate;
end BEHAVIORAL;
