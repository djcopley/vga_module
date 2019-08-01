library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
  port(
	  clk : in std_logic; -- Pixel clock
	  rst : in std_logic;

    hsync : out std_logic;
    vsync : out std_logic;

    -- Input colors
    i_red : in std_logic_vector(1 downto 0);
    i_blue : in std_logic_vector(1 downto 0);
    i_green : in std_logic_vector(1 downto 0);

    -- Output colors
    -- 4 x 4 x 4 yields 64 different colors
    o_red : out std_logic_vector(1 downto 0);
    o_blue : out std_logic_vector(1 downto 0);
    o_green : out std_logic_vector(1 downto 0)
  );
end entity vga;

architecture RTL of vga is
  
  -- Timing - 1024 x 768 @ 60Hz
  -- 65 MHz Pixel Clock

  constant H_VISIBLE_AREA : natural := 1024;
  constant H_FRONT_PORCH : natural := H_VISIBLE_AREA + 0;
  constant H_SYNC_PULSE : natural := H_FRONT_PORCH + 24;
  constant H_BACK_PORCH : natural := H_SYNC_PULSE + 136;
  constant H_WHOLE_LINE : natural := H_BACK_PORCH + 160;

  constant V_VISIBLE_AREA : natural := 768;
  constant V_FRONT_PORCH : natural := V_VISIBLE_AREA + 0;
  constant V_SYNC_PULSE : natural := V_FRONT_PORCH + 3;
  constant V_BACK_PORCH : natural := V_SYNC_PULSE + 6;
  constant V_WHOLE_LINE : natural := V_BACK_PORCH + 29;

  -- Data for test
  constant WHITE_PIXEL : std_logic_vector(5 downto 0) := (others => '1');

  alias R : std_logic_vector(1 downto 0) is WHITE_PIXEL(5 downto 4);
  alias G : std_logic_vector(1 downto 0) is WHITE_PIXEL(3 downto 2);
  alias B : std_logic_vector(1 downto 0) is WHITE_PIXEL(1 downto 0);

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
        if h_count = H_SYNC_PULSE then
          hsync <= '0';
        elsif h_count = H_BACK_PORCH then
          hsync <= '1';
        end if;

        if v_count = V_SYNC_PULSE then
          vsync <= '0';
        elsif v_count = V_BACK_PORCH then
          vsync <= '1';
        end if;

        -- To display or not to display
        if h_count < H_VISIBLE_AREA and v_count < V_VISIBLE_AREA then
        
          o_red <= R;
          o_green <= G;
          o_blue <= B;
        
        else

          o_red <= (others => '0');
          o_green <= (others => '0');
          o_blue <= (others =>'0');
        
        end if;

      end if;
			
		end if;

	end process;
end architecture RTL;
