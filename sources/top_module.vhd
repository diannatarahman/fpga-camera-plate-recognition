library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.work_package.all;

entity top_module is
 port (
  clk_100mhz : in std_logic;
  reset : in std_logic;
  capture : in std_logic;
  pause : in std_logic;
  pause_en : in std_logic;
  next_addr : in std_logic;
  next_addr_dir : in std_logic;
  next_index : in std_logic;
  next_index_dir : in std_logic;
  next_pixel : in std_logic;
  next_pixel_ori : in std_logic;
  next_pixel_dir : in std_logic;
  threshold_nextval : in std_logic;
  threshold_nextval_dir : in std_logic;
  ov7670_sioc : out std_logic;
  ov7670_siod : inout std_logic;
  ov7670_pclk : in std_logic;
  ov7670_xclk : out std_logic;
  ov7670_vsync : in std_logic;
  ov7670_href : in std_logic;
  ov7670_data : in std_logic_vector(7 downto 0);
  ov7670_reset_1 : out std_logic;
  ov7670_pwdn : out std_logic;
  vga_r : out std_logic_vector(2 downto 0);
  vga_g : out std_logic_vector(2 downto 0);
  vga_b : out std_logic_vector(2 downto 1);
  vga_hs : out std_logic;
  vga_vs : out std_logic;
  config_finished : out std_logic
 );
end top_module;

architecture behavioral of top_module is
component anpr_module is
 port (
  clk_100mhz : in std_logic;
  reset : in std_logic;
  capture : in std_logic;
  pause : in std_logic;
  pause_en : in std_logic;
  next_addr : in std_logic;
  next_addr_dir : in std_logic;
  threshold_nextval : in std_logic;
  threshold_nextval_dir : in std_logic;
  ov7670_vsync : in std_logic;
  state_capture_image : out std_logic;
  cntx : out unsigned(9 downto 0);
  cnty : out unsigned(8 downto 0);
  ov7670_capture_ce_cntx : in std_logic;
  ov7670_capture_r_acc : in std_logic;
  ov7670_capture_dout1 : in std_logic_vector(2 downto 0);
  ov7670_capture_we1 : in std_logic;
  ov7670_capture_dout2 : in std_logic;
  ov7670_capture_we2 : in std_logic;
  ov7670_capture_finished : in std_logic;
  vga_driver_addr1 : in std_logic_vector(16 downto 0);
  vga_driver_din1 : out std_logic_vector(2 downto 0);
  vga_driver_addr2 : in std_logic_vector(16 downto 0);
  vga_driver_din2 : out std_logic;
  vga_driver_addr_py1 : in std_logic_vector(7 downto 0);
  vga_driver_din_py1 : out std_logic_vector(8 downto 0);
  ym1 : out std_logic_vector(7 downto 0);
  y0_1 : out std_logic_vector(7 downto 0);
  y1_1 : out std_logic_vector(7 downto 0);
  vga_driver_addr_px1 : in std_logic_vector(8 downto 0);
  vga_driver_din_px1 : out std_logic_vector(7 downto 0);
  xm1 : out std_logic_vector(8 downto 0);
  xmw1 : out std_logic_vector(8 downto 0);
  x0_1 : out std_logic_vector(8 downto 0);
  x1_1 : out std_logic_vector(8 downto 0);
  vga_driver_addr_px2 : in std_logic_vector(8 downto 0);
  vga_driver_din_px2 : out std_logic_vector(7 downto 0);
  vga_driver_addr_py2 : in std_logic_vector(11 downto 0);
  vga_driver_din_py2 : out std_logic_vector(8 downto 0);
  vga_driver_ym2 : out std_logic_vector(7 downto 0);
  bounds_addr : out std_logic_vector(3 downto 0);
  bounds_count : out std_logic_vector(3 downto 0);
  vga_driver_addr_b : in std_logic_vector(3 downto 0);
  vga_driver_din_bx0 : out std_logic_vector(8 downto 0);
  vga_driver_din_bx1 : out std_logic_vector(8 downto 0);
  vga_driver_din_by0 : out std_logic_vector(7 downto 0);
  vga_driver_din_by1 : out std_logic_vector(7 downto 0);
  vga_driver_addr_f : in std_logic_vector(9 downto 0);
  vga_driver_din_f : out std_logic_vector(15 downto 0);
  vga_driver_addr_c : in std_logic_vector(3 downto 0);
  vga_driver_din_c : out std_logic_vector(5 downto 0);
  vga_driver_addr_ci : in std_logic_vector(7 downto 0);
  vga_driver_din_ci : out std_logic_vector(15 downto 0);
  vga_driver_addr_d : in std_logic_vector(8 downto 0);
  vga_driver_din_d : out std_logic_vector(8 downto 0);
  state : out state_type;
  ce : out std_logic;
  threshold : out std_logic_vector(9 downto 0);
  processing_time : out std_logic_vector(31 downto 0);
  capture_time : out std_logic_vector(31 downto 0);
  icr_btn : in std_logic
 );
