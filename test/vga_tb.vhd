library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_tb is
end entity vga_tb;

architecture rtl of vga_tb is

  -- Clock
  constant CLOCK_SPEED : natural := 65e6;
  constant CLOCK_PERIOD : time := 1.0 sec / CLOCK_SPEED;
  constant CLOCK_DUTY : real := 0.5;
  constant CLOCK_PHASE : real := 0.0 / 360.0;

  constant RESET_PERIOD : time := 10 us;

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal hsync, vsync : std_logic;

  signal o_red, o_blue, o_green : std_logic_vector(1 downto 0);

begin
  
  vga1 : entity work.vga 
    port map(
       	clk => clk,
        rst => rst,

        hsync => hsync,
        vsync => vsync,

        -- Input colors
        i_red => (others => '0'),
        i_blue => (others => '0'),
        i_green => (others => '0'),

        -- Output colors
        -- 8 x 8 x 8 yields 512 different colors
        o_red => o_red,
        o_blue => o_blue,
        o_green => o_green 
    );
  
  clk_gen : process
  begin
    clk <= transport '1' after (CLOCK_PERIOD * CLOCK_PHASE);
    clk <= transport '0' after (CLOCK_PERIOD * (CLOCK_DUTY + CLOCK_PHASE));
    wait for CLOCK_PERIOD;
  end process;

  reset : process
  begin
    rst <= '1', '0' after RESET_PERIOD;
    wait;
  end process;

  end architecture rtl;

