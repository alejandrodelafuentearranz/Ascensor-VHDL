library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP is
    generic (
        CLKIN_FREQ : positive := 100_000_000  -- Nexys4 DDR clock frequency [Hz]
    );
    port (
        CLK100MHZ      : in  std_logic;  -- Nexys4 DDR on-board clock
        CPU_RESETN     : in  std_logic;  -- Nexys4 DDR CPU_RESETN pushbutton (negated)
        SW             : in  std_logic_vector(3 downto 0);  -- Nexys4 DDR switches
        LED            : out std_logic_vector(3 downto 0);  -- Nexys4 DDR RGB green leds
        LED16_G        : out std_logic;  -- Nexys4 DDR RGB led 16 green (going up)
        LED16_R        : out std_logic;  -- Nexys4 DDR RGB led 16 red (going down)
        LED17_B         : OUT STD_LOGIC;
        CA, CB, CC, CD : out std_logic;  -- Nexys4 DDR 7-segment display segments (negated)
        CE, CF, CG, DP : out std_logic;
        AN             : out std_logic_vector(7 downto 0)   -- Nexys4 DDR 7-segment display anodes (negated)
    );
    end TOP;

architecture STRUCTURAL of TOP is

    constant SYS_CLK_FREQ : positive := 1_000;  -- Internal clock frequency [Hz]

    -- Declaración de componentes ---------------------------------------------

    component CLK_DIVIDER
        generic (
            CLKIN_FREQ  : positive;
            CLKOUT_FREQ : positive
        );
        port (
            CLKIN  : in  std_logic;
            CLKOUT : out std_logic
        );
    end component;
  
    component SYNCHRONIZER is
        generic (
            WIDTH    : positive;
            INIT     : std_logic_vector
        );
        port (
            CLK      : in  std_logic;
            ASYNC_IN : in  std_logic_vector(WIDTH - 1 downto 0);
            SYNC_OUT : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;
    
    component MAQUINA_ESTADOS
        port(
            CLK       : in  std_logic;
            RESET     : in  std_logic;
            SENSORS   : in  std_logic_vector(3 downto 0);
            REQ_FLOOR : in  std_logic_vector(3 downto 0);
            MOTOR_UP  : out std_logic;
            MOTOR_DN  : out std_logic;
            PUERTA  : out std_logic;
            CUR_FLOOR : out std_logic_vector(3 downto 0)
        );
    end component;

    component REQ_REGISTER is
        port (
            CLK       : in  std_logic;
            RESET     : in  std_logic;
            BUTTONS   : in  std_logic_vector(3 downto 0);
            MOTOR_UP  : in  std_logic;
            MOTOR_DN  : in  std_logic;
            REQ_FLOOR : out std_logic_vector(3 downto 0));
    end component;

    component MOTOR
        port(
            CLK       : in  std_logic;
            RESET     : in  std_logic;
            MOTOR_UP  : in  std_logic;
            MOTOR_DN  : in  std_logic;
            LMT_SNSRS : out std_logic_vector(3 downto 0)
        );
    end component;

    component DISPLAY_DECODER
        port(
            SENSORS  : in  std_logic_vector(3 downto 0);
            SEGMENTS : out std_logic_vector(6 downto 0)
        );
    end component;

    component DISPLAY_REFRESH
        port(
            RESET    : in  std_logic;
            CLK      : in  std_logic;
            CODE     : in  std_logic_vector(6 downto 0);
            SEGMENTS : out std_logic_vector(6 downto 0);
            ANODES   : out std_logic_vector(7 downto 0)
        );
    end component;

    --------------------------------------------- Declaración de componentes --

    -- Señales ----------------------------------------------------------------

    signal sys_clk       : std_logic;                   -- System clock
    signal async_inputs  : std_logic_vector(4 downto 0);
    signal syncd_inputs  : std_logic_vector(async_inputs'range);
    signal sys_reset     : std_logic;                   -- System async reset
    signal segments      : std_logic_vector(6 downto 0);
    signal segments_i    : std_logic_vector(segments'range);
    signal motor_up      : std_logic;
    signal motor_dn      : std_logic;
    signal puerta        : std_logic;
    signal sensors       : std_logic_vector(3 downto 0);
    signal reqsted_floor : std_logic_vector(3 downto 0);
    signal current_floor : std_logic_vector(3 downto 0);

    ---------------------------------------------------------------- Señales --

begin
    DP <= '1';
    (CA, CB, CC, CD, CE, CF, CG) <= segments;

    clkdiv_1: CLK_DIVIDER
        generic map (
            CLKIN_FREQ  => CLKIN_FREQ,
            CLKOUT_FREQ => SYS_CLK_FREQ
        )
        port map (
            CLKIN  => CLK100MHZ,
            CLKOUT => sys_clk
        );

    async_inputs <= CPU_RESETN & SW;

    synchro_1: SYNCHRONIZER
        generic map (
            WIDTH    => 5,
            INIT     => "10000"
        )
        port map (
            CLK      => sys_clk,
            ASYNC_IN => async_inputs,
            SYNC_OUT => syncd_inputs
        );

    sys_reset <= syncd_inputs(4) nand CPU_RESETN; -- Sync reset finish with sys_clock

    fsm_1: MAQUINA_ESTADOS
   	    port map(
            CLK       => sys_clk,
            RESET     => sys_reset,
            SENSORS   => sensors,
            REQ_FLOOR => reqsted_floor,
            MOTOR_UP  => motor_up,
            MOTOR_DN  => motor_dn,
            PUERTA  => puerta,
            CUR_FLOOR => current_floor
        );

    LED     <= current_floor or reqsted_floor;
    LED16_G <= motor_up;
    LED16_R <= motor_dn;
    LED17_B <= puerta;

    reqreg_1: REQ_REGISTER
        port map (
            CLK       => sys_clk,
            RESET     => sys_reset,
            BUTTONS   => syncd_inputs(3 downto 0),
            MOTOR_UP  => motor_up,
            MOTOR_DN  => motor_dn,
            REQ_FLOOR => reqsted_floor
        );

    motor_1: MOTOR
        port map(
            CLK       => sys_clk,
            RESET     => sys_reset,
            MOTOR_UP  => motor_up,
            MOTOR_DN  => motor_dn,
            LMT_SNSRS => sensors
        );

    udis: DISPLAY_DECODER
        port map(
            SENSORS  => current_floor,
            SEGMENTS => segments_i
        );

    udisplay_refresh: DISPLAY_REFRESH
        port map(
            CLK      => sys_clk,
            RESET    => sys_reset,
            CODE     => segments_i,
            SEGMENTS => segments,
            ANODES   => AN
        );
end STRUCTURAL;