end component;

component ov7670_capture is
 port (
  clk_100mhz : in std_logic;
  pclk : in std_logic;
  reset : in std_logic;
  vsync : in std_logic;
  href : in std_logic;
  capture : in std_logic;
  threshold : in std_logic_vector(9 downto 0);
  din : in std_logic_vector(7 downto 0);
  cntx : in unsigned(9 downto 0);
  cnty : in unsigned(8 downto 0);
  ce_cntx : out std_logic;
  r_acc : out std_logic;
  dout1 : out std_logic_vector(2 downto 0);
  we1 : out std_logic;
  dout2 : out std_logic;
  we2 : out std_logic;
  finished : out std_logic;
  pixel_clock : out std_logic_vector(7 downto 0)
 );
end component;

component ov7670_controller is
 port (
  clk_100mhz : in std_logic;
  sccb_busy : in std_logic;
  start_config : in std_logic;
  reset : in std_logic;
  send : out std_logic;
  rw : out std_logic;
  addr : out std_logic_vector(7 downto 0);
  data : out std_logic_vector(7 downto 0);
  busy : out std_logic;
  config_finished : out std_logic
 );
end component;

component ov7670_sccb is
 port (
  clk_100mhz : in std_logic;
  reset : in std_logic;
  pwdn_trig : in std_logic;
  send : in std_logic;
  rw : in std_logic;
  addr : in std_logic_vector(7 downto 0);
  din : in std_logic_vector(7 downto 0);
  dout : out std_logic_vector(7 downto 0);
  sioc : out std_logic;
  siod : inout std_logic;
  busy : out std_logic;
  pwdn : out std_logic
 );
end component;

component vga_driver is
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

