library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov7670_capture is
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
end ov7670_capture;

architecture behavioral of ov7670_capture is
component shift_ram_638_8bit is
 port (
  d : in std_logic_vector(7 downto 0);
  clk : in std_logic;
  ce : in std_logic;
  sclr : in std_logic;
  q : out std_logic_vector(7 downto 0)
 );
end component;

component simple_edge_detect is
 port (
  clk : in std_logic;
  reset : in std_logic;
  threshold : in std_logic_vector(9 downto 0);
  t_en : in std_logic;
  op1 : in std_logic_vector(9 downto 0);
  op2 : in std_logic_vector(9 downto 0);
  en : in std_logic;
  r : out std_logic
 );
end component;

signal dout1_p, dout1_n : std_logic_vector(9 downto 0);
signal we1_p, we1_n : std_logic;
signal ce_dout1 : std_logic;
signal dout1_1_p, dout1_1_n : std_logic_vector(9 downto 0);
signal dout1_2_p, dout1_2_n : std_logic_vector(9 downto 0);
signal dout2_p, dout2_n : std_logic;
signal we2_p, we2_n : std_logic;
signal ce_dout2 : std_logic;
signal ce_cntx_p, ce_cntx_n : std_logic;
signal ce_shiftreg_p, ce_shiftreg_n : std_logic;
signal pclk_div_p, pclk_div_n : std_logic;
signal latch_pclk : std_logic_vector(1 downto 0);
signal latch_vsync : std_logic_vector(1 downto 0);
signal din0_p, din0_n : std_logic_vector(7 downto 0);
signal din1_p, din1_n : std_logic_vector(7 downto 0);
signal din2_p, din2_n : std_logic_vector(7 downto 0);
signal din3_p, din3_n : std_logic_vector(7 downto 0);
signal shift_ram_d : std_logic_vector(7 downto 0);
signal shift_ram_q : std_logic_vector(7 downto 0);
signal shift_ram_sclr : std_logic;
signal en1_p, en1_n : std_logic;
signal en2_p, en2_n : std_logic;
signal en3_p, en3_n : std_logic_vector(1 downto 0);
signal en4_p, en4_n : std_logic;
signal r : std_logic_vector(1 downto 0);
signal r_acc_p, r_acc_n : std_logic;
signal finished_p, finished_n : std_logic;
type state_type is (inactive, active);
signal state_p, state_n : state_type;
signal t_en : std_logic;
signal pc_count_p, pc_count_n : std_logic_vector(7 downto 0);
signal ce_pc_count_digit, r_pc_count_digit : std_logic_vector(1 downto 0);
signal pc_p, pc_n : std_logic_vector(7 downto 0);
signal ce_pc, r_pc : std_logic;
begin

 inst_shift_ram_638_8bit: shift_ram_638_8bit port map (
  d => shift_ram_d,
  clk => clk_100mhz,
  ce => ce_shiftreg_p,
  sclr => reset,
  q => shift_ram_q
 );

 inst_simple_edge_detect1: simple_edge_detect port map (
  clk => clk_100mhz,
  reset => reset,
  threshold => threshold,
  t_en => t_en,
  op1 => dout1_1_p,
  op2 => dout1_p,
  en  => en3_p(0),
  r => r(0)
 );

 inst_simple_edge_detect2: simple_edge_detect port map (
  clk => pclk,
  reset => reset,
  threshold => threshold,
  t_en => t_en,
  op1 => dout1_1_p,
  op2 => dout1_2_p,
  en  => en3_p(1),
  r => r(1)
 );

 clock_process1: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' then
    state_p <= inactive;
    finished_p <= '0';
    latch_pclk <= (others => '0');
    latch_vsync <= (others => '0');
   else
    state_p <= state_n;
    finished_p <= finished_n;
    latch_pclk <= latch_pclk(0) & pclk;
    latch_vsync <= latch_vsync(0) & vsync;
   end if;
  end if;
 end process;

 clock_process2: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' or vsync = '1' then
    we1_p <= '0';
    we2_p <= '0';
    ce_cntx_p <= '0';
    ce_shiftreg_p <= '0';
    r_acc_p <= '0';
    pclk_div_p <= '0';
    din0_p <= (others => '0');
    din1_p <= (others => '0');
    din2_p <= (others => '0');
    din3_p <= (others => '0');
    dout1_p <= (others => '0');
    dout1_1_p <= (others => '0');
    dout1_2_p <= (others => '0');
    dout2_p <= '0';
    en1_p <= '0';
    en2_p <= '0';
    en3_p <= (others => '0');
    en4_p <= '0';
   else
    we1_p <= we1_n;
    we2_p <= we2_n;
    ce_cntx_p <= ce_cntx_n;
    ce_shiftreg_p <= ce_shiftreg_n;
    r_acc_p <= r_acc_n;
    pclk_div_p <= pclk_div_n;
    en1_p <= en1_n;
    en2_p <= en2_n;
    en3_p <= en3_n;
    en4_p <= en4_n;
    if ce_shiftreg_p = '1' then
     din0_p <= din0_n;
     din1_p <= din1_n;
     din2_p <= din2_n;
     din3_p <= din3_n;
    end if;
    if ce_dout1 = '1' then
     dout1_p <= dout1_n;
    end if;
    if ce_dout2 = '1' then
     dout2_p <= dout2_n;
    end if;
    if ce_dout1 = '1' or ce_dout2 = '1' then
     dout1_1_p <= dout1_1_n;
     dout1_2_p <= dout1_2_n;
    end if;
   end if;
   for i in 0 to 1 loop
    if reset = '1' or r_pc_count_digit(i) = '1' then
     pc_count_p((i*4)+3 downto i*4) <= (others => '0');
    elsif ce_pc_count_digit(i) = '1' then
     pc_count_p((i*4)+3 downto i*4) <= pc_count_n((i*4)+3 downto i*4);
    end if;
   end loop;
   if reset = '1' or r_pc = '1' then
    pc_p <= (others => '0');
   elsif ce_pc = '1' then
    pc_p <= pc_n;
   end if;
  end if;
 end process;

 next_state_process: process(dout1_p, we1_p, dout2_p, we2_p, href, latch_vsync, latch_pclk, r, r_acc_p, din0_p, din1_p, din2_p, din3_p, dout1_1_p, dout1_2_p, din, capture, ce_cntx_p, ce_shiftreg_p, state_p, shift_ram_q, pclk_div_p, en1_p, en2_p, en3_p, en4_p, finished_p, cnty, cntx, pc_count_p, pc_p)
 begin
  --default:
  din0_n <= din;
  din1_n <= din0_p;
  shift_ram_d <= din1_p;
  din2_n <= shift_ram_q;
  din3_n <= din2_p;
  dout1_n <= std_logic_vector(to_unsigned(to_integer(unsigned(din0_p))+to_integer(unsigned(din1_p))+to_integer(unsigned(din2_p))+to_integer(unsigned(din3_p)),10));
  we1_n <= '0';
  dout1_1_n <= dout1_p;
  dout1_2_n <= dout1_1_p;
  dout2_n <= r(0) or r(1);
  we2_n <= '0';
  en1_n <= en1_p;
  en2_n <= en2_p;
  en3_n <= en3_p;
  en4_n <= en4_p;
  ce_cntx_n <= '0';
  ce_shiftreg_n <= '0';
  pclk_div_n <= '0';
  state_n <= state_p;
  r_acc_n <= '0';
  finished_n <= finished_p;
  ce_dout1 <= '0';
  ce_dout2 <= '0';
  if state_p = active then
   t_en <= '0';
  else
   t_en <= '1';
  end if;
  for i in 0 to 1 loop
   pc_count_n((i*4)+3 downto i*4) <= std_logic_vector(unsigned(pc_count_p((i*4)+3 downto i*4))+1);
   ce_pc_count_digit <= (others => '0');
   r_pc_count_digit <= (others => '0');
  end loop;
  ce_pc_count_digit(0) <= '1';
  if pc_count_p(3 downto 0) = x"9" then
   ce_pc_count_digit(1) <= '1';
   r_pc_count_digit(0) <= '1';
  end if;
  if pc_count_p(7 downto 0) = x"99" then
   r_pc_count_digit(1) <= '1';
  end if;
  pc_n <= pc_count_p;
  ce_pc <= '0';
  r_pc <= '0';

  --main:
  if latch_pclk = "10" then
   r_pc_count_digit <= (others => '1');
   r_pc_count_digit(0) <= '0';
   pc_count_n(3 downto 0) <= "0001";
   ce_pc <= '1';
  end if;

  if latch_vsync = "01" then
   if capture = '1' then
    state_n <= active;
   else
    state_n <= inactive;
   end if;
   finished_n <= '0';
  end if;

  if state_p = active and (href = '1' or en4_p = '1') then
   pclk_div_n <= pclk_div_p;
   if latch_pclk = "10" then
    pclk_div_n <= not pclk_div_p;
    ce_shiftreg_n <= pclk_div_p;
   end if;
   ce_cntx_n <= ce_shiftreg_p;
  end if;

  if ce_cntx_p = '1' then
   if cnty = 1 then
    if cntx = 1 then
     en1_n <= '1';
    end if;
    if cntx = 4 then
     en2_n <= '1';
    end if;
   end if;
   if cnty(0) = '1' then
    if cntx = 4 then
     en3_n <= "01";
     if en2_p = '1' then
      r_acc_n <= '1';
     end if;
    end if;
    if cntx = 6 then
     en3_n <= "11";
    end if;
    if cntx = 2 then
     en3_n <= "10";
    end if;
   end if;
   if cnty = 479 then
    en4_n <= '1';
   end if;
   if cnty = 480 then
    if cntx = 0 then
     en1_n <= '0';
    end if;
    if cntx = 2 then
     en3_n <= "10";
    end if;
    if cntx = 4 then
     en2_n <= '0';
     en3_n <= "00";
     en4_n <= '0';
     r_acc_n <= '1';
     finished_n <= '1';
    end if;
   end if;
  end if;

  if ce_shiftreg_p = '1' then
   if cntx(0) = '0' and (cnty(0) = '1' or cnty = 480) then
    if en1_p = '1' then
     ce_dout1 <= '1';
     we1_n <= '1';
    end if;
    if en2_p = '1' then
     ce_dout2 <= '1';
     we2_n <= '1';
    end if;
   end if;
  end if;
 end process;

 output_process: process(ce_cntx_p, r_acc_p, dout1_p, we1_p, dout2_p, we2_p, finished_p, pc_p)
 begin
  ce_cntx <= ce_cntx_p;
  r_acc <= r_acc_p;
  dout1 <= dout1_p(9 downto 7);
  we1 <= we1_p;
  dout2 <= dout2_p;
  we2 <= we2_p;
  finished <= finished_p;
  pixel_clock <= pc_p;
 end process;
end behavioral;