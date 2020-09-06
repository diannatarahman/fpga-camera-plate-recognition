library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.work_package.all;

entity anpr_module is
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
end anpr_module;

architecture behavioral of anpr_module is
component image_memory is
 port (
  clka : in std_logic;
  wea : in std_logic_vector(0 downto 0);
  addra : in std_logic_vector(16 downto 0);
  dina : in std_logic_vector(2 downto 0);
  douta : out std_logic_vector(2 downto 0);
  clkb : in std_logic;
  web : in std_logic_vector(0 downto 0);
  addrb : in std_logic_vector(16 downto 0);
  dinb : in std_logic_vector(2 downto 0);
  doutb : out std_logic_vector(2 downto 0)
 );
end component;

component bin_image_memory is
 port (
  clka : in std_logic;
  wea : in std_logic_vector(0 downto 0);
  addra : in std_logic_vector(16 downto 0);
  dina : in std_logic_vector(0 downto 0);
  douta : out std_logic_vector(0 downto 0);
  clkb : in std_logic;
  web : in std_logic_vector(0 downto 0);
  addrb : in std_logic_vector(16 downto 0);
  dinb : in std_logic_vector(0 downto 0);
  doutb : out std_logic_vector(0 downto 0)
 );
end component;

component accum_bin_proj is
 port (
  b : in std_logic_vector(0 downto 0);
  clk : in std_logic;
  ce : in std_logic;
  bypass : in std_logic;
  sclr : in std_logic;
  q : out std_logic_vector(8 downto 0)
 );
end component;

component accum_area_projx is
 port (
  b : in std_logic_vector(7 downto 0);
  clk : in std_logic;
  add : in std_logic;
  ce : in std_logic;
  bypass : in std_logic;
  sclr : in std_logic;
  q : out std_logic_vector(16 downto 0)
 );
end component;

component font_memory is
 port (
  clka : in std_logic;
  addra : in std_logic_vector(9 downto 0);
  douta : out std_logic_vector(15 downto 0);
  clkb : in std_logic;
  addrb : in std_logic_vector(9 downto 0);
  doutb : out std_logic_vector(15 downto 0)
 );
end component;

component projx_memory is
 port (
  a : in std_logic_vector(8 downto 0);
  d : in std_logic_vector(7 downto 0);
  dpra : in std_logic_vector(8 downto 0);
  clk : in std_logic;
  we : in std_logic;
  qspo : out std_logic_vector(7 downto 0);
  qdpo : out std_logic_vector(7 downto 0)
 );
end component;

component projy_memory is
 port (
  a : in std_logic_vector(7 downto 0);
  d : in std_logic_vector(8 downto 0);
  dpra : in std_logic_vector(7 downto 0);
  clk : in std_logic;
  we : in std_logic;
  qspo : out std_logic_vector(8 downto 0);
  qdpo : out std_logic_vector(8 downto 0)
 );
end component;

component boundx_memory is
 port (
  a : in std_logic_vector(3 downto 0);
  d : in std_logic_vector(8 downto 0);
  dpra : in std_logic_vector(3 downto 0);
  clk : in std_logic;
  we : in std_logic;
  spo : out std_logic_vector(8 downto 0);
  dpo : out std_logic_vector(8 downto 0);
  qspo : out std_logic_vector(8 downto 0);
  qdpo : out std_logic_vector(8 downto 0)
 );
end component;

component boundy_memory is
 port (
  a : in std_logic_vector(3 downto 0);
  d : in std_logic_vector(7 downto 0);
  dpra : in std_logic_vector(3 downto 0);
  clk : in std_logic;
  we : in std_logic;
  spo : out std_logic_vector(7 downto 0);
  dpo : out std_logic_vector(7 downto 0);
  qspo : out std_logic_vector(7 downto 0);
  qdpo : out std_logic_vector(7 downto 0)
 );
end component;

component resize_memory is
 port (
  a : in std_logic_vector(7 downto 0);
  d : in std_logic_vector(16 downto 0);
  dpra : in std_logic_vector(7 downto 0);
  clk : in std_logic;
  we : in std_logic;
  qspo : out std_logic_vector(16 downto 0);
  qdpo : out std_logic_vector(16 downto 0)
 );
end component;

component line_resize_memory is
 port (
  a : in std_logic_vector(3 downto 0);
  d : in std_logic_vector(8 downto 0);
  dpra : in std_logic_vector(3 downto 0);
  clk : in std_logic;
  we : in std_logic;
  qspo : out std_logic_vector(8 downto 0);
  qdpo : out std_logic_vector(8 downto 0)
 );
end component;

component char_memory is
 port (
  a : in std_logic_vector(3 downto 0);
  d : in std_logic_vector(5 downto 0);
  dpra : in std_logic_vector(3 downto 0);
  clk : in std_logic;
  we : in std_logic;
  qspo : out std_logic_vector(5 downto 0);
  qdpo : out std_logic_vector(5 downto 0)
 );
end component;

component distance_memory is
 port (
  a : in std_logic_vector(8 downto 0);
  d : in std_logic_vector(8 downto 0);
  dpra : in std_logic_vector(8 downto 0);
  clk : in std_logic;
  we : in std_logic;
  qspo : out std_logic_vector(8 downto 0);
  qdpo : out std_logic_vector(8 downto 0)
 );
end component;

component char_images_memory is
 port (
  a : in std_logic_vector(7 downto 0);
  d : in std_logic_vector(15 downto 0);
  dpra : in std_logic_vector(7 downto 0);
  clk : in std_logic;
  we : in std_logic;
  qspo : out std_logic_vector(15 downto 0);
  qdpo : out std_logic_vector(15 downto 0)
 );
end component;

component projy_memory2 is
 port (
  clka : in std_logic;
  wea : in std_logic_vector(0 downto 0);
  addra : in std_logic_vector(11 downto 0);
  dina : in std_logic_vector(8 downto 0);
  douta : out std_logic_vector(8 downto 0);
  clkb : in std_logic;
  web : in std_logic_vector(0 downto 0);
  addrb : in std_logic_vector(11 downto 0);
  dinb : in std_logic_vector(8 downto 0);
  doutb : out std_logic_vector(8 downto 0)
 );
end component;