signal ov7670_sccb_send : std_logic;
signal ov7670_sccb_rw : std_logic;
signal ov7670_sccb_addr : std_logic_vector(7 downto 0);
signal ov7670_sccb_din : std_logic_vector(7 downto 0);
signal ov7670_sccb_busy : std_logic;
signal start_config : std_logic;
signal ov7670_capture_ce_cntx : std_logic;
signal ov7670_capture_r_acc : std_logic;
signal ov7670_capture_dout1 : std_logic_vector(2 downto 0);
signal ov7670_capture_we1 : std_logic;
signal ov7670_capture_dout2 : std_logic;
signal ov7670_capture_we2 : std_logic;
signal ov7670_capture_finished : std_logic;
signal ov7670_controller_config_finished : std_logic;
signal ov7670_controller_busy : std_logic;
signal clk_25mhz : std_logic := '0';
signal clk_50mhz : std_logic := '0';
signal pixel_clock : std_logic_vector(7 downto 0);
signal state_capture_image : std_logic;
signal cntx : unsigned(9 downto 0);
signal cnty : unsigned(8 downto 0);
signal vga_driver_addr1 : std_logic_vector(16 downto 0);
signal vga_driver_din1 : std_logic_vector(2 downto 0);
signal vga_driver_addr2 : std_logic_vector(16 downto 0);
signal vga_driver_din2 : std_logic;
signal vga_driver_addr_py1 : std_logic_vector(7 downto 0);
signal vga_driver_din_py1 : std_logic_vector(8 downto 0);
signal ym1 : std_logic_vector(7 downto 0);
signal y0_1 : std_logic_vector(7 downto 0);
signal y1_1 : std_logic_vector(7 downto 0);
signal vga_driver_addr_px1 : std_logic_vector(8 downto 0);
signal vga_driver_din_px1 : std_logic_vector(7 downto 0);
signal xm1 : std_logic_vector(8 downto 0);
signal xmw1 : std_logic_vector(8 downto 0);
signal x0_1 : std_logic_vector(8 downto 0);
signal x1_1 : std_logic_vector(8 downto 0);
signal vga_driver_addr_px2 : std_logic_vector(8 downto 0);
signal vga_driver_din_px2 : std_logic_vector(7 downto 0);
signal vga_driver_addr_py2 : std_logic_vector(11 downto 0);
signal vga_driver_din_py2 : std_logic_vector(8 downto 0);
signal vga_driver_ym2 : std_logic_vector(7 downto 0);
signal bounds_addr : std_logic_vector(3 downto 0);
signal bounds_count : std_logic_vector(3 downto 0);
signal vga_driver_addr_b : std_logic_vector(3 downto 0);
signal vga_driver_din_bx0 : std_logic_vector(8 downto 0);
signal vga_driver_din_bx1 : std_logic_vector(8 downto 0);
signal vga_driver_din_by0 : std_logic_vector(7 downto 0);
signal vga_driver_din_by1 : std_logic_vector(7 downto 0);
signal vga_driver_addr_f : std_logic_vector(9 downto 0);
signal vga_driver_din_f : std_logic_vector(15 downto 0);
signal vga_driver_addr_c : std_logic_vector(3 downto 0);
signal vga_driver_din_c : std_logic_vector(5 downto 0);
signal vga_driver_addr_ci : std_logic_vector(7 downto 0);
signal vga_driver_din_ci : std_logic_vector(15 downto 0);
signal vga_driver_addr_d : std_logic_vector(8 downto 0);
signal vga_driver_din_d : std_logic_vector(8 downto 0);
signal state : state_type;
signal ce : std_logic;
signal threshold : std_logic_vector(9 downto 0);
signal processing_time : std_logic_vector(31 downto 0);
signal capture_time : std_logic_vector(31 downto 0);
signal icr_btn : std_logic;
begin

 inst_anpr_module: anpr_module port map (
  clk_100mhz => clk_100mhz,
  reset => reset,
  capture => capture,
  pause => pause,
  pause_en => pause_en,
  next_addr => next_addr,
  next_addr_dir => next_addr_dir,
  threshold_nextval => threshold_nextval,
  threshold_nextval_dir => threshold_nextval_dir,
  ov7670_vsync => ov7670_vsync,
  state_capture_image => state_capture_image,
  cntx => cntx,
  cnty => cnty,
  ov7670_capture_ce_cntx => ov7670_capture_ce_cntx,
  ov7670_capture_r_acc => ov7670_capture_r_acc,
  ov7670_capture_dout1 => ov7670_capture_dout1,
  ov7670_capture_we1 => ov7670_capture_we1,
  ov7670_capture_dout2 => ov7670_capture_dout2,
  ov7670_capture_we2 => ov7670_capture_we2,
  ov7670_capture_finished => ov7670_capture_finished,
  vga_driver_addr1 => vga_driver_addr1,
  vga_driver_din1 => vga_driver_din1,
  vga_driver_addr2 => vga_driver_addr2,
  vga_driver_din2 => vga_driver_din2,
  vga_driver_addr_py1 => vga_driver_addr_py1,
  vga_driver_din_py1 => vga_driver_din_py1,
  ym1 => ym1,
  y0_1 => y0_1,
  y1_1 => y1_1,
  vga_driver_addr_px1 => vga_driver_addr_px1,
  vga_driver_din_px1 => vga_driver_din_px1,
  xm1 => xm1,
  xmw1 => xmw1,
  x0_1 => x0_1,
  x1_1 => x1_1,
  vga_driver_addr_px2 => vga_driver_addr_px2,
  vga_driver_din_px2 => vga_driver_din_px2,
  vga_driver_addr_py2 => vga_driver_addr_py2,
  vga_driver_din_py2 => vga_driver_din_py2,
  vga_driver_ym2 => vga_driver_ym2,
  bounds_addr => bounds_addr,
  bounds_count => bounds_count,
  vga_driver_addr_b => vga_driver_addr_b,
  vga_driver_din_bx0 => vga_driver_din_bx0,
  vga_driver_din_bx1 => vga_driver_din_bx1,
  vga_driver_din_by0 => vga_driver_din_by0,
  vga_driver_din_by1 => vga_driver_din_by1,
  vga_driver_addr_f => vga_driver_addr_f,
  vga_driver_din_f => vga_driver_din_f,
  vga_driver_addr_c => vga_driver_addr_c,
  vga_driver_din_c => vga_driver_din_c,
  vga_driver_addr_ci => vga_driver_addr_ci,
  vga_driver_din_ci => vga_driver_din_ci,
  vga_driver_addr_d => vga_driver_addr_d,
  vga_driver_din_d => vga_driver_din_d,
  state => state,
  ce => ce,
  threshold => threshold,
  processing_time => processing_time,
  capture_time => capture_time,
  icr_btn => icr_btn
 );

 inst_ov7670_capture: ov7670_capture port map (
  clk_100mhz => clk_100mhz,
  pclk => ov7670_pclk,
  reset => reset,
  vsync => ov7670_vsync,
  href => ov7670_href,
  capture => state_capture_image,
      threshold => threshold,
  din => ov7670_data,
  cntx => cntx,
  cnty => cnty,
  ce_cntx => ov7670_capture_ce_cntx,
  r_acc => ov7670_capture_r_acc,
  dout1 => ov7670_capture_dout1,
  we1 => ov7670_capture_we1,
  dout2 => ov7670_capture_dout2,
  we2 => ov7670_capture_we2,
  finished => ov7670_capture_finished,
  pixel_clock => pixel_clock
 );
 
 inst_ov7670_controller: ov7670_controller port map (
  clk_100mhz => clk_100mhz,
  reset => reset,
  send => ov7670_sccb_send,
  rw => ov7670_sccb_rw,
  addr => ov7670_sccb_addr,
  data => ov7670_sccb_din,
  sccb_busy => ov7670_sccb_busy,
  start_config => start_config,
  busy => ov7670_controller_busy,
  config_finished => ov7670_controller_config_finished
 );
 
 inst_ov7670_sccb: ov7670_sccb port map (
  clk_100mhz => clk_100mhz,
  reset => reset,
  send => ov7670_sccb_send,
  rw => ov7670_sccb_rw,
  addr => ov7670_sccb_addr,
  din => ov7670_sccb_din,
  busy => ov7670_sccb_busy,
  pwdn_trig => '0',
  dout => open,
  sioc => ov7670_sioc,
  siod => ov7670_siod,
  pwdn => ov7670_pwdn
 );
 
 inst_vga_driver: vga_driver port map (
  clk_100mhz => clk_100mhz,
  reset => reset,
  next_index => next_index,
  next_index_dir => next_index_dir,
  next_pixel => next_pixel,
  next_pixel_ori => next_pixel_ori,
  next_pixel_dir => next_pixel_dir,
  r => vga_r,
  g => vga_g,
  b => vga_b,
  addr1 => vga_driver_addr1,
  din1 => vga_driver_din1,
  addr2 => vga_driver_addr2,
  din2 => vga_driver_din2,
  addr_py1 => vga_driver_addr_py1,
  din_py1 => vga_driver_din_py1,
  ym1 => ym1,
  y0_1 => y0_1,
  y1_1 => y1_1,
  addr_px1 => vga_driver_addr_px1,
  din_px1 => vga_driver_din_px1,
  xm1 => xm1,
  xmw1 => xmw1,
  x0_1 => x0_1,
  x1_1 => x1_1,
  addr_px2 => vga_driver_addr_px2,
  din_px2 => vga_driver_din_px2,
  addr_py2 => vga_driver_addr_py2,
  din_py2 => vga_driver_din_py2,
  ym2 => vga_driver_ym2,
  bounds_addr => bounds_addr,
  bounds_count => bounds_count,
  addr_b => vga_driver_addr_b,
  din_bx0 => vga_driver_din_bx0,
  din_bx1 => vga_driver_din_bx1,
  din_by0 => vga_driver_din_by0,
  din_by1 => vga_driver_din_by1,
  addr_f => vga_driver_addr_f,
  din_f => vga_driver_din_f,
  addr_c => vga_driver_addr_c,
  din_c => vga_driver_din_c,
  addr_ci => vga_driver_addr_ci,
  din_ci => vga_driver_din_ci,
  addr_d => vga_driver_addr_d,
  din_d => vga_driver_din_d,
  state => state,
  ce => ce,
  capture => capture,
  threshold => threshold,
  processing_time => processing_time,
  capture_time => capture_time,
  icr_btn => icr_btn,
  pixel_clock => pixel_clock,
  hs => vga_hs,
  vs => vga_vs,
  active => open
 );

 ov7670_reset_1 <= not reset;
 start_config <= (not ov7670_controller_config_finished) and (not ov7670_controller_busy);
 config_finished <= ov7670_controller_config_finished;
 ov7670_xclk <= clk_25mhz;

 clock_process: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if clk_50mhz = '0' then
    clk_25mhz <= not clk_25mhz;
   end if;
   clk_50mhz <= not clk_50mhz;
  end if;
 end process;
end behavioral;