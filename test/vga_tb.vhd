library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_tb is
end entity vga_tb;

architecture rtl of vga_tb is

  -- Clock
  constant CLOCK_SPEED : natural := 65e6;
  constant CLOCK_PERIOD : time := 1.0 sec / CLOCK_SPEED;
  constant DUTY_CYCLE : real := 0.5;

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal hsync, vsync : std_logic;

  signal o_red, o_blue, o_green : std_logic_vector(2 downto 0);

begin
  
  vga1 : entity work.vga 
    port map(
       	clk => clk, -- Pixel clock
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
  

  clk <= not clk after CLOCK_PERIOD / 2;

  end architecture rtl;