signal image_memory_wea : std_logic_vector(0 downto 0);
signal image_memory_addra_p, image_memory_addra_n : std_logic_vector(16 downto 0);
signal ce_image_memory_addra, r_image_memory_addra : std_logic;
signal image_memory_addrb : std_logic_vector(16 downto 0);
signal image_memory_dina : std_logic_vector(2 downto 0);
signal image_memory_douta : std_logic_vector(2 downto 0);
signal image_memory_doutb : std_logic_vector(2 downto 0);
signal bin_image_memory_wea : std_logic_vector(0 downto 0);
signal bin_image_memory_addra_p, bin_image_memory_addra_n : std_logic_vector(16 downto 0);
signal ce_bin_image_memory_addra, r_bin_image_memory_addra : std_logic;
signal bin_image_memory_addrb : std_logic_vector(16 downto 0);
signal bin_image_memory_dina : std_logic_vector(0 downto 0);
signal bin_image_memory_douta : std_logic_vector(0 downto 0);
signal bin_image_memory_doutb : std_logic_vector(0 downto 0);
signal accum_bin_proj_b : std_logic_vector(0 downto 0);
signal accum_bin_proj_ce : std_logic;
signal accum_bin_proj_bypass : std_logic;
signal accum_bin_proj_sclr : std_logic;
signal accum_bin_proj_q : std_logic_vector(8 downto 0);
signal accum_area_projx_b : std_logic_vector(7 downto 0);
signal accum_area_projx_add : std_logic;
signal accum_area_projx_ce : std_logic;
signal accum_area_projx_bypass : std_logic;
signal accum_area_projx_sclr : std_logic;
signal accum_area_projx_q : std_logic_vector(16 downto 0);
signal font_memory_addra_p, font_memory_addra_n : std_logic_vector(13 downto 0);
signal ce_font_memory_addra, r_font_memory_addra : std_logic;
signal font_memory_addra_lat1_p, font_memory_addra_lat1_n : std_logic_vector(13 downto 0);
signal ce_font_memory_addra_lat1, r_font_memory_addra_lat1 : std_logic;
signal font_memory_addrb : std_logic_vector(9 downto 0);
signal font_memory_douta : std_logic_vector(15 downto 0);
signal font_memory_doutb : std_logic_vector(15 downto 0);
signal projx_memory1_a : std_logic_vector(8 downto 0);
signal projx_memory1_d : std_logic_vector(7 downto 0);
signal projx_memory1_dpra : std_logic_vector(8 downto 0);
signal projx_memory1_we : std_logic;
signal projx_memory1_qspo : std_logic_vector(7 downto 0);
signal projx_memory1_qdpo : std_logic_vector(7 downto 0);
signal projy_memory1_a : std_logic_vector(7 downto 0);
signal projy_memory1_d : std_logic_vector(8 downto 0);
signal projy_memory1_dpra : std_logic_vector(7 downto 0);
signal projy_memory1_we : std_logic;
signal projy_memory1_qspo : std_logic_vector(8 downto 0);
signal projy_memory1_qdpo : std_logic_vector(8 downto 0);
signal projx_memory2_a : std_logic_vector(8 downto 0);
signal projx_memory2_d : std_logic_vector(7 downto 0);
signal projx_memory2_dpra : std_logic_vector(8 downto 0);
signal projx_memory2_we : std_logic;
signal projx_memory2_qspo : std_logic_vector(7 downto 0);
signal projx_memory2_qdpo : std_logic_vector(7 downto 0);
signal projy_memory2_wea : std_logic_vector(0 downto 0);
signal projy_memory2_addra_p, projy_memory2_addra_n : std_logic_vector(11 downto 0);
signal ce_projy_memory2_addra, r_projy_memory2_addra : std_logic;
signal projy_memory2_addrb : std_logic_vector(11 downto 0);
signal projy_memory2_dina : std_logic_vector(8 downto 0);
signal projy_memory2_douta : std_logic_vector(8 downto 0);
signal projy_memory2_doutb : std_logic_vector(8 downto 0);
signal boundx0_memory_a : std_logic_vector(3 downto 0);
signal boundx0_memory_d : std_logic_vector(8 downto 0);
signal boundx0_memory_dpra : std_logic_vector(3 downto 0);
signal boundx0_memory_we : std_logic;
signal boundx0_memory_spo : std_logic_vector(8 downto 0);
signal boundx0_memory_dpo : std_logic_vector(8 downto 0);
signal boundx0_memory_qspo : std_logic_vector(8 downto 0);
signal boundx0_memory_qdpo : std_logic_vector(8 downto 0);
signal boundx1_memory_a : std_logic_vector(3 downto 0);
signal boundx1_memory_d : std_logic_vector(8 downto 0);
signal boundx1_memory_dpra : std_logic_vector(3 downto 0);
signal boundx1_memory_we : std_logic;
signal boundx1_memory_spo : std_logic_vector(8 downto 0);
signal boundx1_memory_dpo : std_logic_vector(8 downto 0);
signal boundx1_memory_qspo : std_logic_vector(8 downto 0);
signal boundx1_memory_qdpo : std_logic_vector(8 downto 0);
signal boundy0_memory_a : std_logic_vector(3 downto 0);
signal boundy0_memory_d : std_logic_vector(7 downto 0);
signal boundy0_memory_dpra : std_logic_vector(3 downto 0);
signal boundy0_memory_we : std_logic;
signal boundy0_memory_spo : std_logic_vector(7 downto 0);
signal boundy0_memory_dpo : std_logic_vector(7 downto 0);
signal boundy0_memory_qspo : std_logic_vector(7 downto 0);
signal boundy0_memory_qdpo : std_logic_vector(7 downto 0);
signal boundy1_memory_a : std_logic_vector(3 downto 0);
signal boundy1_memory_d : std_logic_vector(7 downto 0);
signal boundy1_memory_dpra : std_logic_vector(3 downto 0);
signal boundy1_memory_we : std_logic;
signal boundy1_memory_spo : std_logic_vector(7 downto 0);
signal boundy1_memory_dpo : std_logic_vector(7 downto 0);
signal boundy1_memory_qspo : std_logic_vector(7 downto 0);
signal boundy1_memory_qdpo : std_logic_vector(7 downto 0);
signal ym2_memory_a : std_logic_vector(3 downto 0);
signal ym2_memory_d : std_logic_vector(7 downto 0);
signal ym2_memory_dpra : std_logic_vector(3 downto 0);
signal ym2_memory_we : std_logic;
signal ym2_memory_spo : std_logic_vector(7 downto 0);
signal ym2_memory_dpo : std_logic_vector(7 downto 0);
signal ym2_memory_qspo : std_logic_vector(7 downto 0);
signal ym2_memory_qdpo : std_logic_vector(7 downto 0);
signal resize_memory_a : std_logic_vector(7 downto 0);
signal resize_memory_d : std_logic_vector(16 downto 0);
signal resize_memory_dpra : std_logic_vector(7 downto 0);
signal resize_memory_we : std_logic;
signal resize_memory_qspo : std_logic_vector(16 downto 0);
signal resize_memory_qdpo : std_logic_vector(16 downto 0);
signal line_resize_memory_a : std_logic_vector(3 downto 0);
signal line_resize_memory_d : std_logic_vector(8 downto 0);
signal line_resize_memory_dpra : std_logic_vector(3 downto 0);
signal line_resize_memory_we : std_logic;
signal line_resize_memory_qspo : std_logic_vector(8 downto 0);
signal line_resize_memory_qdpo : std_logic_vector(8 downto 0);
signal char_memory_a : std_logic_vector(3 downto 0);
signal char_memory_d : std_logic_vector(5 downto 0);
signal char_memory_dpra : std_logic_vector(3 downto 0);
signal char_memory_we : std_logic;
signal char_memory_qspo : std_logic_vector(5 downto 0);
signal char_memory_qdpo : std_logic_vector(5 downto 0);
signal distance_memory_a : std_logic_vector(8 downto 0);
signal distance_memory_d : std_logic_vector(8 downto 0);
signal distance_memory_dpra : std_logic_vector(8 downto 0);
signal distance_memory_we : std_logic;
signal distance_memory_qspo : std_logic_vector(8 downto 0);
signal distance_memory_qdpo : std_logic_vector(8 downto 0);
signal char_images_memory_a : std_logic_vector(7 downto 0);
signal char_images_memory_d : std_logic_vector(15 downto 0);
signal char_images_memory_dpra : std_logic_vector(7 downto 0);
signal char_images_memory_we : std_logic;
signal char_images_memory_qspo : std_logic_vector(15 downto 0);
signal char_images_memory_qdpo : std_logic_vector(15 downto 0);
signal state_p, state_n : state_type;
signal proj_addr_p, proj_addr_n : std_logic_vector(8 downto 0);
signal ce_proj_addr, r_proj_addr : std_logic;
signal bounds_count_p, bounds_count_n : std_logic_vector(3 downto 0);
signal ce_bounds_count, r_bounds_count : std_logic;
signal bounds_addr_p, bounds_addr_n : std_logic_vector(3 downto 0);
signal ce_bounds_addr, r_bounds_addr : std_logic;
signal bounds_addr2_p, bounds_addr2_n : std_logic_vector(3 downto 0);
signal ce_bounds_addr2, r_bounds_addr2 : std_logic;
signal ba_240_p, ba_240_n : std_logic_vector(11 downto 0);
signal ce_ba_240, r_ba_240 : std_logic;
signal ba_36_p, ba_36_n : std_logic_vector(8 downto 0);
signal ce_ba_36, r_ba_36 : std_logic;
signal latch_next_addr : std_logic_vector(7 downto 0);
signal ym1_p, ym1_n : std_logic_vector(7 downto 0);
signal pym1_p, pym1_n : std_logic_vector(8 downto 0);
signal y0_1_p, y0_1_n : std_logic_vector(7 downto 0);
signal y1_1_p, y1_1_n : std_logic_vector(7 downto 0);
signal h1_p, h1_n : std_logic_vector(7 downto 0);
signal h2_p, h2_n : std_logic_vector(7 downto 0);
signal h1sq_p, h1sq_n : std_logic_vector(15 downto 0);
signal y0_1_320_p, y0_1_320_n : std_logic_vector(16 downto 0);
signal y0_2_320_p, y0_2_320_n : std_logic_vector(16 downto 0);
signal wmax_p, wmax_n : std_logic_vector(11 downto 0);
signal wmin_p, wmin_n : std_logic_vector(10 downto 0);
signal ce_ym1, r_ym1 : std_logic;
signal ce_y0_1, r_y0_1 : std_logic;
signal ce_y1_1, r_y1_1 : std_logic;
signal ce_h1, r_h1 : std_logic;
signal ce_h2, r_h2 : std_logic;
signal ce_h1sq, r_h1sq : std_logic;
signal ce_y0_1_320, r_y0_1_320 : std_logic;
signal ce_y0_2_320, r_y0_2_320 : std_logic;
signal ce_w, r_w : std_logic;
signal xm1_p, xm1_n : std_logic_vector(8 downto 0);
signal xmw1_p, xmw1_n : std_logic_vector(8 downto 0);
signal pxm1_p, pxm1_n : std_logic_vector(7 downto 0);
signal axm1_p, axm1_n : std_logic_vector(16 downto 0);
signal x0_1_p, x0_1_n : std_logic_vector(8 downto 0);
signal x1_1_p, x1_1_n : std_logic_vector(8 downto 0);
signal w1_p, w1_n : std_logic_vector(8 downto 0);
signal w2_p, w2_n : std_logic_vector(8 downto 0);
signal ce_xm1, r_xm1 : std_logic;
signal ce_pxm1, r_pxm1 : std_logic;
signal ce_x0_1, r_x0_1 : std_logic;
signal ce_x1_1, r_x1_1 : std_logic;
signal ce_w1, r_w1 : std_logic;
signal ce_w2, r_w2 : std_logic;
signal ym2_p, ym2_n : std_logic_vector(7 downto 0);
signal ym2_2_p, ym2_2_n : std_logic_vector(7 downto 0);
signal pym2_p, pym2_n : std_logic_vector(8 downto 0);
signal ce_ym2, r_ym2 : std_logic;
signal ce_ym2_2, r_ym2_2 : std_logic;
signal ff_p, ff_n : std_logic_vector(5 downto 0);
signal temp_dat1_p, temp_dat1_n : std_logic_vector(8 downto 0);
signal temp_addr1_p, temp_addr1_n : std_logic_vector(16 downto 0);
signal temp_dat2_p, temp_dat2_n : std_logic_vector(8 downto 0);
signal cnty_p, cnty_n : unsigned(8 downto 0);
signal cntx_p, cntx_n : unsigned(9 downto 0);
signal cntyn_p, cntyn_n : unsigned(18 downto 0);
signal cntxn_p, cntxn_n : unsigned(9 downto 0);
signal cntyr_p, cntyr_n : unsigned(3 downto 0);
signal cntxr_p, cntxr_n : unsigned(3 downto 0);
signal ce_cntx, r_cntx : std_logic;
signal ce_cnty, r_cnty : std_logic;
signal ce_cntyn, r_cntyn : std_logic;
signal ce_cntxn, r_cntxn : std_logic;
signal ce_cntyr, r_cntyr : std_logic;
signal ce_cntxr, r_cntxr : std_logic;
signal rx1_p, rx1_n : std_logic_vector(8 downto 0);
signal rx2_p, rx2_n : std_logic_vector(8 downto 0);
signal ry1_p, ry1_n : std_logic_vector(7 downto 0);
signal ry2_p, ry2_n : std_logic_vector(7 downto 0);
signal ce_rx1, r_rx1 : std_logic;
signal ce_rx2, r_rx2 : std_logic;
signal ce_ry1, r_ry1 : std_logic;
signal ce_ry2, r_ry2 : std_logic;
signal dm_p, dm_n : std_logic_vector(8 downto 0);
signal dc_addr_p, dc_addr_n : std_logic_vector(5 downto 0);
signal cdm_p, cdm_n : std_logic_vector(5 downto 0);
signal ce_dm, r_dm : std_logic;
signal ce_dc_addr, r_dc_addr : std_logic;
signal status_active : std_logic_vector(0 downto 0);
signal ce_p, ce_n : std_logic;
signal latch_pause : std_logic_vector(7 downto 0);
signal threshold_p, threshold_n : std_logic_vector(9 downto 0);
signal ce_threshold, r_threshold : std_logic;
signal latch_threshold_nextval : std_logic_vector(7 downto 0);
signal hold_ti_p, hold_ti_n : unsigned(25 downto 0);
signal hold_td_p, hold_td_n : unsigned(25 downto 0);
signal ce_hold_ti, r_hold_ti : std_logic;
signal ce_hold_td, r_hold_td : std_logic;
signal time_count_p, time_count_n : std_logic_vector(31 downto 0);
signal ce_time_count_digit, r_time_count_digit : std_logic_vector(7 downto 0);
signal processing_time_p, processing_time_n : std_logic_vector(31 downto 0);
signal ce_processing_time, r_processing_time : std_logic;
signal capture_time_p, capture_time_n : std_logic_vector(31 downto 0);
signal ce_capture_time, r_capture_time : std_logic;
begin

 inst_image_memory: image_memory port map (
  clka => clk_100mhz,
  clkb => clk_100mhz,
  wea => image_memory_wea,
  web => (others => '0'),
  addra => image_memory_addra_p,
  addrb => image_memory_addrb,
  dina => image_memory_dina,
  dinb => (others => '0'),
  douta => image_memory_douta,
  doutb => image_memory_doutb
 );

 inst_bin_image_memory: bin_image_memory port map (
  clka => clk_100mhz,
  clkb => clk_100mhz,
  wea => bin_image_memory_wea,
  web => (others => '0'),
  addra => bin_image_memory_addra_p,
  addrb => bin_image_memory_addrb,
  dina => bin_image_memory_dina,
  dinb => (others => '0'),
  douta => bin_image_memory_douta,
  doutb => bin_image_memory_doutb
 );

 inst_accum_bin_proj: accum_bin_proj port map (
  b => accum_bin_proj_b,
  clk => clk_100mhz,
  ce => accum_bin_proj_ce,
  bypass => accum_bin_proj_bypass,
  sclr => accum_bin_proj_sclr,
  q => accum_bin_proj_q
 );

 inst_accum_area_projx: accum_area_projx port map (
  b => accum_area_projx_b,
  clk => clk_100mhz,
  add => accum_area_projx_add,
  ce => accum_area_projx_ce,
  bypass => accum_area_projx_bypass,
  sclr => accum_area_projx_sclr,
  q => accum_area_projx_q
 );

 inst_font_memory: font_memory port map (
  clka => clk_100mhz,
  addra => font_memory_addra_lat1_p(13 downto 4),
  douta => font_memory_douta,
  clkb => clk_100mhz,
  addrb => font_memory_addrb,
  doutb => font_memory_doutb
 );

 inst_projx_memory1: projx_memory port map (
  a => projx_memory1_a,
  d => projx_memory1_d,
  dpra => projx_memory1_dpra,
  clk => clk_100mhz,
  we => projx_memory1_we,
  qspo => projx_memory1_qspo,
  qdpo => projx_memory1_qdpo
 );

 inst_projy_memory1: projy_memory port map (
  a => projy_memory1_a,
  d => projy_memory1_d,
  dpra => projy_memory1_dpra,
  clk => clk_100mhz,
  we => projy_memory1_we,
  qspo => projy_memory1_qspo,
  qdpo => projy_memory1_qdpo
 );

 inst_projx_memory2: projx_memory port map (
  a => projx_memory2_a,
  d => projx_memory2_d,
  dpra => projx_memory2_dpra,
  clk => clk_100mhz,
  we => projx_memory2_we,
  qspo => projx_memory2_qspo,
  qdpo => projx_memory2_qdpo
 );

  inst_projy_memory2: projy_memory2 port map (
   clka => clk_100mhz,
   clkb => clk_100mhz,
   wea => projy_memory2_wea,
   web => (others => '0'),
   addra => projy_memory2_addra_p,
   addrb => projy_memory2_addrb,
   dina => projy_memory2_dina,
   dinb => (others => '0'),
   douta => projy_memory2_douta,
   doutb => projy_memory2_doutb
  );

 inst_boundx0_memory: boundx_memory port map (
  a => boundx0_memory_a,
  d => boundx0_memory_d,
  dpra => boundx0_memory_dpra,
  clk => clk_100mhz,
  we => boundx0_memory_we,
  spo => boundx0_memory_spo,
  dpo => boundx0_memory_dpo,
  qspo => boundx0_memory_qspo,
  qdpo => boundx0_memory_qdpo
 );

 inst_boundx1_memory: boundx_memory port map (
  a => boundx1_memory_a,
  d => boundx1_memory_d,
  dpra => boundx1_memory_dpra,
  clk => clk_100mhz,
  we => boundx1_memory_we,
  spo => boundx1_memory_spo,
  dpo => boundx1_memory_dpo,
  qspo => boundx1_memory_qspo,
  qdpo => boundx1_memory_qdpo
 );

 inst_boundy0_memory: boundy_memory port map (
  a => boundy0_memory_a,
  d => boundy0_memory_d,
  dpra => boundy0_memory_dpra,
  clk => clk_100mhz,
  we => boundy0_memory_we,
  spo => boundy0_memory_spo,
  dpo => boundy0_memory_dpo,
  qspo => boundy0_memory_qspo,
  qdpo => boundy0_memory_qdpo
 );

 inst_boundy1_memory: boundy_memory port map (
  a => boundy1_memory_a,
  d => boundy1_memory_d,
  dpra => boundy1_memory_dpra,
  clk => clk_100mhz,
  we => boundy1_memory_we,
  spo => boundy1_memory_spo,
  dpo => boundy1_memory_dpo,
  qspo => boundy1_memory_qspo,
  qdpo => boundy1_memory_qdpo
 );

 inst_ym2_memory: boundy_memory port map (
  a => ym2_memory_a,
  d => ym2_memory_d,
  dpra => ym2_memory_dpra,
  clk => clk_100mhz,
  we => ym2_memory_we,
  spo => ym2_memory_spo,
  dpo => ym2_memory_dpo,
  qspo => ym2_memory_qspo,
  qdpo => ym2_memory_qdpo
 );

 inst_resize_memory: resize_memory port map (
  a => resize_memory_a,
  d => resize_memory_d,
  dpra => resize_memory_dpra,
  clk => clk_100mhz,
  we => resize_memory_we,
  qspo => resize_memory_qspo,
  qdpo => resize_memory_qdpo
 );

 inst_line_resize_memory: line_resize_memory port map (
  a => line_resize_memory_a,
  d => line_resize_memory_d,
  dpra => line_resize_memory_dpra,
  clk => clk_100mhz,
  we => line_resize_memory_we,
  qspo => line_resize_memory_qspo,
  qdpo => line_resize_memory_qdpo
 );

 inst_char_memory: char_memory port map (
  a => char_memory_a,
  d => char_memory_d,
  dpra => char_memory_dpra,
  clk => clk_100mhz,
  we => char_memory_we,
  qspo => char_memory_qspo,
  qdpo => char_memory_qdpo
 );

 inst_distance_memory: distance_memory port map (
  a => distance_memory_a,
  d => distance_memory_d,
  dpra => distance_memory_dpra,
  clk => clk_100mhz,
  we => distance_memory_we,
  qspo => distance_memory_qspo,
  qdpo => distance_memory_qdpo
 );

 inst_char_images_memory: char_images_memory port map (
  a => char_images_memory_a,
  d => char_images_memory_d,
  dpra => char_images_memory_dpra,
  clk => clk_100mhz,
  we => char_images_memory_we,
  qspo => char_images_memory_qspo,
  qdpo => char_images_memory_qdpo
 );

 boundx0_memory_dpra <= vga_driver_addr_b;
 boundx1_memory_dpra <= vga_driver_addr_b;
 boundy0_memory_dpra <= vga_driver_addr_b;
 boundy1_memory_dpra <= vga_driver_addr_b;
 ym2_memory_dpra <= bounds_addr2_p;
 resize_memory_dpra <= (others => '0');
 line_resize_memory_dpra <= (others => '0');
 image_memory_addrb <= vga_driver_addr1;
 bin_image_memory_addrb <= vga_driver_addr2;
 projy_memory1_dpra <= vga_driver_addr_py1;
 projx_memory1_dpra <= vga_driver_addr_px1;
 projx_memory2_dpra <= vga_driver_addr_px2;
 projy_memory2_addrb <= vga_driver_addr_py2;
 font_memory_addrb <= vga_driver_addr_f;
 char_memory_dpra <= vga_driver_addr_c;
 char_images_memory_dpra <= vga_driver_addr_ci;
 distance_memory_dpra <=vga_driver_addr_d;

 clock_process: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' then
    latch_pause <= (others => '0');
    latch_next_addr <= (others => '0');
    latch_threshold_nextval <= (others => '0');
    ce_p <= '0';
   else
    latch_pause <= latch_pause(6 downto 0) & pause;
    latch_next_addr <= latch_next_addr(6 downto 0) & next_addr;
    latch_threshold_nextval <= latch_threshold_nextval(6 downto 0) & threshold_nextval;
    ce_p <= ce_n;
   end if;
   if reset = '1' then
    state_p <= idle;
   elsif ce_p = '1' then
    state_p <= state_n;
   end if;
   if reset = '1' or r_ym1 = '1' then
    ym1_p <= (others => '0');
    pym1_p <= (others => '0');
   elsif ce_ym1 = '1' then
    ym1_p <= ym1_n;
    pym1_p <= pym1_n;
   end if;
   if reset = '1' or r_y0_1 = '1' then
    y0_1_p <= (others => '0');
   elsif ce_y0_1 = '1' then
    y0_1_p <= y0_1_n;
   end if;
   if reset = '1' or r_y1_1 = '1' then
    y1_1_p <= (others => '0');
   elsif ce_y1_1 = '1' then
    y1_1_p <= y1_1_n;
   end if;
   if reset = '1' or r_h1 = '1' then
    h1_p <= (others => '0');
   elsif ce_h1 = '1' then
    h1_p <= h1_n;
   end if;
   if reset = '1' or r_h2 = '1' then
    h2_p <= (others => '0');
   elsif ce_h2 = '1' then
    h2_p <= h2_n;
   end if;
   if reset = '1' or r_h1sq = '1' then
    h1sq_p <= (others => '0');
   elsif ce_h1sq = '1' then
    h1sq_p <= h1sq_n;
   end if;
   if reset = '1' or r_y0_1_320 = '1' then
    y0_1_320_p <= (others => '0');
   elsif ce_y0_1_320 = '1' then
    y0_1_320_p <= y0_1_320_n;
   end if;
   if reset = '1' or r_y0_2_320 = '1' then
    y0_2_320_p <= (others => '0');
   elsif ce_y0_2_320 = '1' then
    y0_2_320_p <= y0_2_320_n;
   end if;
   if reset = '1' or r_w = '1' then
    wmax_p <= (others => '0');
    wmin_p <= (others => '0');
   elsif ce_w = '1' then
    wmax_p <= wmax_n;
    wmin_p <= wmin_n;
   end if;
   if reset = '1' or r_xm1 = '1' then
    xm1_p <= (others => '0');
    xmw1_p <= "100111111";
    axm1_p <= (others => '0');
   elsif ce_xm1 = '1' then
    xm1_p <= xm1_n;
    xmw1_p <= xmw1_n;
    axm1_p <= axm1_n;
   end if;
   if reset = '1' or r_pxm1 = '1' then
    pxm1_p <= (others => '0');
   elsif ce_pxm1 = '1' then
    pxm1_p <= pxm1_n;
   end if;
   if reset = '1' or r_x0_1 = '1' then
    x0_1_p <= (others => '0');
   elsif ce_x0_1 = '1' then
    x0_1_p <= x0_1_n;
   end if;
   if reset = '1' or r_x1_1 = '1' then
    x1_1_p <= (others => '0');
   elsif ce_x1_1 = '1' then
    x1_1_p <= x1_1_n;
   end if;
   if reset = '1' or r_w1 = '1' then
    w1_p <= (others => '0');
   elsif ce_w1 = '1' then
    w1_p <= w1_n;
   end if;
   if reset = '1' or r_w2 = '1' then
    w2_p <= (others => '0');
   elsif ce_w2 = '1' then
    w2_p <= w2_n;
   end if;
   if reset = '1' or r_ym2 = '1' then
    ym2_p <= (others => '0');
    pym2_p <= (others => '0');
   elsif ce_ym2 = '1' then
    ym2_p <= ym2_n;
    pym2_p <= pym2_n;
   end if;
   if reset = '1' or r_ym2_2 = '1' then
    ym2_2_p <= (others => '0');
   elsif ce_ym2_2 = '1' then
    ym2_2_p <= ym2_2_n;
   end if;
   if reset = '1' then
    ff_p <= (others => '0');
    temp_dat1_p <= (others => '0');
    temp_addr1_p <= (others => '0');
    temp_dat2_p <= (others => '0');
   elsif ce_p = '1' then
    ff_p <= ff_n;
    temp_dat1_p <= temp_dat1_n;
    temp_addr1_p <= temp_addr1_n;
    temp_dat2_p <= temp_dat2_n;
   end if;
   if reset = '1' or r_proj_addr = '1' then
    proj_addr_p <= (others => '0');
   elsif ce_proj_addr = '1' then
    proj_addr_p <= proj_addr_n;
   end if;
   if reset = '1' or r_bounds_count = '1' then
    bounds_count_p <= (others => '0');
   elsif ce_bounds_count = '1' then
    bounds_count_p <= bounds_count_n;
   end if;
   if reset = '1' or r_bounds_addr = '1' then
    bounds_addr_p <= (others => '0');
   elsif ce_bounds_addr = '1' then
    bounds_addr_p <= bounds_addr_n;
   end if;
   if reset = '1' or r_bounds_addr2 = '1' then
    bounds_addr2_p <= (others => '0');
   elsif ce_bounds_addr2 = '1' then
    bounds_addr2_p <= bounds_addr2_n;
   end if;
   if reset = '1' or r_ba_240 = '1' then
    ba_240_p <= (others => '0');
   elsif ce_ba_240 = '1' then
    ba_240_p <= ba_240_n;
   end if;
   if reset = '1' or r_ba_36 = '1' then
    ba_36_p <= (others => '0');
   elsif ce_ba_36 = '1' then
    ba_36_p <= ba_36_n;
   end if;
   if reset = '1' or r_image_memory_addra = '1' then
    image_memory_addra_p <= (others => '0');
   elsif ce_image_memory_addra = '1' then
    image_memory_addra_p <= image_memory_addra_n;
   end if;
   if reset = '1' or r_bin_image_memory_addra = '1' then
    bin_image_memory_addra_p <= (others => '0');
   elsif ce_bin_image_memory_addra = '1' then
    bin_image_memory_addra_p <= bin_image_memory_addra_n;
   end if;
   if reset = '1' or r_font_memory_addra = '1' then
    font_memory_addra_p <= (others => '0');
   elsif ce_font_memory_addra = '1' then
    font_memory_addra_p <= font_memory_addra_n;
   end if;
   if reset = '1' or r_font_memory_addra_lat1 = '1' then
    font_memory_addra_lat1_p <= (others => '0');
   elsif ce_font_memory_addra_lat1 = '1' then
    font_memory_addra_lat1_p <= font_memory_addra_lat1_n;
   end if;
   if reset = '1' or r_projy_memory2_addra = '1' then
    projy_memory2_addra_p <= (others => '0');
   elsif ce_projy_memory2_addra = '1' then
    projy_memory2_addra_p <= projy_memory2_addra_n;
   end if;
   if reset = '1' or r_cnty = '1' then
    cnty_p <= (others => '0');
   elsif ce_cnty = '1' then
    cnty_p <= cnty_n;
   end if;
   if reset = '1' or r_cntx = '1' then
    cntx_p <= (others => '0');
   elsif ce_cntx = '1' then
    cntx_p <= cntx_n;
   end if;
   if reset = '1' or r_cntyn = '1' then
    cntyn_p <= (others => '0');
   elsif ce_cntyn = '1' then
    cntyn_p <= cntyn_n;
   end if;
   if reset = '1' or r_cntxn = '1' then
    cntxn_p <= (others => '0');
   elsif ce_cntxn = '1' then
    cntxn_p <= cntxn_n;
   end if;
   if reset = '1' or r_cntyr = '1' then
    cntyr_p <= (others => '0');
   elsif ce_cntyr = '1' then
    cntyr_p <= cntyr_n;
   end if;
   if reset = '1' or r_cntxr = '1' then
    cntxr_p <= (others => '0');
   elsif ce_cntxr = '1' then
    cntxr_p <= cntxr_n;
   end if;
   if reset = '1' or r_rx1 = '1' then
    rx1_p <= (others => '0');
   elsif ce_rx1 = '1' then
    rx1_p <= rx1_n;
   end if;
   if reset = '1' or r_rx2 = '1' then
    rx2_p <= (others => '0');
   elsif ce_rx2 = '1' then
    rx2_p <= rx2_n;
   end if;
   if reset = '1' or r_ry1 = '1' then
    ry1_p <= (others => '0');
   elsif ce_ry1 = '1' then
    ry1_p <= ry1_n;
   end if;
   if reset = '1' or r_ry2 = '1' then
    ry2_p <= (others => '0');
   elsif ce_ry2 = '1' then
    ry2_p <= ry2_n;
   end if;
   if reset = '1' or r_dm = '1' then
    dm_p <= (others => '0');
    cdm_p <= (others => '0');
   elsif ce_dm = '1' then
    dm_p <= dm_n;
    cdm_p <= cdm_n;
   end if;
   if reset = '1' or r_dc_addr = '1' then
    dc_addr_p <= (others => '0');
   elsif ce_dc_addr = '1' then
    dc_addr_p <= dc_addr_n;
   end if;
   if reset = '1' or r_hold_ti = '1' then
    hold_ti_p <= (others => '0');
   elsif ce_hold_ti = '1' then
    hold_ti_p <= hold_ti_n;
   end if;
   if reset = '1' or r_hold_td = '1' then
    hold_td_p <= (others => '0');
   elsif ce_hold_td = '1' then
    hold_td_p <= hold_td_n;
   end if;
   if reset = '1' or r_threshold = '1' then
    threshold_p <= "0011000000";
   elsif ce_threshold = '1' then
    threshold_p <= threshold_n;
   end if;
   for i in 0 to 7 loop
    if reset = '1' or r_time_count_digit(i) = '1' then
     time_count_p((i*4)+3 downto i*4) <= (others => '0');
    elsif ce_time_count_digit(i) = '1' then
     time_count_p((i*4)+3 downto i*4) <= time_count_n((i*4)+3 downto i*4);
    end if;
   end loop;
   if reset = '1' or r_processing_time = '1' then
    processing_time_p <= (others => '0');
   elsif ce_processing_time = '1' then
    processing_time_p <= processing_time_n;
   end if;
   if reset = '1' or r_capture_time = '1' then
    capture_time_p <= (others => '0');
   elsif ce_capture_time = '1' then
    capture_time_p <= capture_time_n;
   end if;
  end if;
 end process;

 next_state_process: process(capture, reset, pause_en, latch_pause, ov7670_vsync, ov7670_capture_finished, state_p, proj_addr_p, latch_next_addr, latch_threshold_nextval, next_addr_dir, threshold_nextval_dir, threshold_p, hold_ti_p, hold_td_p, image_memory_addrb, cntx_p, cnty_p, cntxn_p, cntyn_p, cntxr_p, cntyr_p, ce_p, rx1_p, rx2_p, ry1_p, ry2_p, image_memory_addra_p, bin_image_memory_addra_p, font_memory_addra_p, font_memory_addra_lat1_p, projy_memory2_addra_p, ov7670_capture_we1, ov7670_capture_dout1, ov7670_capture_r_acc, ov7670_capture_we2, ov7670_capture_dout2, ov7670_capture_ce_cntx, projx_memory1_qspo, projx_memory2_qspo, projy_memory1_qspo, projy_memory2_douta, boundx0_memory_qspo, boundx1_memory_qspo, boundy0_memory_qspo, boundy1_memory_qspo, ym2_memory_qspo, resize_memory_qspo, line_resize_memory_qspo, char_memory_qspo, distance_memory_qspo, char_images_memory_qspo, bin_image_memory_douta, image_memory_douta, font_memory_douta, ym1_p, pym1_p, y0_1_p, y1_1_p, h1_p, h2_p, h1sq_p, y0_1_320_p, y0_2_320_p, wmax_p, wmin_p, bounds_count_p, bounds_addr_p, bounds_addr2_p, ba_240_p, ba_36_p, xm1_p, xmw1_p, pxm1_p, axm1_p, x0_1_p, x1_1_p, w1_p, w2_p, ym2_p, ym2_2_p, pym2_p, ff_p, temp_dat1_p, temp_addr1_p, temp_dat2_p, time_count_p, processing_time_p, accum_bin_proj_q, accum_area_projx_q, dm_p, cdm_p, dc_addr_p, icr_btn)
 variable bool_temp1, bool_temp2 : boolean := false;
 variable int_temp1, int_temp2 : integer := 0;
 variable temp1 : std_logic_vector(11 downto 0) := (others => '0');
 begin
  --default:
  state_n <= state_p;
  accum_bin_proj_b <= (others => '0');
  accum_bin_proj_ce <= '0';
  accum_bin_proj_bypass <= '0';
  accum_bin_proj_sclr <= reset;
  accum_area_projx_b <= (others => '0');
  accum_area_projx_add <= '1';
  accum_area_projx_ce <= '0';
  accum_area_projx_bypass <= '0';
  accum_area_projx_sclr <= reset;
  image_memory_wea <= (others => '0');
  image_memory_addra_n <= std_logic_vector(unsigned(image_memory_addra_p)+1);
  ce_image_memory_addra <= '0';
  r_image_memory_addra <= '0';
  image_memory_dina <= (others => '0');
  bin_image_memory_wea <= (others => '0');
  bin_image_memory_addra_n <= std_logic_vector(unsigned(bin_image_memory_addra_p)+1);
  ce_bin_image_memory_addra <= '0';
  r_bin_image_memory_addra <= '0';
  bin_image_memory_dina <= (others => '0');
  font_memory_addra_n <= std_logic_vector(unsigned(font_memory_addra_p)+1);
  ce_font_memory_addra <= '0';
  r_font_memory_addra <= '0';
  font_memory_addra_lat1_n <= font_memory_addra_p;
  ce_font_memory_addra_lat1 <= ce_p;
  r_font_memory_addra_lat1 <= '0';
  proj_addr_n <= std_logic_vector(unsigned(proj_addr_p)+1);
  ce_proj_addr <= '0';
  r_proj_addr <= '0';
  bounds_count_n <= std_logic_vector(unsigned(bounds_count_p)+1);
  ce_bounds_count <= '0';
  r_bounds_count <= '0';
  bounds_addr_n <= std_logic_vector(unsigned(bounds_addr_p)+1);
  ce_bounds_addr <= '0';
  r_bounds_addr <= '0';
  bounds_addr2_n <= bounds_addr2_p;
  ce_bounds_addr2 <= '0';
  r_bounds_addr2 <= '0';
  ba_240_n <= std_logic_vector(unsigned(ba_240_p)+240);
  ce_ba_240 <= '0';
  r_ba_240 <= '0';
  ba_36_n <= std_logic_vector(unsigned(ba_36_p)+36);
  ce_ba_36 <= '0';
  r_ba_36 <= '0';
  projx_memory1_a <= (others => '0');
  projx_memory1_d <= (others => '0');
  projx_memory1_we <= '0';
  projy_memory1_a <= (others => '0');
  projy_memory1_d <= (others => '0');
  projy_memory1_we <= '0';
  projx_memory2_a <= (others => '0');
  projx_memory2_d <= (others => '0');
  projx_memory2_we <= '0';
  projy_memory2_wea <= (others => '0');
  projy_memory2_addra_n <= std_logic_vector(unsigned(projy_memory2_addra_p)+1);
  ce_projy_memory2_addra <= '0';
  r_projy_memory2_addra <= '0';
  projy_memory2_dina <= (others => '0');
  boundx0_memory_a <= (others => '0');
  boundx0_memory_d <= (others => '0');
  boundx0_memory_we <= '0';
  boundx1_memory_a <= (others => '0');
  boundx1_memory_d <= (others => '0');
  boundx1_memory_we <= '0';
  boundy0_memory_a <= (others => '0');
  boundy0_memory_d <= (others => '0');
  boundy0_memory_we <= '0';
  boundy1_memory_a <= (others => '0');
  boundy1_memory_d <= (others => '0');
  boundy1_memory_we <= '0';
  ym2_memory_a <= (others => '0');
  ym2_memory_d <= (others => '0');
  ym2_memory_we <= '0';
  resize_memory_a <= (others => '0');
  resize_memory_d <= (others => '0');
  resize_memory_we <= '0';
  line_resize_memory_a <= (others => '0');
  line_resize_memory_d <= (others => '0');
  line_resize_memory_we <= '0';
  char_memory_a <= (others => '0');
  char_memory_d <= (others => '0');
  char_memory_we <= '0';
  distance_memory_a <= (others => '0');
  distance_memory_d <= (others => '0');
  distance_memory_we <= '0';
  char_images_memory_a <= (others => '0');
  char_images_memory_d <= (others => '0');
  char_images_memory_we <= '0';
  cnty_n <= cnty_p+1;
  cntx_n <= cntx_p+1;
  cntyn_n <= cntyn_p+320;
  cntxn_n <= cntxn_p+1;
  cntyr_n <= cntyr_p+1;
  cntxr_n <= cntxr_p+1;
  ce_cnty <= '0';
  r_cnty <= '0';
  ce_cntx <= '0';
  r_cntx <= '0';
  ce_cntyn <= '0';
  r_cntyn <= '0';
  ce_cntxn <= '0';
  r_cntxn <= '0';
  ce_cntyr <= '0';
  r_cntyr <= '0';
  ce_cntxr <= '0';
  r_cntxr <= '0';
  rx1_n <= rx1_p;
  rx2_n <= rx2_p;
  ry1_n <= ry1_p;
  ry2_n <= ry2_p;
  ce_rx1 <= '0';
  r_rx1 <= '0';
  ce_rx2 <= '0';
  r_rx2 <= '0';
  ce_ry1 <= '0';
  r_ry1 <= '0';
  ce_ry2 <= '0';
  r_ry2 <= '0';
  ym1_n <= ym1_p;
  pym1_n <= pym1_p;
  y0_1_n <= y0_1_p;
  y1_1_n <= y1_1_p;
  h1_n <= h1_p;
  h2_n <= h2_p;
  h1sq_n <= h1sq_p;
  y0_1_320_n <= y0_1_320_p;
  y0_2_320_n <= y0_2_320_p;
  wmax_n <= wmax_p;
  wmin_n <= wmin_p;
  ce_ym1 <= '0';
  r_ym1 <= '0';
  ce_y0_1 <= '0';
  r_y0_1 <= '0';
  ce_y1_1 <= '0';
  r_y1_1 <= '0';
  ce_h1 <= '0';
  r_h1 <= '0';
  ce_h2 <= '0';
  r_h2 <= '0';
  ce_h1sq <= '0';
  r_h1sq <= '0';
  ce_y0_1_320 <= '0';
  r_y0_1_320 <= '0';
  ce_y0_2_320 <= '0';
  r_y0_2_320 <= '0';
  ce_w <= '0';
  r_w <= '0';
  xm1_n <= xm1_p;
  xmw1_n <= xmw1_p;
  pxm1_n <= pxm1_p;
  axm1_n <= axm1_p;
  x0_1_n <= x0_1_p;
  x1_1_n <= x1_1_p;
  w1_n <= w1_p;
  w2_n <= w2_p;
  ff_n <= (others => '0');
  temp_dat1_n <= (others => '0');
  temp_addr1_n <= (others => '0');
  temp_dat2_n <= (others => '0');
  ce_xm1 <= '0';
  r_xm1 <= '0';
  ce_pxm1 <= '0';
  r_pxm1 <= '0';
  ce_x0_1 <= '0';
  r_x0_1 <= '0';
  ce_x1_1 <= '0';
  r_x1_1 <= '0';
  ce_w1 <= '0';
  r_w1 <= '0';
  ce_w2 <= '0';
  r_w2 <= '0';
  ym2_n <= ym2_p;
  pym2_n <= pym2_p;
  ce_ym2 <= '0';
  r_ym2 <= '0';
  ym2_2_n <= ym2_2_p;
  ce_ym2_2 <= '0';
  r_ym2_2 <= '0';
  dm_n <= dm_p;
  cdm_n <= cdm_p;
  ce_dm <= '0';
  r_dm <= '0';
  dc_addr_n <= std_logic_vector(unsigned(dc_addr_p)+1);
  ce_dc_addr <= '0';
  r_dc_addr <= '0';
  ce_n <= ce_p;
  threshold_n <= threshold_p;
  ce_threshold <= '0';
  r_threshold <= '0';
  hold_ti_n <= hold_ti_p+1;
  ce_hold_ti <= latch_threshold_nextval(0);
  r_hold_ti <= not latch_threshold_nextval(0);
  if hold_ti_p = 5e7 then
   ce_hold_ti <= '0';
  end if;
  hold_td_n <= hold_td_p+1;
  ce_hold_td <= latch_threshold_nextval(0);
  r_hold_td <= not latch_threshold_nextval(0);
  if hold_td_p = 5e7 then
   ce_hold_td <= '0';
  end if;
  for i in 0 to 7 loop
   time_count_n((i*4)+3 downto i*4) <= std_logic_vector(unsigned(time_count_p((i*4)+3 downto i*4))+1);
   ce_time_count_digit <= (others => '0');
   r_time_count_digit <= (others => '0');
  end loop;
  if state_p /= idle then
   ce_time_count_digit(0) <= ce_p;
  end if;
  if time_count_p(3 downto 0) = x"9" then
   ce_time_count_digit(1) <= ce_p;
   r_time_count_digit(0) <= ce_p;
  end if;
  if time_count_p(7 downto 0) = x"99" then
   ce_time_count_digit(2) <= ce_p;
   r_time_count_digit(1) <= ce_p;
  end if;
  if time_count_p(11 downto 0) = x"999" then
   ce_time_count_digit(3) <= ce_p;
   r_time_count_digit(2) <= ce_p;
  end if;
  if time_count_p(15 downto 0) = x"9999" then
   ce_time_count_digit(4) <= ce_p;
   r_time_count_digit(3) <= ce_p;
  end if;
  if time_count_p(19 downto 0) = x"99999" then
   ce_time_count_digit(5) <= ce_p;
   r_time_count_digit(4) <= ce_p;
  end if;
  if time_count_p(23 downto 0) = x"999999" then
   ce_time_count_digit(6) <= ce_p;
   r_time_count_digit(5) <= ce_p;
  end if;
  if time_count_p(27 downto 0) = x"9999999" then
   ce_time_count_digit(7) <= ce_p;
   r_time_count_digit(6) <= ce_p;
  end if;
  if time_count_p(31 downto 0) = x"99999999" then
   r_time_count_digit(7) <= ce_p;
  end if;
  processing_time_n <= time_count_p;
  ce_processing_time <= '0';
  r_processing_time <= '0';
  capture_time_n <= time_count_p;
  ce_capture_time <= '0';
  r_capture_time <= '0';

  --main:
  if latch_next_addr = "00001111" then
   if next_addr_dir = '1' then
    bounds_addr2_n <= std_logic_vector(unsigned(bounds_addr2_p)+1);
    if unsigned(bounds_addr2_p) = 9 then
     r_bounds_addr2 <= '1';
    else
     ce_bounds_addr2 <= '1';
    end if;
   else
    ce_bounds_addr2 <= '1';
    if unsigned(bounds_addr2_p) = 0 then
     bounds_addr2_n <= "1001";
    else
     bounds_addr2_n <= std_logic_vector(unsigned(bounds_addr2_p)-1);
    end if;
   end if;
  end if;

  if latch_threshold_nextval = "00001111" or (hold_ti_p = 5e7 and icr_btn = '1') then
   ce_threshold <= '1';
   if threshold_nextval_dir = '1' then
    threshold_n <= std_logic_vector(unsigned(threshold_p)+1);
   else
    threshold_n <= std_logic_vector(unsigned(threshold_p)-1);
   end if;
  end if;

  case state_p is
   when idle =>
    if capture = '1' then
     state_n <= capture_image;
     r_time_count_digit <= (others => ce_p);
     if pause_en = '1' then
      ce_n <= '0';
     end if;
    end if;
    if ff_p(0) = '1' then
     ce_processing_time <= ce_p;
    end if;
   when capture_image =>
    if ov7670_vsync = '1' or ov7670_capture_finished = '1' then
     r_image_memory_addra <= '1';
     r_bin_image_memory_addra <= '1';
     r_cnty <= '1';
     r_cntx <= '1';
    end if;
    if ov7670_vsync = '1' then
     r_ym1 <= '1';
     r_h1 <= '1';
     r_h1sq <= '1';
     r_proj_addr <= '1';
    end if;
    ce_cntx <= ov7670_capture_ce_cntx;
    if cntx_p = 639 and ov7670_capture_ce_cntx = '1' then
     ce_cnty <= '1';
     r_cntx <= '1';
    end if;
    image_memory_wea(0) <= ov7670_capture_we1;
    ce_image_memory_addra <= ov7670_capture_we1;
    image_memory_dina <= ov7670_capture_dout1;
    bin_image_memory_wea(0) <= ov7670_capture_we2;
    ce_bin_image_memory_addra <= ov7670_capture_we2;
    bin_image_memory_dina(0) <= ov7670_capture_dout2;
    accum_bin_proj_b(0) <= ov7670_capture_dout2;
    accum_bin_proj_ce <= ov7670_capture_we2;
    accum_bin_proj_sclr <= reset or ov7670_vsync or ov7670_capture_r_acc or ov7670_capture_finished;
    projy_memory1_we <= ov7670_capture_r_acc;
    ce_proj_addr <= ov7670_capture_r_acc;
    projy_memory1_a <= proj_addr_p(7 downto 0);
    projy_memory1_d <= accum_bin_proj_q;
    ym1_n <= proj_addr_p(7 downto 0);
    pym1_n <= accum_bin_proj_q;
    bool_temp1 := unsigned(accum_bin_proj_q) > unsigned(pym1_p);
    h1_n <= std_logic_vector(unsigned(h1_p)+1);
    if bool_temp1 then
     y0_1_n <= proj_addr_p(7 downto 0);
     y1_1_n <= proj_addr_p(7 downto 0);
    else
     y0_1_n <= ym1_p;
     y1_1_n <= ym1_p;
    end if;
    if ov7670_capture_r_acc = '1' then
     if bool_temp1 then
      ce_ym1 <= '1';
     end if;
    end if;
    if ov7670_capture_finished = '1' then
     state_n <= y0_first;
     if pause_en = '1' then
      ce_n <= '0';
     end if;
     ce_y0_1 <= '1';
     ce_y1_1 <= '1';
     ce_h1 <= '1';
     ce_proj_addr <= '1';
     if bool_temp1 then
      proj_addr_n <= std_logic_vector(unsigned(proj_addr_p)-1);
     else
      proj_addr_n <= "0" & std_logic_vector(unsigned(ym1_p)-1);
     end if;
     r_cntxn <= '1';
    end if;
   when y0_first =>
    y0_1_n <= std_logic_vector(unsigned(y0_1_p)-1);
    h1_n <= std_logic_vector(unsigned(h1_p)+1);
    if unsigned(proj_addr_p) = unsigned(ym1_p)-1 then
     r_time_count_digit <= (others => ce_p);
     r_time_count_digit(0) <= '0';
     ce_time_count_digit(0) <= ce_p;
     time_count_n(3 downto 0) <= "0001";
     ce_capture_time <= ce_p;
    else
     ce_y0_1 <= ce_p;
     ce_h1 <= ce_p;
    end if;
    ce_proj_addr <= ce_p;
    proj_addr_n <= std_logic_vector(unsigned(proj_addr_p)-1);
    projy_memory1_a <= proj_addr_p(7 downto 0);
    bool_temp1 := unsigned(y0_1_p) = 0;
    bool_temp2 := unsigned(projy_memory1_qspo) <= unsigned(pym1_p)/4;
    y0_1_320_n <= std_logic_vector(to_unsigned(to_integer(unsigned(y0_1_p))*320, 17));
    if unsigned(proj_addr_p) /= unsigned(ym1_p)-1 and (bool_temp1 or bool_temp2) then
     state_n <= y1_first;
     if pause_en = '1' then
      ce_n <= '0';
     end if;
     ce_y0_1 <= '0';
     ce_y0_1_320 <= ce_p;
     ce_h1 <= '0';
     proj_addr_n <= "0" & std_logic_vector(unsigned(ym1_p)+1);
    end if;
   when y1_first =>
    y1_1_n <= std_logic_vector(unsigned(y1_1_p)+1);
    h1_n <= std_logic_vector(unsigned(h1_p)+1);
    if unsigned(proj_addr_p) /= unsigned(ym1_p)+1 then
     ce_y1_1 <= ce_p;
     ce_h1 <= ce_p;
    end if;
    ce_proj_addr <= ce_p;
    projy_memory1_a <= proj_addr_p(7 downto 0);
    bool_temp1 := unsigned(y1_1_p) = 239;
    bool_temp2 := unsigned(projy_memory1_qspo) <= unsigned(pym1_p)/4;
    cnty_n <= "0" & unsigned(y0_1_p);
    bin_image_memory_addra_n <= y0_1_320_p;
    h1sq_n <= std_logic_vector(to_unsigned(to_integer(unsigned(h1_p))*to_integer(unsigned(h1_p)),16));
    wmax_n <= std_logic_vector(to_unsigned(to_integer(unsigned(h1_p))*25/2,12));
    wmin_n <= std_logic_vector(to_unsigned(to_integer(unsigned(h1_p))*5,11));
    if unsigned(proj_addr_p) /= unsigned(ym1_p)+1 and (bool_temp1 or bool_temp2) then
     state_n <= px1;
     if pause_en = '1' then
      ce_n <= '0';
     end if;
     ce_y1_1 <= '0';
     ce_h1 <= '0';
     ce_h1sq <= ce_p;
     r_w1 <= ce_p;
     r_xm1 <= ce_p;
     r_pxm1 <= ce_p;
     ce_cnty <= ce_p;
     ce_bin_image_memory_addra <= ce_p;
     ce_w <= ce_p;
     r_proj_addr <= ce_p;
     ce_cntxn <= ce_p;
     if unsigned(h1_p) < 4 then
      state_n <= idle;
     end if;
    end if;
   when px1 =>
    ff_n(4 downto 1) <= ff_p(3 downto 0);
    ff_n(0) <= '0';
    ce_cnty <= ce_p;
    ce_bin_image_memory_addra <= ce_p;
    bin_image_memory_addra_n <= std_logic_vector(unsigned(bin_image_memory_addra_p)+320);
    temp_dat1_n <= temp_dat1_p;
    if cnty_p = unsigned(y1_1_p) then
     ce_cntx <= ce_p;
     ce_cntxn <= ce_p;
     cnty_n <= "0" & unsigned(y0_1_p);
     bin_image_memory_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(y0_1_320_p))+to_integer(cntxn_p),17));
     ff_n(0) <= '1';
    end if;
    accum_bin_proj_b <= bin_image_memory_douta;
    if bin_image_memory_addra_p /= y0_1_320_p then
     accum_bin_proj_ce <= ce_p;
    end if;
    accum_area_projx_b <= accum_bin_proj_q(7 downto 0);
    projx_memory1_a <= proj_addr_p;
    projx_memory1_d <= accum_bin_proj_q(7 downto 0);
    if unsigned(proj_addr_p) <= unsigned(wmax_p) then
     temp1 := (others => '0');
    else
     temp1 := std_logic_vector(unsigned(proj_addr_p)-unsigned(wmax_p));
    end if;
    w1_n <= std_logic_vector(unsigned(w1_p)+1);
    xm1_n <= temp1(8 downto 0);
    xmw1_n <= std_logic_vector(unsigned(proj_addr_p)-1);
    pxm1_n <= accum_bin_proj_q(7 downto 0);
    axm1_n <= accum_area_projx_q;
    bool_temp1 := unsigned(accum_bin_proj_q(7 downto 0)) > unsigned(pxm1_p);
    bool_temp2 := unsigned(accum_area_projx_q) > unsigned(axm1_p);
    if ff_p(1) = '1' then
     if unsigned(ff_p(4 downto 2)) /= 0 then
      ce_cnty <= '0';
      ce_bin_image_memory_addra <= '0';
      ce_cntx <= '0';
      ce_cntxn <= '0';
      accum_bin_proj_ce <= '0';
      ff_n(1 downto 0) <= ff_p(1 downto 0);
     else
      accum_bin_proj_bypass <= '1';
      ce_proj_addr <= ce_p;
      ce_w1 <= ce_p;
      if unsigned(w1_p) = unsigned(wmax_p) then
       ce_w1 <= '0';
      end if;
      if unsigned(proj_addr_p) > unsigned(wmax_p) then
       temp_dat1_n <= std_logic_vector(unsigned(temp_dat1_p)+1);
      end if;
      projx_memory1_we <= ce_p;
      accum_area_projx_ce <= ce_p;
      if bool_temp1 then
       ce_pxm1 <= ce_p;
      end if;
     end if;
    end if;
    if ff_p(2) = '1' and cntx_p > unsigned(wmax_p) then
     projx_memory1_a <= temp_dat1_p;
    end if;
    if ff_p(3) = '1' and cntx_p > unsigned(wmax_p) then
     accum_area_projx_b <= projx_memory1_qspo;
     accum_area_projx_add <= '0';
     accum_area_projx_ce <= ce_p;
    end if;
    if ff_p(4) = '1' then
     if cntx_p >= unsigned(wmax_p) then
      if bool_temp2 then
       ce_xm1 <= ce_p;
      end if;
     end if;
     if cntx_p = 320 then
      r_bin_image_memory_addra <= ce_p;
      r_cnty <= ce_p;
      r_cntx <= ce_p;
      r_cntxn <= ce_p;
      ce_proj_addr <= ce_p;
      state_n <= x_first;
      if pause_en = '1' then
       ce_n <= '0';
      end if;
      ce_x0_1 <= ce_p;
      ce_x1_1 <= ce_p;
      if bool_temp2 then
       proj_addr_n <= temp1(8 downto 0);
      else
       proj_addr_n <= xm1_p;
      end if;
      accum_bin_proj_sclr <= ce_p or reset;
      accum_area_projx_sclr <= ce_p or reset;
      temp_dat1_n <= (others => '0');
      ff_n <= (others => '0');
     end if;
    end if;
    if bool_temp2 then
     x0_1_n <= temp1(8 downto 0);
     x1_1_n <= std_logic_vector(unsigned(proj_addr_p)-1);
    else
     x0_1_n <= xm1_p;
     x1_1_n <= xmw1_p;
    end if;
   when x_first =>
    ff_n(3) <= ff_p(3);
    ff_n(2) <= '1';
    ff_n(1 downto 0) <= ff_p(1 downto 0);
    x0_1_n <= std_logic_vector(unsigned(x0_1_p)+1);
    x1_1_n <= std_logic_vector(unsigned(x1_1_p)-1);
    w1_n <= std_logic_vector(unsigned(w1_p)-1);
    ce_proj_addr <= ce_p;
    if ff_p(2) = '1' then
     ce_w1 <= ce_p;
     if ff_p(3) = '0' then
      ce_x0_1 <= ce_p;
     else
      ce_x1_1 <= ce_p;
     end if;
    end if;
    if ff_p(3) = '1' then
     proj_addr_n <= std_logic_vector(unsigned(proj_addr_p)-1);
    end if;
    projx_memory1_a <= proj_addr_p;
    bool_temp1 := unsigned(projx_memory1_qspo) >= unsigned(pxm1_p)/8;
    if ff_p(2) = '1' and bool_temp1 then
     if ff_p(3) = '0' then
      ff_n(0) <= '1';
      ce_x0_1 <= '0';
     else
      ff_n(1) <= '1';
      ce_x1_1 <= '0';
     end if;
     ce_w1 <= '0';
     if (ff_p(3) = '0' and ff_p(1) = '1') or (ff_p(3) = '1' and ff_p(0) = '1') then
      state_n <= x_second;
      if pause_en = '1' then
       ce_n <= '0';
      end if;
      ce_cntx <= ce_p;
      ce_cnty <= ce_p;
      ce_cntxn <= ce_p;
      proj_addr_n <= x0_1_p;
      ce_image_memory_addra <= ce_p;
      ff_n <= (others => '0');
      r_bounds_count <= ce_p;
      r_ba_240 <= ce_p;
     end if;
    end if;
    if ff_p(2) = '1' and ((ff_p(3) = '0' and ff_p(1) = '0') or (ff_p(3) = '1' and ff_p(0) = '0')) then
     ff_n(3) <= not ff_p(3);
     ff_n(2) <= '0';
     if ff_p(3) = '0' then
      proj_addr_n <= x1_1_p;
     else
      proj_addr_n <= x0_1_p;
     end if;
    end if;
    bool_temp2 := unsigned(w1_p) < unsigned(wmin_p);
    if bool_temp2 then
     state_n <= idle;
     if pause_en = '1' then
      ce_n <= '0';
     end if;
    end if;
    cntx_n <= "0" & unsigned(x0_1_p);
    cnty_n <= "0" & unsigned(y0_1_p);
    cntxn_n <= "0" & (unsigned(x0_1_p)+1);
    image_memory_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(y0_1_320_p))+to_integer(unsigned(x0_1_p)),17));
   when x_second =>
    ff_n(5) <= '0';
    ff_n(4) <= ff_p(4);
    ff_n(3 downto 1) <= ff_p(2 downto 0);
    ff_n(0) <= '0';
    ce_cnty <= ce_p;
    ce_image_memory_addra <= ce_p;
    image_memory_addra_n <= std_logic_vector(unsigned(image_memory_addra_p)+320);
    if cnty_p = unsigned(y1_1_p) then
     ce_cntx <= ce_p;
     ce_cntxn <= ce_p;
     cnty_n <= "0" & unsigned(y0_1_p);
     image_memory_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(y0_1_320_p))+to_integer(cntxn_p),17));
     ff_n(0) <= '1';
    end if;
    accum_bin_proj_b(0) <= image_memory_douta(2);
    if not (cntx_p = unsigned(x0_1_p) and cnty_p = unsigned(y0_1_p)) then
     accum_bin_proj_ce <= ce_p;
    end if;
    accum_area_projx_b <= accum_bin_proj_q(7 downto 0);
    if ff_p(4) = '0' then
     accum_area_projx_bypass <= '1';
    end if;
    projx_memory2_a <= proj_addr_p;
    projx_memory2_d <= accum_bin_proj_q(7 downto 0);
    boundx0_memory_a <= bounds_count_p;
    boundx1_memory_a <= bounds_count_p;
    boundx0_memory_d <= proj_addr_p;
    boundx1_memory_d <= proj_addr_p;
    bool_temp1 := unsigned(accum_bin_proj_q) > unsigned(h1_p)/16;
    bool_temp2 := unsigned(accum_area_projx_q) > unsigned(h1sq_p)*3/32 and unsigned(accum_area_projx_q) <= unsigned(h1sq_p);
    if ff_p(1) = '1' then
     if unsigned(ff_p(3 downto 2)) /= 0 then
      ce_cnty <= '0';
      ce_image_memory_addra <= '0';
      ce_cntx <= '0';
      ce_cntxn <= '0';
      accum_bin_proj_ce <= '0';
      ff_n(1 downto 0) <= ff_p(1 downto 0);
     else
      accum_bin_proj_bypass <= '1';
      ce_proj_addr <= ce_p;
      projx_memory2_we <= ce_p;
      accum_area_projx_ce <= ce_p;
      if bool_temp1 then
       if ff_p(4) = '0' then
        ff_n(4) <= '1';
        boundx0_memory_we <= ce_p;
       end if;
       boundx1_memory_we <= ce_p;
      else
       ff_n(5) <= '1';
      end if;
     end if;
    end if;
    if ff_p(2) = '1' then
     if ff_p(4) = '1' and (ff_p(5) = '1' or unsigned(proj_addr_p) = unsigned(x1_1_p)+1) then
      if pause_en = '1' then
       ce_n <= '0';
      end if;
      if bool_temp2 then
       state_n <= py2;
       accum_bin_proj_sclr <= ce_p or reset;
       accum_area_projx_sclr <= ce_p or reset;
       ce_cntx <= ce_p;
       ce_cnty <= ce_p;
       ce_cntyn <= ce_p;
       ce_proj_addr <= ce_p;
       ce_projy_memory2_addra <= ce_p;
       temp_dat1_n <= proj_addr_p;
       ff_n <= (others => '0');
       ce_image_memory_addra <= ce_p;
       cntx_n <= "0" & unsigned(boundx0_memory_qspo);
       proj_addr_n <= "0" & y0_1_p;
       projy_memory2_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(ba_240_p))+to_integer(unsigned(y0_1_p)),12));
       cnty_n <= "0" & unsigned(y0_1_p);
       cntyn_n <= to_unsigned(to_integer(unsigned(y0_1_320_p))+320,19);
       image_memory_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(y0_1_320_p))+to_integer(unsigned(boundx0_memory_qspo)),17));
       r_ym2 <= ce_p;
       r_h2 <= ce_p;
      else
       ff_n(4) <= '0';
      end if;
     end if;
    end if;
    if ff_p(3) = '1' and (unsigned(proj_addr_p) = unsigned(x1_1_p)+1 or unsigned(bounds_count_p) = 10) then
     state_n <= init_res;
     if pause_en = '1' then
      ce_n <= '0';
     end if;
     r_image_memory_addra <= ce_p;
     r_cnty <= ce_p;
     r_cntx <= ce_p;
     r_cntxn <= ce_p;
     r_proj_addr <= ce_p;
     accum_bin_proj_sclr <= ce_p or reset;
     accum_area_projx_sclr <= ce_p or reset;
     resize_memory_we <= ce_p;
     line_resize_memory_we <= ce_p;
     r_bounds_addr <= ce_p;
     r_ba_36 <= ce_p;
     ff_n <= (others => '0');
     if unsigned(bounds_count_p) = 0 then
      state_n <= idle;
     end if;
    end if;
   when py2 =>
    ff_n(1) <= ff_p(0);
    ff_n(0) <= '0';
    ce_cntx <= ce_p;
    temp_dat1_n <= temp_dat1_p;
    ce_image_memory_addra <= ce_p;
    boundx0_memory_a <= bounds_count_p;
    boundx1_memory_a <= bounds_count_p;
    ym2_memory_a <= bounds_count_p;
    if cntx_p = unsigned(boundx1_memory_qspo) then
     ce_cnty <= ce_p;
     ce_cntyn <= ce_p;
     cntx_n <= "0" & unsigned(boundx0_memory_qspo);
     image_memory_addra_n <= std_logic_vector(to_unsigned(to_integer(cntyn_p)+to_integer(unsigned(boundx0_memory_qspo)),17));
     ff_n(0) <= '1';
    end if;
    accum_bin_proj_b(0) <= image_memory_douta(2);
    if not (cntx_p = unsigned(boundx0_memory_qspo) and cnty_p = unsigned(y0_1_p)) then
     accum_bin_proj_ce <= ce_p;
    end if;
    projy_memory2_dina <= accum_bin_proj_q;
    ym2_n <= proj_addr_p(7 downto 0);
    pym2_n <= accum_bin_proj_q;
    h2_n <= std_logic_vector(unsigned(h2_p)+1);
    bool_temp1 := unsigned(accum_bin_proj_q) > unsigned(pym2_p);
    if bool_temp1 then
     temp_dat2_n <= proj_addr_p;
     ym2_memory_d <= proj_addr_p(7 downto 0);
    else
     temp_dat2_n <= "0" & ym2_p;
     ym2_memory_d <= ym2_p;
    end if;
    if ff_p(1) = '1' then
     accum_bin_proj_bypass <= '1';
     ce_proj_addr <= ce_p;
     ce_projy_memory2_addra <= ce_p;
     projy_memory2_wea(0) <= ce_p;
     if bool_temp1 then
      ce_ym2 <= ce_p;
     end if;
     if cnty_p = unsigned(y1_1_p)+1 then
      r_image_memory_addra <= ce_p;
      ce_h2 <= ce_p;
      r_cnty <= ce_p;
      r_cntyn <= ce_p;
      r_cntx <= ce_p;
      ce_proj_addr <= ce_p;
      ce_projy_memory2_addra <= ce_p;
      ym2_memory_we <= ce_p;
      if bool_temp1 then
       proj_addr_n <= std_logic_vector(unsigned(proj_addr_p)-1);
       projy_memory2_addra_n <= std_logic_vector(unsigned(projy_memory2_addra_p)-1);
      else
       proj_addr_n <= "0" & std_logic_vector(unsigned(ym2_p)-1);
       projy_memory2_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(ba_240_p))+to_integer(unsigned(ym2_p)) - 1,12));
      end if;
      state_n <= y0_second;
      if pause_en = '1' then
       ce_n <= '0';
      end if;
      accum_bin_proj_sclr <= ce_p or reset;
      ff_n <= (others => '0');
     end if;
    end if;
   when y0_second =>
    temp_dat1_n <= temp_dat1_p;
    boundy0_memory_a <= bounds_count_p;
    temp_dat2_n <= temp_dat2_p;
    boundy0_memory_d <= temp_dat2_p(7 downto 0);
    h2_n <= std_logic_vector(unsigned(h2_p)+1);
    if unsigned(proj_addr_p) /= unsigned(ym2_p)-1 then
     temp_dat2_n <= std_logic_vector(unsigned(temp_dat2_p)-1);
     ce_h2 <= ce_p;
    end if;
    ce_proj_addr <= ce_p;
    ce_projy_memory2_addra <= ce_p;
    proj_addr_n <= std_logic_vector(unsigned(proj_addr_p)-1);
    projy_memory2_addra_n <= std_logic_vector(unsigned(projy_memory2_addra_p)-1);
    bool_temp1 := unsigned(temp_dat2_p(7 downto 0)) = unsigned(y0_1_p);
    bool_temp2 := unsigned(projy_memory2_douta) <= unsigned(pym2_p)/16;
    if unsigned(proj_addr_p) /= unsigned(ym2_p)-1 and (bool_temp1 or bool_temp2) then
     state_n <= y1_second;
     if pause_en = '1' then
      ce_n <= '0';
     end if;
     boundy0_memory_we <= ce_p;
     ce_h2 <= '0';
     temp_dat2_n <= "0" & ym2_p;
     proj_addr_n <= "0" & std_logic_vector(unsigned(ym2_p)+1);
     projy_memory2_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(ba_240_p))+to_integer(unsigned(ym2_p)) + 1,12));
    end if;
   when y1_second =>
    temp_dat1_n <= temp_dat1_p;
    boundx1_memory_a <= bounds_count_p;
    boundy0_memory_a <= bounds_count_p;
    boundy1_memory_a <= bounds_count_p;
    temp_dat2_n <= temp_dat2_p;
    boundy1_memory_d <= temp_dat2_p(7 downto 0);
    h2_n <= std_logic_vector(unsigned(h2_p)+1);
    if unsigned(proj_addr_p) /= unsigned(ym2_p)+1 then
     temp_dat2_n <= std_logic_vector(unsigned(temp_dat2_p)+1);
     ce_h2 <= ce_p;
    end if;
    ce_proj_addr <= ce_p;
    ce_projy_memory2_addra <= ce_p;
    bool_temp1 := unsigned(temp_dat2_p(7 downto 0)) = unsigned(y1_1_p);
    bool_temp2 := unsigned(projy_memory2_douta) <= unsigned(pym2_p)/16;
    cntx_n <= "0" & unsigned(temp_dat1_p);
    cnty_n <= "0" & unsigned(y0_1_p);
    cntxn_n <= "0" & (unsigned(temp_dat1_p)+1);
    image_memory_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(y0_1_320_p))+to_integer(unsigned(temp_dat1_p)),17));
    if unsigned(proj_addr_p) /= unsigned(ym2_p)+1 and (bool_temp1 or bool_temp2) then
     state_n <= x_second;
     if pause_en = '1' then
      ce_n <= '0';
     end if;
     r_projy_memory2_addra <= ce_p;
     boundy1_memory_we <= ce_p;
     ce_h2 <= '0';
     ce_cntx <= ce_p;
     ce_cnty <= ce_p;
     ce_cntxn <= ce_p;
     ce_proj_addr <= ce_p;
     proj_addr_n <= temp_dat1_p;
     temp_dat1_n <= (others => '0');
     temp_dat2_n <= (others => '0');
     ce_image_memory_addra <= ce_p;
     ff_n <= "001000";
     if unsigned(h2_p) > unsigned(h1_p)/2 then
      ce_bounds_count <= ce_p;
      ce_ba_240 <= ce_p;
     end if;
    end if;
   when init_res =>
    resize_memory_a <= std_logic_vector(cntyr_p & cntxr_p);
    boundy0_memory_a <= bounds_addr_p;
    boundy1_memory_a <= bounds_addr_p;
    boundx0_memory_a <= bounds_addr_p;
    boundx1_memory_a <= bounds_addr_p;
    h2_n <= std_logic_vector(unsigned(temp_dat1_p(7 downto 0))+1);
    w2_n <= std_logic_vector(unsigned(temp_dat2_p)+1);
    ry2_n <= std_logic_vector(unsigned(temp_dat1_p(7 downto 0))+1);
    cnty_n <= "0" & unsigned(boundy0_memory_qspo);
    cntyn_n <= to_unsigned(to_integer(unsigned(y0_2_320_p))+320,19);
    y0_2_320_n <= std_logic_vector(to_unsigned(to_integer(unsigned(boundy0_memory_qspo))*320, 17));
    cntx_n <= "0" & unsigned(boundx0_memory_qspo);
    image_memory_addra_n <= std_logic_vector(to_unsigned(to_integer(unsigned(y0_2_320_p))+to_integer(unsigned(boundx0_memory_qspo)),17));
    if unsigned(bounds_addr_p) = unsigned(bounds_count_p) then
     state_n <= idle;
     ff_n(0) <= '1';
     if pause_en = '1' then
      ce_n <= '0';
     end if;
    else
     ce_cntxr <= ce_p;
     if cntxr_p = 15 then
      ce_cntyr <= ce_p;
      if cntyr_p = 15 then
       state_n <= res;
      end if;
     end if;
     resize_memory_we <= ce_p;
     temp_dat1_n <= "0" & std_logic_vector(unsigned(boundy1_memory_qspo)-unsigned(boundy0_memory_qspo));
     ce_h2 <= ce_p;
     temp_dat2_n <= std_logic_vector(unsigned(boundx1_memory_qspo)-unsigned(boundx0_memory_qspo));
     ce_w2 <= ce_p;
     r_ry1 <= ce_p;
     ce_ry2 <= ce_p;
     ce_cnty <= ce_p;
     ce_cntyn <= ce_p;
     ce_y0_2_320 <= ce_p;
     ce_cntx <= ce_p;
     ce_image_memory_addra <= ce_p;
    end if;
   when init_l_res =>
    ce_cntxr <= ce_p;
    if cntxr_p = 15 then
     state_n <= l_res;
    end if;
    line_resize_memory_we <= ce_p;
    line_resize_memory_a <= std_logic_vector(cntxr_p);
    r_rx1 <= ce_p;
    ce_rx2 <= ce_p;
    rx2_n <= w2_p;
   when res =>
    ce_ry1 <= ce_p;
    if unsigned(ry1_p) = 0 then
     ry1_n <= "00010000";
     state_n <= init_l_res;
    else
     ce_ry2 <= ce_p;
     if unsigned(ry1_p) < unsigned(ry2_p) then
      ry1_n <= (others => '0');
      ry2_n <= std_logic_vector(unsigned(ry2_p)-unsigned(ry1_p));
      temp_dat1_n <= "0" & ry1_p;
     else
      ry1_n <= std_logic_vector(unsigned(ry1_p)-unsigned(ry2_p));
      ry2_n <= (others => '0');
      temp_dat1_n <= "0" & ry2_p;
     end if;
     state_n <= l_res2;
    end if;
   when l_res =>
    ff_n(0) <= ff_p(0);
    temp_dat1_n <= temp_dat1_p;
    boundx0_memory_a <= bounds_addr_p;
    line_resize_memory_a <= std_logic_vector(cntxr_p);
    if unsigned(rx1_p) = 0 then
     ce_rx1 <= ce_p;
     rx1_n <= "000010000";
     ce_image_memory_addra <= ce_p;
     ff_n(0) <= image_memory_douta(2);
     ce_cntx <= ce_p;
    else
     ce_rx1 <= ce_p;
     ce_rx2 <= ce_p;
     if unsigned(rx1_p) < unsigned(rx2_p) then
      rx1_n <= (others => '0');
      rx2_n <= std_logic_vector(unsigned(rx2_p)-unsigned(rx1_p));
      if ff_p(0) = '1' then
       temp_dat1_n <= std_logic_vector(unsigned(temp_dat1_p)+unsigned(rx1_p));
      end if;
     else
      rx1_n <= std_logic_vector(unsigned(rx1_p)-unsigned(rx2_p));
      rx2_n <= w2_p;
      ce_cntxr <= ce_p;
      ff_n(1) <= '0';
      if cntxr_p = 15 then
       state_n <= res;
       ce_cntx <= ce_p;
       ce_cnty <= ce_p;
       ce_cntyn <= ce_p;
       ce_image_memory_addra <= ce_p;
       cntx_n <= "0" & unsigned(boundx0_memory_qspo);
       image_memory_addra_n <= std_logic_vector(to_unsigned(to_integer(cntyn_p)+to_integer(unsigned(boundx0_memory_qspo)),17));
       ff_n <= (others => '0');
      end if;
      line_resize_memory_we <= ce_p;
      line_resize_memory_d <= temp_dat1_p;
      temp_dat1_n <= (others => '0');
      if ff_p(0) = '1' then
       line_resize_memory_d <= std_logic_vector(unsigned(temp_dat1_p)+unsigned(rx2_p));
      end if;
     end if;
    end if;
   when l_res2 =>
    ff_n <= std_logic_vector(unsigned(ff_p)+1);
    temp_dat1_n <= temp_dat1_p;
    boundy0_memory_a <= bounds_addr_p;
    boundy1_memory_a <= bounds_addr_p;
    resize_memory_a <= std_logic_vector(cntyr_p & cntxr_p);
    line_resize_memory_a <= std_logic_vector(cntxr_p);
    temp_addr1_n <= std_logic_vector(to_unsigned(to_integer(unsigned(temp_dat1_p(7 downto 0)))*to_integer(unsigned(line_resize_memory_qspo)),17));
    resize_memory_d <= std_logic_vector(unsigned(resize_memory_qspo)+unsigned(temp_addr1_p));
    if unsigned(ff_p) = 2 then
     ff_n <= (others => '0');
     resize_memory_we <= ce_p;
     ce_cntxr <= ce_p;
     if cntxr_p = 15 then
      state_n <= res;
      if unsigned(ry2_p) = 0 then
       ce_ry2 <= ce_p;
       ry2_n <= h2_p;
       ce_cntyr <= ce_p;
       if cntyr_p = 15 then
        state_n <= dist;
        if pause_en = '1' then
         ce_n <= '0';
        end if;
        r_image_memory_addra <= ce_p;
        r_cnty <= ce_p;
        r_cntyn <= ce_p;
        r_cntx <= ce_p;
        temp_dat1_n <= (others => '0');
        temp_addr1_n <= std_logic_vector(to_unsigned(to_integer(unsigned(w2_p))*to_integer(unsigned(h2_p)),17));
        r_font_memory_addra <= ce_p;
       end if;
      end if;
     end if;
    end if;
   when dist =>
    if pause_en = '1' then
     ce_n <= '0';
    end if;
    ff_n(1) <= not ff_p(1);
    temp_addr1_n <= temp_addr1_p;
    if ff_p(1) = '1' then
     ce_font_memory_addra <= ce_p;
    end if;
    temp_dat1_n <= std_logic_vector(to_unsigned(to_integer(unsigned(ba_36_p))+to_integer(unsigned(font_memory_addra_p(13 downto 8))),9));
    resize_memory_a <= font_memory_addra_p(7 downto 0);
    distance_memory_a <= temp_dat1_p;
    distance_memory_d <= std_logic_vector(unsigned(distance_memory_qspo)+1);
    char_images_memory_a <= bounds_addr_p & font_memory_addra_lat1_p(7 downto 4);
    char_images_memory_d <= char_images_memory_qspo;
    char_images_memory_d(to_integer(unsigned(font_memory_addra_lat1_p(3 downto 0)))) <= ff_p(0);
    dm_n <= distance_memory_qspo;
    cdm_n <= std_logic_vector(unsigned(font_memory_addra_lat1_p(13 downto 8))-1);
    if unsigned(font_memory_addra_lat1_p(7 downto 0)) = 0 then
     distance_memory_d <= "000000000";
    end if;
    char_memory_a <= bounds_addr_p;
    if unsigned(resize_memory_qspo) < unsigned(temp_addr1_p)/2 then
     ff_n(0) <= '0';
    else
     ff_n(0) <= '1';
    end if;
    if unsigned(font_memory_addra_p) /= 0 and ff_p(1) = '0' then
     if ff_p(0) = '1' xor font_memory_douta(to_integer(unsigned(font_memory_addra_lat1_p(3 downto 0)))) = '1' then
      distance_memory_we <= ce_p;
      if unsigned(font_memory_addra_lat1_p(7 downto 0)) = 0 then
       distance_memory_d <= "000000001";
      end if;
     end if;
     if unsigned(font_memory_addra_lat1_p(7 downto 0)) = 0 then
      distance_memory_we <= ce_p;
     end if;
     char_images_memory_we <= ce_p;
    end if;
    if unsigned(font_memory_addra_p) = 9216 then
     state_n <= dm;
     temp_addr1_n <= (others => '0');
     temp_dat1_n <= ba_36_p;
     ff_n <= (others => '0');
     r_font_memory_addra <= ce_p;
     ce_dm <= ce_p;
     char_memory_we <= ce_p;
     r_dc_addr <= ce_p;
    end if;
   when dm =>
    ce_dc_addr <= ce_p;
    temp_dat1_n <= std_logic_vector(unsigned(temp_dat1_p)+1);
    char_memory_a <= bounds_addr_p;
    char_memory_d <= std_logic_vector(unsigned(dc_addr_p)-1);
    distance_memory_a <= temp_dat1_p;
    dm_n <= distance_memory_qspo;
    cdm_n <= std_logic_vector(unsigned(dc_addr_p)-1);
    bool_temp1 := unsigned(distance_memory_qspo) < unsigned(dm_p);
    if unsigned(dc_addr_p) /= 0 and bool_temp1 then
     char_memory_we <= ce_p;
     ce_dm <= ce_p;
    end if;
    if unsigned(dc_addr_p) = 36 then
     r_dc_addr <= ce_p;
     temp_dat1_n <= (others => '0');
     ce_bounds_addr <= ce_p;
     ce_ba_36 <= ce_p;
     state_n <= init_res;
     if pause_en = '1' then
      ce_n <= '0';
     end if;
    end if;
  end case;

  if pause_en = '0' or latch_pause = "00001111" then
   ce_n <= '1';
  end if;
 end process;

 output_process: process(state_p, threshold_p, cntx_p, cnty_p, ym1_p, y0_1_p, y1_1_p, xm1_p, xmw1_p, x0_1_p, x1_1_p, bounds_addr2_p, bounds_count_p, ce_p, processing_time_p, capture_time_p, image_memory_doutb, bin_image_memory_doutb(0), projy_memory1_qdpo, projx_memory1_qdpo, projx_memory2_qdpo, projy_memory2_doutb, ym2_memory_dpo, boundx0_memory_dpo, boundx1_memory_dpo, boundy0_memory_dpo, boundy1_memory_dpo, font_memory_doutb, char_memory_qdpo, char_images_memory_qdpo, distance_memory_qdpo)
 begin
  if state_p = capture_image then
   state_capture_image <= '0';
  else
   state_capture_image <= ce_p;
  end if;
  cntx <= cntx_p;
  cnty <= cnty_p;
  vga_driver_din1 <= image_memory_doutb;
  vga_driver_din2 <= bin_image_memory_doutb(0);
  vga_driver_din_py1 <= projy_memory1_qdpo;
  ym1 <= ym1_p;
  y0_1 <= y0_1_p;
  y1_1 <= y1_1_p;
  vga_driver_din_px1 <= projx_memory1_qdpo;
  xm1 <= xm1_p;
  xmw1 <= xmw1_p;
  x0_1 <= x0_1_p;
  x1_1 <= x1_1_p;
  vga_driver_din_px2 <= projx_memory2_qdpo;
  vga_driver_din_py2 <= projy_memory2_doutb;
  vga_driver_ym2 <= ym2_memory_dpo;
  bounds_addr <= bounds_addr2_p;
  bounds_count <= bounds_count_p;
  vga_driver_din_bx0 <= boundx0_memory_dpo;
  vga_driver_din_bx1 <= boundx1_memory_dpo;
  vga_driver_din_by0 <= boundy0_memory_dpo;
  vga_driver_din_by1 <= boundy1_memory_dpo;
  vga_driver_din_f <= font_memory_doutb;
  vga_driver_din_c <= char_memory_qdpo;
  vga_driver_din_ci <= char_images_memory_qdpo;
  vga_driver_din_d <= distance_memory_qdpo;
  state <= state_p;
  ce <= ce_p;
  threshold <= threshold_p;
  processing_time <= processing_time_p;
  capture_time <= capture_time_p;
 end process;
end behavioral;