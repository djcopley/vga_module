library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
  generic(
    COLOR_IN_WIDTH : natural := 2;
    COLOR_OUT_WIDTH : natural := 2;

    -- tinyvga.com/vga-timing
    -- Default - 1024 x 768 @ 60Hz
    -- 65 MHz Pixel Clock
    H_VISIBLE_AREA : natural := 1024;
    H_FRONT_PORCH : natural := 24;
    H_SYNC_PULSE : natural := 136;
    H_BACK_PORCH : natural := 160;
    H_WHOLE_LINE : natural := 1344;

    V_VISIBLE_AREA : natural := 768;
    V_FRONT_PORCH : natural := 3;
    V_SYNC_PULSE : natural := 6;
    V_BACK_PORCH : natural := 29;
    V_WHOLE_LINE : natural := 806
  );
  port(
    clk : in std_logic;
    rst : in std_logic;

    hsync : out std_logic;
    vsync : out std_logic;

    -- Input colors
    i_red : in std_logic_vector(COLOR_IN_WIDTH-1 downto 0);
    i_blue : in std_logic_vector(COLOR_IN_WIDTH-1 downto 0);
    i_green : in std_logic_vector(COLOR_IN_WIDTH-1 downto 0);
    
    -- '1' if ready for pixel else '0'
    pxl_rdy : out std_logic;

    -- Output colors
    -- 4 x 4 x 4 yields 64 different colors
    o_red : out std_logic_vector(COLOR_OUT_WIDTH-1 downto 0);
    o_blue : out std_logic_vector(COLOR_OUT_WIDTH-1 downto 0);
    o_green : out std_logic_vector(COLOR_OUT_WIDTH-1 downto 0)
  );
end entity vga;

architecture RTL of vga is

  procedure SyncCount(signal count : inout natural;
                      constant wrap : in natural;
                      constant enable : in boolean;
                      variable wrapped : out boolean) is
  begin
    if enable then
      if count < wrap then
        count <= count + 1;
        wrapped := false;
      else
        count <= 0;
        wrapped := true;
      end if;
    end if;
  end procedure;

  signal h_count : natural := 0;
  signal v_count : natural := 0;
  
begin

  process(clk)
    
    variable wrapped : boolean;
	
  begin
		
    if rising_edge(clk) then
      
      if rst='1' then

        o_red <= (others => '0');
        o_blue <= (others => '0');
        o_green <= (others => '0');

      else

        SyncCount(h_count, H_WHOLE_LINE, true, wrapped);
        SyncCount(v_count, V_WHOLE_LINE, wrapped, wrapped);
      
        -- Sync Pulses
        if h_count = H_VISIBLE_AREA + H_FRONT_PORCH then
          hsync <= '0';
        elsif h_count = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE then
          hsync <= '1';
        end if;

        if v_count = V_VISIBLE_AREA + V_FRONT_PORCH then
          vsync <= '0';
        elsif v_count = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE then
          vsync <= '1';
        end if;

        -- To display or not to display
        if h_count < H_VISIBLE_AREA and v_count < V_VISIBLE_AREA then
        
          pxl_rdy <= '1';

          o_red <= i_red;
          o_green <= i_green;
          o_blue <= i_blue;
        
        else

          pxl_rdy <= '0';

          o_red <= (others => '0');
          o_green <= (others => '0');
          o_blue <= (others =>'0');
        
        end if;

      end if;
			
    end if;

  end process;
end architecture RTL;
