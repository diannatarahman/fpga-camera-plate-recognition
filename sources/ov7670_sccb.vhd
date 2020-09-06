library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov7670_sccb is
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
end ov7670_sccb;

architecture behavioral of ov7670_sccb is
signal cnt1k_p, cnt1k_n : unsigned(9 downto 0);
signal cntc_p, cntc_n : unsigned(3 downto 0);
signal pwdn_p, pwdn_n : std_logic;
signal sioc_p, sioc_n : std_logic;
signal siod_p, siod_n : std_logic;
signal busy_p, busy_n : std_logic;
signal dout_p, dout_n : std_logic_vector(7 downto 0);
signal sreg_p, sreg_n : std_logic_vector(6 downto 0);
signal latch_pwdn_trig : std_logic;
signal buff_addr_p, buff_addr_n : std_logic_vector(7 downto 0);
signal buff_din_p, buff_din_n : std_logic_vector(7 downto 0);
signal buff_rw_p, buff_rw_n : std_logic;
type state_type is (idle, start, id, address, data, stop, suspend);
signal state_p, state_n : state_type;
type transmission_type is (tr_write, tr_read);
signal tr_p, tr_n : transmission_type;
constant ov7670_id : std_logic_vector(6 downto 0) := "0100001";
begin

 clock_process: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' then
    cnt1k_p <= (others => '0');
    dout_p <= (others => '0');
    sreg_p <= (others => '0');
    cntc_p <= (others => '0');
    sioc_p <= '1';
    siod_p <= 'z';
    state_p <= idle;
    busy_p <= '0';
    buff_addr_p <= (others => '0');
    buff_din_p <= (others => '0');
    buff_rw_p <= '0';
    tr_p <= tr_write;
   else
    cnt1k_p <= cnt1k_n;
    dout_p <= dout_n;
    sreg_p <= sreg_n;
    cntc_p <= cntc_n;
    sioc_p <= sioc_n;
    siod_p <= siod_n;
    state_p <= state_n;
    busy_p <= busy_n;
    buff_addr_p <= buff_addr_n;
    buff_din_p <= buff_din_n;
    buff_rw_p <= buff_rw_n;
    tr_p <= tr_n;
   end if;
   latch_pwdn_trig <= pwdn_trig;
   pwdn_p <= pwdn_n;
  end if;
 end process;

 next_state_process: process(latch_pwdn_trig, pwdn_trig, pwdn_p, sioc_p, siod_p, state_p, busy_p, send, tr_p, siod, dout_p, cntc_p, buff_addr_p, buff_din_p, buff_rw_p, cnt1k_p, addr, din, rw, sreg_p)
 begin
  --default:
  if cnt1k_p = 999 then
   cnt1k_n <= (others => '0');
  else
   cnt1k_n <= cnt1k_p + 1;
  end if;
  dout_n <= dout_p;
  sreg_n <= sreg_p;
  cntc_n <= cntc_p;
  pwdn_n <= '0';
  sioc_n <= sioc_p;
  siod_n <= siod_p;
  state_n <= state_p;
  busy_n <= busy_p;
  buff_addr_n <= buff_addr_p;
  buff_din_n <= buff_din_p;
  buff_rw_n <= buff_rw_p;
  tr_n <= tr_p;

  --main:
  case state_p is
   when idle =>
    if send = '1' and busy_p = '0' then
     siod_n <= '1';
     buff_addr_n <= addr;
     if rw = '0' then
      buff_din_n <= din;
     end if;
     buff_rw_n <= rw;
     state_n <= start;
     busy_n <= '1';
    end if;
    cnt1k_n <= (others => '0');
   when start =>
    if cnt1k_p = 249 then
     siod_n <= '0';
    end if;
    if cnt1k_p = 499 then
     sioc_n <= '0';
     state_n <= id;
     cntc_n <= (others => '0');
    end if;
   when id =>
    if cnt1k_p = 749 then
     case cntc_p is
      when "1000" =>
       siod_n <= '0';
      when "0111" =>
       if tr_p = tr_read then
        siod_n <= '1';
       else
        siod_n <= '0';
       end if;
      when others =>
       siod_n <= ov7670_id(to_integer(6-cntc_p));
     end case;
    end if;
    if cnt1k_p = 999 then
     sioc_n <= '1';
     cntc_n <= cntc_p + 1;
    end if;
    if cnt1k_p = 499 then
     sioc_n <= '0';
     if cntc_p = 9 then
      cntc_n <= (others => '0');
      if tr_p = tr_write then
       state_n <= address;
      else
       state_n <= data;
       siod_n <= 'z';
      end if;
     end if;
    end if;
   when address =>
    if cnt1k_p = 749 then
     if cntc_p = 8 then
      siod_n <= '0';
     else
      siod_n <= buff_addr_p(to_integer(7-cntc_p));
     end if;
    end if;
    if cnt1k_p = 999 then
     sioc_n <= '1';
     cntc_n <= cntc_p + 1;
    end if;
    if cnt1k_p = 499 then
     sioc_n <= '0';
     if cntc_p = 9 then
      cntc_n <= (others => '0');
      if buff_rw_p = '1' then
       state_n <= stop;
      else
       state_n <= data;
      end if;
     end if;
    end if;
   when data =>
    if cnt1k_p = 749 and tr_p = tr_write then
     if cntc_p = 8 then
      siod_n <= '0';
     else
      siod_n <= buff_din_p(to_integer(7-cntc_p));
     end if;
    end if;
    if cnt1k_p = 999 then
     if tr_p = tr_read and cntc_p = 8 then
      siod_n <= '1';
     end if;
     sioc_n <= '1';
     cntc_n <= cntc_p + 1;
    end if;
    if cnt1k_p = 249 then
     if buff_rw_p = '1' and cntc_p /= 9 then
      if cntc_p = 8 then
       dout_n <= sreg_p(6 downto 0) & siod;
      end if;
      sreg_n <= sreg_p(5 downto 0) & siod;
     end if;
    end if;
    if cnt1k_p = 499 then
     sioc_n <= '0';
     if cntc_p = 9 then
      cntc_n <= (others => '0');
      state_n <= stop;
     end if;
    end if;
   when stop =>
    if cnt1k_p = 749 then
     siod_n <= '0';
    end if;
    if cnt1k_p = 999 then
     sioc_n <= '1';
    end if;
    if cnt1k_p = 249 then
     siod_n <= '1';
    end if;
    if cnt1k_p = 499 then
     if buff_rw_p = '1' and tr_p = tr_write then
      tr_n <= tr_read;
      state_n <= start;
      cnt1k_n <= (others => '0');
     else
      tr_n <= tr_write;
      busy_n <= '0';
      siod_n <= 'z';
      state_n <= idle;
     end if;
    end if;
   when others =>
    pwdn_n <= '1';
    if latch_pwdn_trig = '1' and pwdn_trig = '0' then
     sioc_n <= '1';
     siod_n <= 'z';
     cnt1k_n <= (others => '0');
    end if;
    if latch_pwdn_trig = '1' and cnt1k_p = 9 then
     sioc_n <= '0';
     siod_n <= '0';
     dout_n <= (others => '0');
     sreg_n <= (others => '0');
     tr_n <= tr_write;
    end if;
    if latch_pwdn_trig = '0' and cnt1k_p = 9 then
     pwdn_n <= '0';
     if busy_p = '0' then
      state_n <= idle;
     else
      state_n <= start;
      siod_n <= '1';
     end if;
     cnt1k_n <= (others => '0');
    end if;
  end case;

  if latch_pwdn_trig = '0' and pwdn_trig = '1' then
   pwdn_n <= '1';
   cnt1k_n <= (others => '0');
   cntc_n <= (others => '0');
   state_n <= suspend;
  end if;
 end process;

 output_process: process(pwdn_p, sioc_p, siod_p, busy_p, dout_p)
 begin
  pwdn <= pwdn_p;
  sioc <= sioc_p;
  siod <= siod_p;
  busy <= busy_p;
  dout <= dout_p;
 end process;
end behavioral;