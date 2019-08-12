library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library display;

entity vga_tb is
end entity vga_tb;

architecture rtl of vga_tb is

  -- Clock
  constant CLOCK_SPEED : natural := 65e6;
  constant CLOCK_PERIOD : time := 1.0 sec / CLOCK_SPEED;
  constant CLOCK_DUTY : real := 0.5;
  constant CLOCK_PHASE : real := 0.0 / 360.0;

  constant RESET_PERIOD : time := 10 us;

  constant WHITE_PIXEL : std_logic_vector(5 downto 0) := (others => '1');
  alias R : std_logic_vector(1 downto 0) is WHITE_PIXEL(5 downto 4);
  alias G : std_logic_vector(1 downto 0) is WHITE_PIXEL(3 downto 2);
  alias B : std_logic_vector(1 downto 0) is WHITE_PIXEL(1 downto 0);

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';

  signal hsync, vsync : std_logic;
  signal pxl_rdy : std_logic;

  signal i_red, i_blue, i_green : std_logic_vector(1 downto 0);
  signal o_red, o_blue, o_green : std_logic_vector(1 downto 0);

begin
  
  vga1 : entity display.vga 
    port map(
       	clk => clk,
        rst => rst,

        hsync => hsync,
        vsync => vsync,

        -- Input colors
        i_red => i_red,
        i_blue => i_blue,
        i_green => i_green,

        pxl_rdy => pxl_rdy,

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

  stim : process
  begin

    wait until falling_edge(clk);
    if pxl_rdy='1' then
      i_red <= R;
      i_green <= G;
      i_blue <= B;
    else
      i_red <= (others => '0');
      i_green <= (others => '0');
      i_blue <= (others => '0');
    end if;
  end process;

  kill_sim : process
  begin
    wait for 100 ms;
    assert (false) report "-- SIMULATION COMPLETE --" severity failure;
  end process;

end architecture rtl;
