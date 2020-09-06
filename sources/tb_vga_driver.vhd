library ieee;
use ieee.std_logic_1164.all;
use work.work_package.all;

entity tb_vga_driver is
end tb_vga_driver;

architecture behavior of tb_vga_driver is
 -- component declaration for the unit under test (uut)
 component vga_driver
 port (
  clk_100mhz : in std_logic;
  reset : in std_logic;
  next_index : in std_logic;
  next_index_dir : in std_logic;
  next_pixel : in std_logic;
  next_pixel_ori : in std_logic;
  next_pixel_dir : in std_logic;
  r : out std_logic_vector(2 downto 0);
  g : out std_logic_vector(2 downto 0);
  b : out std_logic_vector(2 downto 1);
  addr1 : out std_logic_vector(16 downto 0);
  din1 : in std_logic_vector(2 downto 0);
  addr2 : out std_logic_vector(16 downto 0);
  din2 : in std_logic;
  addr_py1 : out std_logic_vector(7 downto 0);
  din_py1 : in std_logic_vector(8 downto 0);
  ym1 : in std_logic_vector(7 downto 0);
  y0_1 : in std_logic_vector(7 downto 0);
  y1_1 : in std_logic_vector(7 downto 0);
  addr_px1 : out std_logic_vector(8 downto 0);
  din_px1 : in std_logic_vector(7 downto 0);
  xm1 : in std_logic_vector(8 downto 0);
  xmw1 : in std_logic_vector(8 downto 0);
  x0_1 : in std_logic_vector(8 downto 0);
  x1_1 : in std_logic_vector(8 downto 0);
  addr_px2 : out std_logic_vector(8 downto 0);
  din_px2 : in std_logic_vector(7 downto 0);
  addr_py2 : out std_logic_vector(11 downto 0);
  din_py2 : in std_logic_vector(8 downto 0);
  ym2 : in std_logic_vector(7 downto 0);
  bounds_addr : in std_logic_vector(3 downto 0);
  bounds_count : in std_logic_vector(3 downto 0);
  addr_b : out std_logic_vector(3 downto 0);
  din_bx0 : in std_logic_vector(8 downto 0);
  din_bx1 : in std_logic_vector(8 downto 0);
  din_by0 : in std_logic_vector(7 downto 0);
  din_by1 : in std_logic_vector(7 downto 0);
  addr_f : out std_logic_vector(9 downto 0);
  din_f : in std_logic_vector(15 downto 0);
  addr_c : out std_logic_vector(3 downto 0);
  din_c : in std_logic_vector(5 downto 0);
  addr_ci : out std_logic_vector(7 downto 0);
  din_ci : in std_logic_vector(15 downto 0);
  addr_d : out std_logic_vector(8 downto 0);
  din_d : in std_logic_vector(8 downto 0);
  state : in state_type;
  ce : in std_logic;
  capture : in std_logic;
  threshold : in std_logic_vector(9 downto 0);
  processing_time : in std_logic_vector(31 downto 0);
  capture_time : in std_logic_vector(31 downto 0);
  icr_btn : out std_logic;
  pixel_clock : in std_logic_vector(7 downto 0);
  hs : out std_logic;
  vs : out std_logic;
  active : out std_logic
 );
end component;

--inputs
signal clk_100mhz : std_logic := '0';
signal reset : std_logic := '1';
--outputs
signal r : std_logic_vector(2 downto 0);
signal g : std_logic_vector(2 downto 0);
signal b : std_logic_vector(2 downto 1);
signal hs : std_logic;
signal vs : std_logic;
signal active : std_logic;
-- clock period definitions
constant clk_100mhz_period : time := 10 ns;
begin
 -- instantiate the unit under test (uut)
 uut: vga_driver port map (
  clk_100mhz => clk_100mhz,
  reset => reset,
  next_index => '0',
  next_index_dir => '0',
  next_pixel => '0',
  next_pixel_ori => '0',
  next_pixel_dir => '0',
  din1 => (others => '0'),
  din2 => '0',
  din_py1 => (others => '0'),
  ym1 => (others => '0'),
  y0_1 => (others => '0'),
  y1_1 => (others => '0'),
  din_px1 => (others => '0'),
  xm1 => (others => '0'),
  xmw1 => (others => '0'),
  x0_1 => (others => '0'),
  x1_1 => (others => '0'),
  din_px2 => (others => '0'),
  din_py2 => (others => '0'),
  ym2 => (others => '0'),
  bounds_addr => (others => '0'),
  bounds_count => (others => '0'),
  din_bx0 => (others => '0'),
  din_bx1 => (others => '0'),
  din_by0 => (others => '0'),
  din_by1 => (others => '0'),
  din_f => (others => '0'),
  din_c => (others => '0'),
  din_ci => (others => '0'),
  din_d => (others => '0'),
  state => idle,
  ce => '0',
  capture => '0',
  threshold => (others => '0'),
  processing_time => (others => '0'),
  capture_time => (others => '0'),
  pixel_clock => (others => '0'),
  r => r,
  g => g,
  b => b,
  hs => hs,
  vs => vs,
  active => active
 );

 -- clock process definitions
 clk_100mhz_process :process
 begin
  clk_100mhz <= '0';
  wait for clk_100mhz_period/2;
  clk_100mhz <= '1';
  wait for clk_100mhz_period/2;
 end process;

 -- stimulus process
 stim_proc: process
 begin
  -- hold reset state for 100 ns.
  wait for 100 ns;
  wait for clk_100mhz_period*10;
  reset <= '0';
  wait;
 end process;
end;