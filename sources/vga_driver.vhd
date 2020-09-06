library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.work_package.all;

entity vga_driver is
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
end vga_driver;

architecture behavioral of vga_driver is
signal hs_p, hs_n : std_logic;
signal vs_p, vs_n : std_logic;
signal active_p, active_n : std_logic;
signal active_lat1_p, active_lat1_n : std_logic;
signal active_lat2_p, active_lat2_n : std_logic;
signal active_lat3_p, active_lat3_n : std_logic;
signal vblank_p, vblank_n : std_logic;
signal clk_div_p, clk_div_n : std_logic;
signal hcnt_p, hcnt_n : unsigned(10 downto 0);
signal vcnt_p, vcnt_n : unsigned(9 downto 0);
signal hcnt_lat1_p, hcnt_lat1_n : unsigned(10 downto 0);
signal vcnt_lat1_p, vcnt_lat1_n : unsigned(9 downto 0);
signal hcnt_lat2_p, hcnt_lat2_n : unsigned(10 downto 0);
signal vcnt_lat2_p, vcnt_lat2_n : unsigned(9 downto 0);
signal hcnt_lat3_p, hcnt_lat3_n : unsigned(10 downto 0);
signal vcnt_lat3_p, vcnt_lat3_n : unsigned(9 downto 0);
signal hcnt_lat4_p, hcnt_lat4_n : unsigned(10 downto 0);
signal vcnt_lat4_p, vcnt_lat4_n : unsigned(9 downto 0);
signal ce_hcnt : std_logic;
signal ce_vcnt : std_logic;
signal pick_r : std_logic_vector(2 downto 0);
signal pick_g : std_logic_vector(2 downto 0);
signal pick_b : std_logic_vector(2 downto 1);
signal r_p, r_n : std_logic_vector(2 downto 0);
signal g_p, g_n : std_logic_vector(2 downto 0);
signal b_p, b_n : std_logic_vector(2 downto 1);
signal addr1_p, addr1_n : std_logic_vector(16 downto 0);
signal addr2_p, addr2_n : std_logic_vector(16 downto 0);
signal addr_py1_p, addr_py1_n : std_logic_vector(7 downto 0);
signal addr_px1_p, addr_px1_n : std_logic_vector(8 downto 0);
signal addr_px2_p, addr_px2_n : std_logic_vector(8 downto 0);
signal addr_py2_p, addr_py2_n : std_logic_vector(11 downto 0);
signal addr_py2s_p, addr_py2s_n : std_logic_vector(7 downto 0);
signal addr_py1_lat1_p, addr_py1_lat1_n : std_logic_vector(7 downto 0);
signal addr_px1_lat1_p, addr_px1_lat1_n : std_logic_vector(8 downto 0);
signal addr_px2_lat1_p, addr_px2_lat1_n : std_logic_vector(8 downto 0);
signal addr_py2_lat1_p, addr_py2_lat1_n : std_logic_vector(7 downto 0);
signal addr_proj_p, addr_proj_n : std_logic_vector(11 downto 0);
signal proj_p, proj_n : std_logic_vector(8 downto 0);
signal pixel_x_p, pixel_x_n : std_logic_vector(8 downto 0);
signal pixel_y_p, pixel_y_n : std_logic_vector(7 downto 0);
signal pixel_dat_p, pixel_dat_n : std_logic_vector(3 downto 0);
signal latch_next_index : std_logic_vector(7 downto 0);
signal hold_ni_p, hold_ni_n : unsigned(25 downto 0);
signal ce_hold_ni : std_logic;
signal latch_next_pixel : std_logic_vector(7 downto 0);
signal hold_np_p, hold_np_n : unsigned(25 downto 0);
signal ce_hold_np : std_logic;
signal addr_b_p, addr_b_n : std_logic_vector(3 downto 0);
signal ce_addr_b, r_addr_b : std_logic;
signal y0_p, y0_n : std_logic_vector(7 downto 0);
signal y1_p, y1_n : std_logic_vector(7 downto 0);
signal cdm_p, cdm_n : std_logic_vector(5 downto 0);
signal addr_b_lat1_p, addr_b_lat1_n : std_logic_vector(3 downto 0);
signal addr_f_p, addr_f_n : std_logic_vector(9 downto 0);
signal addr_ci_p, addr_ci_n : std_logic_vector(7 downto 0);
signal addr_c_p, addr_c_n : std_logic_vector(3 downto 0);
signal addr_d_p, addr_d_n : std_logic_vector(8 downto 0);
signal addr_ds_p, addr_ds_n : std_logic_vector(5 downto 0);
signal addr_c_lat1_p, addr_c_lat1_n : std_logic_vector(3 downto 0);
signal addr_d_lat1_p, addr_d_lat1_n : std_logic_vector(5 downto 0);
begin

 color_process: process(hcnt_lat4_p, vcnt_lat4_p, din1,din2, din_py1, ym1, y0_1, y1_1, din_px1, xm1, xmw1, x0_1, x1_1, state, din_px2, din_py2, ym2, din_bx0, din_bx1, din_by0, din_by1, bounds_count, din_f, din_ci, din_c, din_d, cdm_p, pixel_x_p, pixel_y_p, pixel_dat_p, addr_proj_p, proj_p, bounds_addr, addr_b_p, y0_p, y1_p, ce, capture)
 variable temp : integer := 0;
 begin
  pick_r <= (others => '0');
  pick_g <= (others => '0');
  pick_b <= (others => '0');

  if hcnt_lat4_p < 320 then
   if vcnt_lat4_p < 240 then
    pick_r <= din1(2 downto 0);
    pick_g <= din1(2 downto 0);
    pick_b <= din1(2 downto 1);
    if ((vcnt_lat4_p = unsigned(y0_1) or vcnt_lat4_p = unsigned(y1_1)) and hcnt_lat4_p >= unsigned(x0_1) and hcnt_lat4_p <= unsigned(x1_1)) or ((hcnt_lat4_p = unsigned(x0_1) or hcnt_lat4_p = unsigned(x1_1)) and vcnt_lat4_p >= unsigned(y0_1) and vcnt_lat4_p <= unsigned(y1_1)) then
     pick_r <= (others => '0');
     pick_g <= (others => '1');
     pick_b <= (others => '0');
    end if;
    if unsigned(bounds_count) /= 0 and (((vcnt_lat4_p = unsigned(din_by0) or vcnt_lat4_p = unsigned(din_by1)) and hcnt_lat4_p >= unsigned(din_bx0) and hcnt_lat4_p <= unsigned(din_bx1)) or ((hcnt_lat4_p = unsigned(din_bx0) or hcnt_lat4_p = unsigned(din_bx1)) and vcnt_lat4_p >= unsigned(din_by0) and vcnt_lat4_p <= unsigned(din_by1))) then
     pick_r <= (others => '0');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
     if addr_b_p = bounds_addr then
      pick_r <= (others => '1');
      pick_g <= (others => '0');
      pick_b <= (others => '0');
     end if;
    end if;
    if (ce = '0' or capture = '0') and hcnt_lat4_p = unsigned(pixel_x_p) and vcnt_lat4_p = unsigned(pixel_y_p) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
   elsif vcnt_lat4_p < 480 then
    pick_r <= (others => din1(2));
    pick_g <= (others => din1(2));
    pick_b <= (others => din1(2));
    if ((vcnt_lat4_p-240 = unsigned(y0_1) or vcnt_lat4_p-240 = unsigned(y1_1)) and hcnt_lat4_p >= unsigned(x0_1) and hcnt_lat4_p <= unsigned(x1_1)) or ((hcnt_lat4_p = unsigned(x0_1) or hcnt_lat4_p = unsigned(x1_1)) and vcnt_lat4_p-240 >= unsigned(y0_1) and vcnt_lat4_p-240 <= unsigned(y1_1)) then
     pick_r <= (others => '0');
     pick_g <= (others => '1');
     pick_b <= (others => '0');
    end if;
    if unsigned(bounds_count) /= 0 and (((vcnt_lat4_p-240 = unsigned(din_by0) or vcnt_lat4_p-240 = unsigned(din_by1)) and hcnt_lat4_p >= unsigned(din_bx0) and hcnt_lat4_p <= unsigned(din_bx1)) or ((hcnt_lat4_p = unsigned(din_bx0) or hcnt_lat4_p = unsigned(din_bx1)) and vcnt_lat4_p-240 >= unsigned(din_by0) and vcnt_lat4_p-240 <= unsigned(din_by1))) then
     pick_r <= (others => '0');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
     if addr_b_p = bounds_addr then
      pick_r <= (others => '1');
      pick_g <= (others => '0');
      pick_b <= (others => '0');
     end if;
    end if;
    if (ce = '0' or capture = '0') and hcnt_lat4_p = unsigned(pixel_x_p) and vcnt_lat4_p-240 = unsigned(pixel_y_p) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
   elsif vcnt_lat4_p < 544 then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
    if vcnt_lat4_p-480 = unsigned(din_px2(7 downto 2)) then
     pick_r <= (others => '0');
     pick_g <= (others => '1');
     pick_b <= (others => '0');
    end if;
    if hcnt_lat4_p = unsigned(din_bx0) or hcnt_lat4_p = unsigned(din_bx1) then
     pick_r <= (others => '0');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
    if (ce = '0' or capture = '0') and addr_proj_p(11 downto 9) = "010" and hcnt_lat4_p = unsigned(addr_proj_p(8 downto 0)) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
    if hcnt_lat4_p < unsigned(x0_1) or hcnt_lat4_p > unsigned(x1_1) then
     pick_r(1 downto 0) <= (others => '0');
     pick_g(1 downto 0) <= (others => '0');
     pick_b(1) <= '0';
    end if;
   end if;
  elsif hcnt_lat4_p < 400 then
   if hcnt_lat4_p < 384 and vcnt_lat4_p >= 240 and vcnt_lat4_p < 480 then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
    if hcnt_lat4_p-320 = unsigned(din_py2(8 downto 3)) then
     pick_r <= (others => '0');
     pick_g <= (others => '1');
     pick_b <= (others => '0');
    end if;
    if vcnt_lat4_p-240 = unsigned(ym2) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '0');
    end if;
    if vcnt_lat4_p-240 = unsigned(y0_p) or vcnt_lat4_p-240 = unsigned(y1_p) then
     pick_r <= (others => '0');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
    if (ce = '0' or capture = '0') and addr_proj_p(11 downto 9) = "011" and vcnt_lat4_p-240 = unsigned(addr_proj_p(8 downto 0)) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
    if vcnt_lat4_p-240 < unsigned(y0_1) or vcnt_lat4_p-240 > unsigned(y1_1) then
     pick_r(1 downto 0) <= (others => '0');
     pick_g(1 downto 0) <= (others => '0');
     pick_b(1) <= '0';
    end if;
   end if;
  elsif hcnt_lat4_p < 720 then
   if vcnt_lat4_p < 240 then
    pick_r <= (others => din2);
    pick_g <= (others => din2);
    pick_b <= (others => din2);
    if ((vcnt_lat4_p = unsigned(y0_1) or vcnt_lat4_p = unsigned(y1_1)) and hcnt_lat4_p-400 >= unsigned(x0_1) and hcnt_lat4_p-400 <= unsigned(x1_1)) or ((hcnt_lat4_p-400 = unsigned(x0_1) or hcnt_lat4_p-400 = unsigned(x1_1)) and vcnt_lat4_p >= unsigned(y0_1) and vcnt_lat4_p <= unsigned(y1_1)) then
     pick_r <= (others => '0');
     pick_g <= (others => '1');
     pick_b <= (others => '0');
    end if;
    if unsigned(bounds_count) /= 0 and (((vcnt_lat4_p = unsigned(din_by0) or vcnt_lat4_p = unsigned(din_by1)) and hcnt_lat4_p-400 >= unsigned(din_bx0) and hcnt_lat4_p-400 <= unsigned(din_bx1)) or ((hcnt_lat4_p-400 = unsigned(din_bx0) or hcnt_lat4_p-400 = unsigned(din_bx1)) and vcnt_lat4_p >= unsigned(din_by0) and vcnt_lat4_p <= unsigned(din_by1))) then
     pick_r <= (others => '0');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
     if addr_b_p = bounds_addr then
      pick_r <= (others => '1');
      pick_g <= (others => '0');
      pick_b <= (others => '0');
     end if;
    end if;
    if (ce = '0' or capture = '0') and hcnt_lat4_p-400 = unsigned(pixel_x_p) and vcnt_lat4_p = unsigned(pixel_y_p) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
   elsif vcnt_lat4_p < 304 then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
    if hcnt_lat4_p-400 >= unsigned(xm1) and hcnt_lat4_p-400 <= unsigned(xmw1) then
     pick_r <= (others => '1');
     pick_g <= "100";
     pick_b <= "10";
    end if;
    if vcnt_lat4_p-240 = unsigned(din_px1(7 downto 2)) then
     pick_r <= (others => '0');
     pick_g <= (others => '1');
     pick_b <= (others => '0');
    end if;
    if hcnt_lat4_p-400 = unsigned(x0_1) or hcnt_lat4_p-400 = unsigned(x1_1) then
     pick_r <= (others => '0');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
    if (ce = '0' or capture = '0') and addr_proj_p(11 downto 9) = "000" and hcnt_lat4_p-400 = unsigned(addr_proj_p(8 downto 0)) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
   end if;
  elsif hcnt_lat4_p < 784 then
   if vcnt_lat4_p < 240 then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
    if hcnt_lat4_p-720 = unsigned(din_py1(8 downto 3)) then
     pick_r <= (others => '0');
     pick_g <= (others => '1');
     pick_b <= (others => '0');
    end if;
    if vcnt_lat4_p = unsigned(ym1) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '0');
    end if;
    if vcnt_lat4_p = unsigned(y0_1) or vcnt_lat4_p = unsigned(y1_1) then
     pick_r <= (others => '0');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
    if (ce = '0' or capture = '0') and addr_proj_p(11 downto 9) = "001" and vcnt_lat4_p = unsigned(addr_proj_p(8 downto 0)) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
   end if;
  end if;

  if hcnt_lat4_p >= 400 and vcnt_lat4_p >= 320 then
   if vcnt_lat4_p >= 324 and vcnt_lat4_p < 332 and hcnt_lat4_p >= 568 and hcnt_lat4_p < 632 and din_f(((to_integer(hcnt_lat4_p)-568) mod 8)*2) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
   end if;
   if vcnt_lat4_p >= 336 and vcnt_lat4_p < 400 and hcnt_lat4_p >= 456 and hcnt_lat4_p < 744 then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
    if vcnt_lat4_p-336 > unsigned(not (din_d(8 downto 3))) then
     pick_r <= (others => '0');
     pick_g <= (others => '1');
     pick_b <= (others => '0');
     if (hcnt_lat4_p-456) mod 8 = 0 or (hcnt_lat4_p-456) mod 8 = 7 then
      pick_r <= (others => '0');
      pick_g <= "100";
      pick_b <= (others => '0');
      if (hcnt_lat4_p-456)/8 = unsigned(cdm_p) then
       pick_r <= (others => '1');
       pick_g <= (others => '0');
       pick_b <= (others => '0');
      end if;
      if (ce = '0' or capture = '0') and addr_proj_p(11 downto 9) = "100" and (hcnt_lat4_p-456)/8 = unsigned(addr_proj_p(8 downto 0)) then
       pick_r <= (others => '1');
       pick_g <= (others => '0');
       pick_b <= (others => '1');
      end if;
     end if;
    end if;
    if vcnt_lat4_p = 399 or vcnt_lat4_p-336 = unsigned(not (din_d(8 downto 3))) then
     pick_r <= (others => '0');
     pick_g <= "100";
     pick_b <= (others => '0');
     if (hcnt_lat4_p-456)/8 = unsigned(cdm_p) then
      pick_r <= (others => '1');
      pick_g <= (others => '0');
      pick_b <= (others => '0');
     end if;
     if (ce = '0' or capture = '0') and addr_proj_p(11 downto 9) = "100" and (hcnt_lat4_p-456)/8 = unsigned(addr_proj_p(8 downto 0)) then
      pick_r <= (others => '1');
      pick_g <= (others => '0');
      pick_b <= (others => '1');
     end if;
    end if;
   end if;
   if vcnt_lat4_p >= 404 and vcnt_lat4_p < 412 and hcnt_lat4_p >= 456 and hcnt_lat4_p < 744 and din_f(((to_integer(hcnt_lat4_p)-456) mod 8)*2) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
    if (hcnt_lat4_p-456)/8 = unsigned(cdm_p) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '0');
    end if;
    if (ce = '0' or capture = '0') and addr_proj_p(11 downto 9) = "100" and (hcnt_lat4_p-456)/8 = unsigned(addr_proj_p(8 downto 0)) then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '1');
    end if;
   end if;
   if vcnt_lat4_p >= 420 and vcnt_lat4_p < 428 and hcnt_lat4_p >= 560 and hcnt_lat4_p < 640 and din_f(((to_integer(hcnt_lat4_p)-560) mod 8)*2) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
   end if;
   if vcnt_lat4_p >= 432 and vcnt_lat4_p < 448 and hcnt_lat4_p >= 440 and hcnt_lat4_p < 760 and (hcnt_lat4_p-440)/32 < unsigned(bounds_count) and ((hcnt_lat4_p-440)/16) mod 2 = 0 and din_ci((to_integer(hcnt_lat4_p)-440) mod 16) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
    if unsigned(bounds_addr) = (hcnt_lat4_p-440)/32 then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '0');
    end if;
   end if;
   if vcnt_lat4_p >= 452 and vcnt_lat4_p < 460 and hcnt_lat4_p >= 560 and hcnt_lat4_p < 640 and (hcnt_lat4_p-560)/8 /= 4 and din_f(((to_integer(hcnt_lat4_p)-560) mod 8)*2) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
   end if;
   if vcnt_lat4_p >= 464 and vcnt_lat4_p < 480 and hcnt_lat4_p >= 440 and hcnt_lat4_p < 760 and (hcnt_lat4_p-440)/32 < unsigned(bounds_count) and ((hcnt_lat4_p-440)/16) mod 2 = 0 and din_f((to_integer(hcnt_lat4_p)-440) mod 16) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
    if unsigned(bounds_addr) = (hcnt_lat4_p-440)/32 then
     pick_r <= (others => '1');
     pick_g <= (others => '0');
     pick_b <= (others => '0');
    end if;
   end if;
   if vcnt_lat4_p >= 484 and vcnt_lat4_p < 492 and (hcnt_lat4_p-400)/8 /= 9 and (hcnt_lat4_p-400)/8 < 13 and din_f(((to_integer(hcnt_lat4_p)-400) mod 8)*2) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
   end if;
   if vcnt_lat4_p >= 500 and vcnt_lat4_p < 508 and (hcnt_lat4_p-400)/8 /= 6 and (hcnt_lat4_p-400)/8 /= 8 and (hcnt_lat4_p-400)/8 /= 14 and (hcnt_lat4_p-400)/8 < 16 and din_f(((to_integer(hcnt_lat4_p)-400) mod 8)*2) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
   end if;
   if vcnt_lat4_p >= 516 and vcnt_lat4_p < 524 and (hcnt_lat4_p-400)/8 /= 5 and (hcnt_lat4_p-400)/8 /= 12 and (hcnt_lat4_p-400)/8 /= 22 and (hcnt_lat4_p-400)/8 < 25 and din_f(((to_integer(hcnt_lat4_p)-400) mod 8)*2) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
   end if;
   if vcnt_lat4_p >= 532 and vcnt_lat4_p < 540 and (hcnt_lat4_p-400)/8 /= 4 and (hcnt_lat4_p-400)/8 /= 11 and (hcnt_lat4_p-400)/8 /= 15 and (hcnt_lat4_p-400)/8 /= 18 and (hcnt_lat4_p-400)/8 /= 23 and (hcnt_lat4_p-400)/8 /= 28 and (hcnt_lat4_p-400)/8 /= 38 and (hcnt_lat4_p-400)/8 < 41 and din_f(((to_integer(hcnt_lat4_p)-400) mod 8)*2) = '1' then
    pick_r <= (others => '1');
    pick_g <= (others => '1');
    pick_b <= (others => '1');
   end if;
   if (ce = '0' or capture = '0') then
    if vcnt_lat4_p >= 548 and vcnt_lat4_p < 556 and (hcnt_lat4_p-400)/8 /= 1 and (hcnt_lat4_p-400)/8 /= 5 and (hcnt_lat4_p-400)/8 /= 7 and (hcnt_lat4_p-400)/8 < 11 and din_f(((to_integer(hcnt_lat4_p)-400) mod 8)*2) = '1' then
     pick_r <= (others => '1');
     pick_g <= (others => '1');
     pick_b <= (others => '1');
    end if;
    if vcnt_lat4_p >= 564 and vcnt_lat4_p < 572 then
     if (hcnt_lat4_p-400)/8 /= 1 and (hcnt_lat4_p-400)/8 /= 5 and (hcnt_lat4_p-400)/8 /= 7 and (hcnt_lat4_p-400)/8 /= 10 and (hcnt_lat4_p-400)/8 < 12 and din_f(((to_integer(hcnt_lat4_p)-400) mod 8)*2) = '1' then
      pick_r <= (others => '1');
      pick_g <= (others => '1');
      pick_b <= (others => '1');
     end if;
     if hcnt_lat4_p >= 504 and (hcnt_lat4_p-504)/8 /= 3 and (hcnt_lat4_p-504)/8 < 5 then
      if ((((vcnt_lat4_p-564) mod 8 = 0 or (vcnt_lat4_p-564) mod 8 = 7) and (hcnt_lat4_p-504) mod 8 >= 0 and (hcnt_lat4_p-504) mod 8 <= 7) or (((hcnt_lat4_p-504) mod 8 = 0 or (hcnt_lat4_p-504) mod 8 = 7) and (vcnt_lat4_p-564) mod 8 >= 0 and (vcnt_lat4_p-564) mod 8 <= 7)) then
       pick_r <= (others => '1');
       pick_g <= (others => '0');
       pick_b <= (others => '0');
      else
       if ((hcnt_lat4_p-504)/8 < 3 and pixel_dat_p(3-to_integer((hcnt_lat4_p-504)/8)) = '1') or ((hcnt_lat4_p-504)/8 = 4 and pixel_dat_p(0) = '1') then
        pick_r <= (others => '1');
        pick_g <= (others => '1');
        pick_b <= (others => '1');
       end if;
      end if;
     end if;
    end if;
    if vcnt_lat4_p >= 580 and vcnt_lat4_p < 588 then
     if (hcnt_lat4_p-400)/8 < 5 and din_f(((to_integer(hcnt_lat4_p)-400) mod 8)*2) = '1' then
      pick_r <= (others => '1');
      pick_g <= (others => '1');
      pick_b <= (others => '1');
     end if;
     if hcnt_lat4_p >= 448 and (hcnt_lat4_p-448)/8 < 17 then
      if ((((vcnt_lat4_p-580) mod 8 = 0 or (vcnt_lat4_p-580) mod 8 = 7) and (hcnt_lat4_p-448) mod 8 >= 0 and (hcnt_lat4_p-448) mod 8 <= 7) or (((hcnt_lat4_p-448) mod 8 = 0 or (hcnt_lat4_p-448) mod 8 = 7) and (vcnt_lat4_p-580) mod 8 >= 0 and (vcnt_lat4_p-580) mod 8 <= 7)) then
       pick_r <= (others => '1');
       pick_g <= (others => '0');
       pick_b <= (others => '0');
      else
       case state is
        when idle => temp := 0;
        when capture_image => temp := 1;
        when y0_first => temp := 2;
        when y1_first => temp := 3;
        when px1 => temp := 4;
        when x_first => temp := 5;
        when x_second => temp := 6;
        when py2 => temp := 7;
        when y0_second => temp := 8;
        when y1_second => temp := 9;
        when init_res => temp := 10;
        when init_l_res => temp := 11;
        when res => temp := 12;
        when l_res => temp := 13;
        when l_res2 => temp := 14;
        when dist => temp := 15;
        when dm => temp := 16;
       end case;
       if (hcnt_lat4_p-448)/8 = temp then
        pick_r <= (others => '1');
        pick_g <= (others => '1');
        pick_b <= (others => '1');
       end if;
      end if;
     end if;
    end if;
   end if;
  end if;

 end process;

 clock_process1: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' then
    hs_p <= '1';
    vs_p <= '1';
    active_p <= '0';
    active_lat1_p <= '0';
    active_lat2_p <= '0';
    active_lat3_p <= '0';
    vblank_p <= '0';
    clk_div_p <= '0';
    hcnt_p <= (others => '0');
    vcnt_p <= (others => '0');
    hcnt_lat1_p <= (others => '0');
    vcnt_lat1_p <= (others => '0');
    hcnt_lat2_p <= (others => '0');
    vcnt_lat2_p <= (others => '0');
    hcnt_lat3_p <= (others => '0');
    vcnt_lat3_p <= (others => '0');
    hcnt_lat4_p <= (others => '0');
    vcnt_lat4_p <= (others => '0');
    addr_proj_p <= (others => '0');
    proj_p <= (others => '0');
    pixel_x_p <= (others => '0');
    pixel_y_p <= (others => '0');
    pixel_dat_p <= (others => '0');
    y0_p <= (others => '0');
    y1_p <= (others => '0');
    cdm_p <= (others => '0');
    addr_b_lat1_p <= (others => '0');
    addr_py1_lat1_p <= (others => '0');
    addr_px1_lat1_p <= (others => '0');
    addr_px2_lat1_p <= (others => '0');
    addr_py2_lat1_p <= (others => '0');
    addr_c_lat1_p <= (others => '0');
    addr_d_lat1_p <= (others => '0');
   else
    hs_p <= hs_n;
    vs_p <= vs_n;
    active_p <= active_n;
    active_lat1_p <= active_lat1_n;
    active_lat2_p <= active_lat2_n;
    active_lat3_p <= active_lat3_n;
    vblank_p <= vblank_n;
    clk_div_p <= clk_div_n;
    hcnt_lat1_p <= hcnt_lat1_n;
    vcnt_lat1_p <= vcnt_lat1_n;
    hcnt_lat2_p <= hcnt_lat2_n;
    vcnt_lat2_p <= vcnt_lat2_n;
    hcnt_lat3_p <= hcnt_lat3_n;
    vcnt_lat3_p <= vcnt_lat3_n;
    hcnt_lat4_p <= hcnt_lat4_n;
    vcnt_lat4_p <= vcnt_lat4_n;
    if ce_hcnt = '1' then
     hcnt_p <= hcnt_n;
    end if;
    if ce_vcnt = '1' then
     vcnt_p <= vcnt_n;
    end if;
    addr_proj_p <= addr_proj_n;
    proj_p <= proj_n;
    pixel_x_p <= pixel_x_n;
    pixel_y_p <= pixel_y_n;
    pixel_dat_p <= pixel_dat_n;
    y0_p <= y0_n;
    y1_p <= y1_n;
    cdm_p <= cdm_n;
    addr_b_lat1_p <= addr_b_lat1_n;
    addr_py1_lat1_p <= addr_py1_lat1_n;
    addr_px1_lat1_p <= addr_px1_lat1_n;
    addr_px2_lat1_p <= addr_px2_lat1_n;
    addr_py2_lat1_p <= addr_py2_lat1_n;
    addr_c_lat1_p <= addr_c_lat1_n;
    addr_d_lat1_p <= addr_d_lat1_n;
   end if;
   if reset = '1' or (ce = '1' and capture = '1') then
    latch_next_index <= (others => '0');
    latch_next_pixel <= (others => '0');
   else
    latch_next_index <= latch_next_index(6 downto 0) & next_index;
    latch_next_pixel <= latch_next_pixel(6 downto 0) & next_pixel;
   end if;
  end if;
 end process;

 clock_process2: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' or latch_next_index(0) = '0' then
    hold_ni_p <= (others => '0');
   elsif ce_hold_ni = '1' then
    hold_ni_p <= hold_ni_n;
   end if;
   if reset = '1' or latch_next_pixel(0) = '0' then
    hold_np_p <= (others => '0');
   elsif ce_hold_np = '1' then
    hold_np_p <= hold_np_n;
   end if;
  end if;
 end process;

 clock_process3: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' or active_lat2_p = '0' then
    r_p <= (others => '0');
    g_p <= (others => '0');
    b_p <= (others => '0');
   else
    r_p <= r_n;
    g_p <= g_n;
    b_p <= b_n;
   end if;
   if reset = '1' or active_p = '0' then
    addr1_p <= (others => '0');
    addr2_p <= (others => '0');
    addr_py1_p <= (others => '0');
    addr_px1_p <= (others => '0');
    addr_px2_p <= (others => '0');
    addr_py2_p <= (others => '0');
    addr_py2s_p <= (others => '0');
    addr_f_p <= (others => '0');
    addr_c_p <= (others => '0');
    addr_ci_p <= (others => '0');
    addr_d_p <= (others => '0');
    addr_ds_p <= (others => '0');
   else
    addr1_p <= addr1_n;
    addr2_p <= addr2_n;
    addr_py1_p <= addr_py1_n;
    addr_px1_p <= addr_px1_n;
    addr_px2_p <= addr_px2_n;
    addr_py2_p <= addr_py2_n;
    addr_py2s_p <= addr_py2s_n;
    addr_f_p <= addr_f_n;
    addr_c_p <= addr_c_n;
    addr_ci_p <= addr_ci_n;
    addr_d_p <= addr_d_n;
    addr_ds_p <= addr_ds_n;
   end if;
   if reset = '1' or active_p = '0' or r_addr_b = '1' then
    addr_b_p <= (others => '0');
   elsif ce_addr_b = '1' then
    addr_b_p <= addr_b_n;
   end if;
  end if;
 end process;

 next_state_process: process(hs_p, vs_p, active_p, active_lat1_p, active_lat2_p, clk_div_p, vblank_p, r_p, g_p, b_p, hcnt_p, vcnt_p, hcnt_lat1_p, vcnt_lat1_p, hcnt_lat2_p, vcnt_lat2_p, hcnt_lat3_p, vcnt_lat3_p, hcnt_lat4_p, vcnt_lat4_p, din_px1, din_py1, din_px2, din_py2, addr1_p, addr2_p, addr_py1_p, addr_px1_p, addr_px2_p, addr_py2_p, addr_py2s_p, addr_py1_lat1_p, addr_px1_lat1_p, addr_px2_lat1_p, addr_py2_lat1_p, addr_b_p, addr_b_lat1_p, addr_f_p, addr_c_p, addr_ci_p, addr_d_p, addr_ds_p, addr_c_lat1_p, addr_d_lat1_p, din_bx1, bounds_count, hcnt_p, vcnt_p, pick_r, pick_g, pick_b, bounds_addr, threshold, latch_next_index, next_index_dir, latch_next_pixel, next_pixel_ori, next_pixel_dir, hold_ni_p, hold_np_p, addr_proj_p, proj_p, pixel_x_p, pixel_y_p, pixel_dat_p, y0_p, y1_p, din_bx0, din_bx1, din_by0, din_by1, din1, din2, din_ci, din_c, din_d, cdm_p, processing_time, pixel_clock, capture_time)
 begin
  --default:
  hs_n <= hs_p;
  vs_n <= vs_p;
  active_n <= active_p;
  active_lat1_n <= active_p;
  active_lat2_n <= active_lat1_p;
  active_lat3_n <= active_lat2_p;
  clk_div_n <= not clk_div_p;
  hcnt_lat1_n <= hcnt_p;
  vcnt_lat1_n <= vcnt_p;
  hcnt_lat2_n <= hcnt_lat1_p;
  vcnt_lat2_n <= vcnt_lat1_p;
  hcnt_lat3_n <= hcnt_lat2_p;
  vcnt_lat3_n <= vcnt_lat2_p;
  hcnt_lat4_n <= hcnt_lat3_p;
  vcnt_lat4_n <= vcnt_lat3_p;
  vblank_n <= vblank_p;
  if hcnt_p = 1039 then
   hcnt_n <= (others => '0');
  else
   hcnt_n <= hcnt_p + 1;
  end if;
  if vcnt_p = 665 then
   vcnt_n <= (others => '0');
  else
   vcnt_n <= vcnt_p + 1;
  end if;
  r_n <= pick_r;
  g_n <= pick_g;
  b_n <= pick_b;
  if vcnt_lat2_p < 240 then
   addr1_n <= std_logic_vector(to_unsigned(to_integer(vcnt_lat2_p)*320 + to_integer(hcnt_lat2_p),17));
  else
   addr1_n <= std_logic_vector(to_unsigned((to_integer(vcnt_lat2_p)-240)*320 + to_integer(hcnt_lat2_p),17));
  end if;
  addr2_n <= std_logic_vector(to_unsigned(to_integer(vcnt_lat2_p)*320+(to_integer(hcnt_lat2_p)-400),17));
  addr_py1_n <= std_logic_vector(vcnt_lat2_p(7 downto 0));
  addr_px1_n <= std_logic_vector(hcnt_lat2_p(8 downto 0)-400);
  addr_px2_n <= std_logic_vector(hcnt_lat2_p(8 downto 0));
  addr_py2_n <= std_logic_vector(to_unsigned(to_integer(unsigned(bounds_addr))*240 + to_integer(vcnt_lat2_p(7 downto 0)-240),12));
  addr_py2s_n <= std_logic_vector(vcnt_lat2_p(7 downto 0)-240);
  addr_py1_lat1_n <= addr_py1_p;
  addr_px1_lat1_n <= addr_px1_p;
  addr_px2_lat1_n <= addr_px2_p;
  addr_py2_lat1_n <= addr_py2s_p;
  addr_b_n <= std_logic_vector(unsigned(addr_b_p)+1);
  ce_addr_b <= '0';
  r_addr_b <= '0';
  addr_d_n <= std_logic_vector(to_unsigned(to_integer(unsigned(bounds_addr))*36 + to_integer((hcnt_lat2_p(8 downto 0)-456)/8),9));
  addr_ds_n <= std_logic_vector(to_unsigned(to_integer((hcnt_lat2_p(8 downto 0)-456)/8),6));
  addr_b_lat1_n <= addr_b_p;
  addr_c_lat1_n <= addr_c_p;
  addr_d_lat1_n <= addr_ds_p;
  addr_f_n <= addr_f_p;
  if vcnt_lat2_p >= 324 and vcnt_lat2_p < 332 then
   case (hcnt_lat2_p-568)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(13*16 + (to_integer(vcnt_lat2_p)-324)*2,10));
    when "00000000001" => addr_f_n <= std_logic_vector(to_unsigned(18*16 + (to_integer(vcnt_lat2_p)-324)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-324)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-324)*2,10));
    when "00000000100" => addr_f_n <= std_logic_vector(to_unsigned(10*16 + (to_integer(vcnt_lat2_p)-324)*2,10));
    when "00000000101" => addr_f_n <= std_logic_vector(to_unsigned(23*16 + (to_integer(vcnt_lat2_p)-324)*2,10));
    when "00000000110" => addr_f_n <= std_logic_vector(to_unsigned(12*16 + (to_integer(vcnt_lat2_p)-324)*2,10));
    when "00000000111" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-324)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 404 and vcnt_lat2_p < 412 then
   addr_f_n <= std_logic_vector(to_unsigned(to_integer((hcnt_lat2_p-456)/8)*16 + (to_integer(vcnt_lat2_p)-404)*2,10));
  elsif vcnt_lat2_p >= 420 and vcnt_lat2_p < 428 then
   case (hcnt_lat2_p-560)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000000001" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(16*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(22*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000000100" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000000101" => addr_f_n <= std_logic_vector(to_unsigned(23*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000000110" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000000111" => addr_f_n <= std_logic_vector(to_unsigned(10*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000001000" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when "00000001001" => addr_f_n <= std_logic_vector(to_unsigned(18*16 + (to_integer(vcnt_lat2_p)-420)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 452 and vcnt_lat2_p < 460 then
   case (hcnt_lat2_p-560)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(25*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when "00000000001" => addr_f_n <= std_logic_vector(to_unsigned(21*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(10*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when "00000000101" => addr_f_n <= std_logic_vector(to_unsigned(23*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when "00000000110" => addr_f_n <= std_logic_vector(to_unsigned(24*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when "00000000111" => addr_f_n <= std_logic_vector(to_unsigned(22*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when "00000001000" => addr_f_n <= std_logic_vector(to_unsigned(24*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when "00000001001" => addr_f_n <= std_logic_vector(to_unsigned(27*16 + (to_integer(vcnt_lat2_p)-452)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 464 and vcnt_lat2_p < 480 then
   addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(din_c))*16 + (to_integer(vcnt_lat2_p)-464),10));
  elsif vcnt_lat2_p >= 484 and vcnt_lat2_p < 492 then
   case (hcnt_lat2_p-400)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000000001" => addr_f_n <= std_logic_vector(to_unsigned(17*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(27*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000000100" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000000101" => addr_f_n <= std_logic_vector(to_unsigned(17*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000000110" => addr_f_n <= std_logic_vector(to_unsigned(24*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000000111" => addr_f_n <= std_logic_vector(to_unsigned(21*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000001000" => addr_f_n <= std_logic_vector(to_unsigned(13*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000001010" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(threshold(9 downto 8)))*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000001011" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(threshold(7 downto 4)))*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when "00000001100" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(threshold(3 downto 0)))*16 + (to_integer(vcnt_lat2_p)-484)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 500 and vcnt_lat2_p < 508 then
   case (hcnt_lat2_p-400)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000000001" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(16*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(22*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000000100" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000000101" => addr_f_n <= std_logic_vector(to_unsigned(23*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000000111" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(bounds_addr))*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000001001" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000001010" => addr_f_n <= std_logic_vector(to_unsigned(24*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000001011" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000001100" => addr_f_n <= std_logic_vector(to_unsigned(10*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000001101" => addr_f_n <= std_logic_vector(to_unsigned(21*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when "00000001111" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(bounds_count))*16 + (to_integer(vcnt_lat2_p)-500)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 516 and vcnt_lat2_p < 524 then
   case (hcnt_lat2_p-400)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(32*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000000001" => addr_f_n <= std_logic_vector(to_unsigned(10*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(20*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000000100" => addr_f_n <= std_logic_vector(to_unsigned(30*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000000110" => addr_f_n <= std_logic_vector(to_unsigned(25*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000000111" => addr_f_n <= std_logic_vector(to_unsigned(27*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000001000" => addr_f_n <= std_logic_vector(to_unsigned(24*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000001001" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000001010" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000001011" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000001101" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(processing_time(31 downto 28)))*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000001110" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(processing_time(27 downto 24)))*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000001111" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(processing_time(23 downto 20)))*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000010000" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(processing_time(19 downto 16)))*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000010001" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(processing_time(15 downto 12)))*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000010010" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(processing_time(11 downto 8)))*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000010011" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(processing_time(7 downto 4)))*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000010100" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(processing_time(3 downto 0)))*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000010101" => addr_f_n <= std_logic_vector(to_unsigned(0*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000010111" => addr_f_n <= std_logic_vector(to_unsigned(23*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when "00000011000" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-516)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 532 and vcnt_lat2_p < 540 then
   case (hcnt_lat2_p-400)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(25*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000000001" => addr_f_n <= std_logic_vector(to_unsigned(12*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(21*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(20*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000000101" => addr_f_n <= std_logic_vector(to_unsigned(25*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000000110" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000000111" => addr_f_n <= std_logic_vector(to_unsigned(27*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000001000" => addr_f_n <= std_logic_vector(to_unsigned(18*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000001001" => addr_f_n <= std_logic_vector(to_unsigned(24*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000001010" => addr_f_n <= std_logic_vector(to_unsigned(13*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000001100" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(pixel_clock(7 downto 4)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000001101" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(pixel_clock(3 downto 0)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000001110" => addr_f_n <= std_logic_vector(to_unsigned(0*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000010000" => addr_f_n <= std_logic_vector(to_unsigned(23*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000010001" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000010011" => addr_f_n <= std_logic_vector(to_unsigned(12*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000010100" => addr_f_n <= std_logic_vector(to_unsigned(10*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000010101" => addr_f_n <= std_logic_vector(to_unsigned(25*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000010110" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000011000" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000011001" => addr_f_n <= std_logic_vector(to_unsigned(18*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000011010" => addr_f_n <= std_logic_vector(to_unsigned(22*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000011011" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000011101" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(capture_time(31 downto 28)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000011110" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(capture_time(27 downto 24)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000011111" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(capture_time(23 downto 20)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000100000" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(capture_time(19 downto 16)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000100001" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(capture_time(15 downto 12)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000100010" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(capture_time(11 downto 8)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000100011" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(capture_time(7 downto 4)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000100100" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(capture_time(3 downto 0)))*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000100101" => addr_f_n <= std_logic_vector(to_unsigned(0*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000100111" => addr_f_n <= std_logic_vector(to_unsigned(23*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when "00000101000" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-532)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 548 and vcnt_lat2_p < 556 then
   case (hcnt_lat2_p-400)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(18*16 + (to_integer(vcnt_lat2_p)-548)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(addr_proj_p(8 downto 8)))*16 +(to_integer(vcnt_lat2_p)-548)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(addr_proj_p(7 downto 4)))*16 + (to_integer(vcnt_lat2_p)-548)*2,10));
    when "00000000100" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(addr_proj_p(3 downto 0)))*16 + (to_integer(vcnt_lat2_p)-548)*2,10));
    when "00000000110" => addr_f_n <= std_logic_vector(to_unsigned(31*16 + (to_integer(vcnt_lat2_p)-548)*2,10));
    when "00000001000" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(proj_p(8 downto 8)))*16 + (to_integer(vcnt_lat2_p)-548)*2,10));
    when "00000001001" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(proj_p(7 downto 4)))*16 + (to_integer(vcnt_lat2_p)-548)*2,10));
    when "00000001010" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(proj_p(3 downto 0)))*16 + (to_integer(vcnt_lat2_p)-548)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 564 and vcnt_lat2_p < 572 then
   case (hcnt_lat2_p-400)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(33*16 + (to_integer(vcnt_lat2_p)-564)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(pixel_x_p(8 downto 8)))*16 + (to_integer(vcnt_lat2_p)-564)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(pixel_x_p(7 downto 4)))*16 + (to_integer(vcnt_lat2_p)-564)*2,10));
    when "00000000100" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(pixel_x_p(3 downto 0)))*16 + (to_integer(vcnt_lat2_p)-564)*2,10));
    when "00000000110" => addr_f_n <= std_logic_vector(to_unsigned(34*16 + (to_integer(vcnt_lat2_p)-564)*2,10));
    when "00000001000" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(pixel_y_p(7 downto 4)))*16 + (to_integer(vcnt_lat2_p)-564)*2,10));
    when "00000001001" => addr_f_n <= std_logic_vector(to_unsigned(to_integer(unsigned(pixel_y_p(3 downto 0)))*16 + (to_integer(vcnt_lat2_p)-564)*2,10));
    when "00000001011" => addr_f_n <= std_logic_vector(to_unsigned(31*16 + (to_integer(vcnt_lat2_p)-564)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  elsif vcnt_lat2_p >= 580 and vcnt_lat2_p < 588 then
   case (hcnt_lat2_p-400)/8 is
    when "00000000000" => addr_f_n <= std_logic_vector(to_unsigned(28*16 + (to_integer(vcnt_lat2_p)-580)*2,10));
    when "00000000001" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-580)*2,10));
    when "00000000010" => addr_f_n <= std_logic_vector(to_unsigned(10*16 + (to_integer(vcnt_lat2_p)-580)*2,10));
    when "00000000011" => addr_f_n <= std_logic_vector(to_unsigned(29*16 + (to_integer(vcnt_lat2_p)-580)*2,10));
    when "00000000100" => addr_f_n <= std_logic_vector(to_unsigned(14*16 + (to_integer(vcnt_lat2_p)-580)*2,10));
    when others => addr_f_n <= addr_f_p;
   end case;
  end if;
  addr_ci_n <= std_logic_vector(to_unsigned(((to_integer(hcnt_lat2_p)-440)/32)*16 + (to_integer(vcnt_lat2_p)-432),8));
  addr_c_n <= std_logic_vector(to_unsigned(((to_integer(hcnt_p)-440)/32),4));

  ce_hcnt <= '0';
  ce_vcnt <= '0';

  addr_proj_n <= addr_proj_p;
  if latch_next_index = "00001111" or (hold_ni_p = 5e7 and hcnt_p = 0 and vcnt_p = 0) then
   if next_index_dir = '1' then
    if addr_proj_p(11) = '0' and addr_proj_p(9) = '0' and unsigned(addr_proj_p(8 downto 0)) = 319 then
     addr_proj_n(11 downto 9) <= std_logic_vector(unsigned(addr_proj_p(11 downto 9))+1);
     addr_proj_n(8 downto 0) <= (others => '0');
    elsif addr_proj_p(11) = '0' and addr_proj_p(9) = '1' and unsigned(addr_proj_p(8 downto 0)) = 239 then
     addr_proj_n(11 downto 9) <= std_logic_vector(unsigned(addr_proj_p(11 downto 9))+1);
     addr_proj_n(8 downto 0) <= (others => '0');
    elsif addr_proj_p(11 downto 9) = "100" and unsigned(addr_proj_p(8 downto 0)) = 35 then
     addr_proj_n(11 downto 9) <= (others => '0');
     addr_proj_n(8 downto 0) <= (others => '0');
    else
     addr_proj_n(8 downto 0) <= std_logic_vector(unsigned(addr_proj_p(8 downto 0))+1);
    end if;
   else
    if addr_proj_p(11 downto 9) = "000" and unsigned(addr_proj_p(8 downto 0)) = 0 then
     addr_proj_n(11 downto 9) <= "100";
     addr_proj_n(8 downto 0) <= std_logic_vector(to_unsigned(35, 9));
    elsif addr_proj_p(11) = '0' and addr_proj_p(9) = '1' and unsigned(addr_proj_p(8 downto 0)) = 0 then
     addr_proj_n(11 downto 9) <= std_logic_vector(unsigned(addr_proj_p(11 downto 9))-1);
     addr_proj_n(8 downto 0) <= std_logic_vector(to_unsigned(319, 9));
    elsif (addr_proj_p(11 downto 9) = "010" or addr_proj_p(11 downto 9) = "100") and unsigned(addr_proj_p(8 downto 0)) = 0 then
     addr_proj_n(11 downto 9) <= std_logic_vector(unsigned(addr_proj_p(11 downto 9))-1);
     addr_proj_n(8 downto 0) <= std_logic_vector(to_unsigned(239, 9));
    else
     addr_proj_n(8 downto 0) <= std_logic_vector(unsigned(addr_proj_p(8 downto 0))-1);
    end if;
   end if;
  end if;

  pixel_x_n <= pixel_x_p;
  pixel_y_n <= pixel_y_p;
  if latch_next_pixel = "00001111" or (hold_np_p = 5e7 and hcnt_p = 0 and vcnt_p = 0) then
   if next_pixel_dir = '1' then
    if next_pixel_ori = '1' then
     if unsigned(pixel_y_p) = 239 then
      pixel_y_n <= (others => '0');
     else
      pixel_y_n <= std_logic_vector(unsigned(pixel_y_p)+1);
     end if;
    else
     if unsigned(pixel_x_p) = 319 then
      pixel_x_n <= (others => '0');
     else
      pixel_x_n <= std_logic_vector(unsigned(pixel_x_p)+1);
     end if;
    end if;
   else
    if next_pixel_ori = '1' then
     if unsigned(pixel_y_p) = 0 then
      pixel_y_n <= std_logic_vector(to_unsigned(239, 8));
     else
      pixel_y_n <= std_logic_vector(unsigned(pixel_y_p)-1);
     end if;
    else
     if unsigned(pixel_x_p) = 0 then
      pixel_x_n <= std_logic_vector(to_unsigned(319, 9));
     else
      pixel_x_n <= std_logic_vector(unsigned(pixel_x_p)-1);
     end if;
    end if;
   end if;
  end if;

  proj_n <= proj_p;
  case unsigned(addr_proj_p(11 downto 9)) is
   when "000" =>
    if addr_proj_p(8 downto 0) = addr_px1_lat1_p then
     proj_n <= "0" & din_px1;
    end if;
   when "001" =>
    if addr_proj_p(7 downto 0) = addr_py1_lat1_p then
     proj_n <= din_py1;
    end if;
   when "010" =>
    if addr_proj_p(8 downto 0) = addr_px2_lat1_p then
     proj_n <= "0" & din_px2;
    end if;
   when "011" =>
    if addr_proj_p(7 downto 0) = addr_py2_lat1_p then
     proj_n <= din_py2;
    end if;
   when "100" =>
    if addr_proj_p(5 downto 0) = addr_d_lat1_p then
     proj_n <= din_d;
    end if;
   when others =>
    proj_n <= proj_p;
  end case;

  pixel_dat_n <= pixel_dat_p;
  if hcnt_lat4_p < 320 then
   if vcnt_lat4_p < 240 then
    if unsigned(pixel_x_p) = hcnt_lat4_p and unsigned(pixel_y_p) = vcnt_lat4_p then
     pixel_dat_n(3 downto 1) <= din1;
    end if;
   elsif vcnt_lat4_p < 480 then
    if unsigned(pixel_x_p) = hcnt_lat4_p and unsigned(pixel_y_p) = vcnt_lat4_p-240 then
     pixel_dat_n(3 downto 1) <= din1;
    end if;
   end if;
  elsif hcnt_lat4_p >= 400 and hcnt_lat4_p < 720 and vcnt_lat4_p < 240 then
   if unsigned(pixel_x_p) = hcnt_lat4_p-400 and unsigned(pixel_y_p) = vcnt_lat4_p then
    pixel_dat_n(0) <= din2;
   end if;
  end if;

  y0_n <= y0_p;
  y1_n <= y1_p;
  if bounds_addr = addr_b_lat1_p then
   y0_n <= din_by0;
   y1_n <= din_by1;
  end if;

  cdm_n <= cdm_p;
  if bounds_addr = addr_c_lat1_p then
   cdm_n <= din_c;
  end if;

  hold_ni_n <= hold_ni_p+1;
  ce_hold_ni <= latch_next_index(0);
  if hold_ni_p = 5e7 then
   ce_hold_ni <= '0';
  end if;

  hold_np_n <= hold_np_p+1;
  ce_hold_np <= latch_next_pixel(0);
  if hold_np_p = 5e7 then
   ce_hold_np <= '0';
  end if;

  --main:
  if hcnt_lat1_p = 0 then
   if vblank_p = '0' then
    active_n <= '1';
   end if;
  end if;
  if hcnt_lat1_p = 800 then
   active_n <= '0';
  end if;
  if hcnt_lat4_p = 856 then
   hs_n <= '0';
  end if;
  if hcnt_lat4_p = 976 then
   hs_n <= '1';
  end if;

  if vcnt_p = 0 then
   vblank_n <= '0';
  end if;
  if vcnt_p = 600 then
   vblank_n <= '1';
  end if;
  if vcnt_lat4_p = 637 then
   vs_n <= '0';
  end if;
  if vcnt_lat4_p = 643 then
   vs_n <= '1';
  end if;

  if hcnt_lat3_p < 320 then
   if unsigned(addr_b_p) < unsigned(bounds_count)-1 then
    if hcnt_lat3_p = unsigned(din_bx1)+1 then
     ce_addr_b <= '1';
    end if;
   end if;
  elsif hcnt_lat3_p >= 400 and hcnt_lat3_p < 720 then
   if unsigned(addr_b_p) < unsigned(bounds_count)-1 then
    if hcnt_lat3_p-400 = unsigned(din_bx1)+1 then
     ce_addr_b <= '1';
    end if;
   end if;
  else
   r_addr_b <= '1';
  end if;

  if clk_div_p = '1' then
   if hcnt_p = 1039 then
    ce_vcnt <= '1';
   end if;
   ce_hcnt <= '1';
  end if;

  if hcnt_p = 0 and vcnt_p = 0 then
   icr_btn <= '1';
  else
   icr_btn <= '0';
  end if;

 end process;

 output_process: process(hs_p, vs_p, active_lat3_p, r_p, g_p, b_p, addr1_p, addr2_p, addr_py1_p, addr_px1_p, addr_px2_p, addr_py2_p, addr_b_p, addr_f_p, addr_c_p, addr_ci_p, addr_d_p)
 begin
  hs <= hs_p;
  vs <= vs_p;
  active <= active_lat3_p;
  r <= r_p;
  g <= g_p;
  b <= b_p;
  addr1 <= addr1_p;
  addr2 <= addr2_p;
  addr_py1 <= addr_py1_p;
  addr_px1 <= addr_px1_p;
  addr_px2 <= addr_px2_p;
  addr_py2 <= addr_py2_p;
  addr_b <= addr_b_p;
  addr_f <= addr_f_p;
  addr_c <= addr_c_p;
  addr_ci <= addr_ci_p;
  addr_d <= addr_d_p;
 end process;

end behavioral;