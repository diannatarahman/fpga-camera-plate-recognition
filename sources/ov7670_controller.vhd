library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov7670_controller is
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
end ov7670_controller;

architecture behavioral of ov7670_controller is
signal send_p, send_n : std_logic;
signal rw_p, rw_n : std_logic;
signal addr_p, addr_n : std_logic_vector(7 downto 0);
signal data_p, data_n : std_logic_vector(7 downto 0);
signal busy_p, busy_n : std_logic;
signal config_finished_p, config_finished_n : std_logic;
signal latch_sccb_busy : std_logic;
signal delay_cnt_p, delay_cnt_n : unsigned(16 downto 0);
signal ce_delay_cnt : std_logic;
signal r_delay_cnt : std_logic;
signal exec_cnt_p, exec_cnt_n : natural;
signal ce_exec_cnt : std_logic;
signal ce_addr_data : std_logic;
type config_mem_type is array(natural range <>) of std_logic_vector(15 downto 0);
constant config_mem : config_mem_type := (
 --software reset register
 x"12" & "10000000",
 --set resolusi vga
 x"32" & "11110110",
 x"17" & "00010011",
 x"18" & "00000001",
 x"19" & "00000010",
 x"1a" & "01111010",
 x"03" & "00001010",
 --set format warna yuv
 x"04" & "00000000",
 x"14" & "00111000",
 x"4f" & "01000000",
 x"50" & "00110100",
 x"51" & "00001100",
 x"52" & "00010111",
 x"53" & "00101001",
 x"54" & "01000000",
 x"3d" & "11000000",
 x"3a" & "00001100",
 x"1e" & "00000111",
 x"74" & "00010000",
 x"b1" & "00001100",
 x"b3" & "10000010",
 x"0c" & "00000000",
 x"3e" & "00000000",
 x"58" & "00011110",
 x"11" & "00000000",
 x"0e" & "01100001",
 x"0f" & "01001011",
 x"16" & "00000010",
 x"21" & "00000010",
 x"22" & "10010001",
 x"29" & "00000111",
 x"33" & "00001011",
 x"35" & "00001011",
 x"37" & "00011101",
 x"38" & "01110001",
 x"39" & "00101010",
 x"3c" & "01111000",
 x"4d" & "01000000",
 x"4e" & "00100000",
 x"69" & "00000000",
 x"74" & "00010000",
 x"8d" & "01001111",
 x"8e" & "00000000",
 x"8f" & "00000000",
 x"90" & "00000000",
 x"91" & "00000000",
 x"96" & "00000000",
 x"9a" & "00000000",
 x"b0" & "10000100",
 x"b2" & "00001110",
 x"b8" & "00001010"
);
begin

 clock_process1: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' then
    send_p <= '0';
    rw_p <= '0';
    addr_p <= (others => '0');
    data_p <= (others => '0');
    busy_p <= '0';
    config_finished_p <= '0';
    exec_cnt_p <= 0;
   else
    send_p <= send_n;
    rw_p <= rw_n;
    if ce_addr_data = '1' then
     addr_p <= addr_n;
     data_p <= data_n;
    end if;
    busy_p <= busy_n;
    config_finished_p <= config_finished_n;
    if ce_exec_cnt = '1' then
     exec_cnt_p <= exec_cnt_n;
    end if;
   end if;
   latch_sccb_busy <= sccb_busy;
  end if;
 end process;

 clock_process2: process(clk_100mhz)
 begin
  if rising_edge(clk_100mhz) then
   if reset = '1' or r_delay_cnt = '1' then
    delay_cnt_p <= (others => '0');
   elsif ce_delay_cnt = '1' then
    delay_cnt_p <= delay_cnt_n;
   end if;
  end if;
 end process;

 next_state_process: process(send_p, rw_p, addr_p, data_p, busy_p, config_finished_p, sccb_busy, start_config, delay_cnt_p, exec_cnt_p, latch_sccb_busy)
 begin
  --default:
  send_n <= send_p;
  rw_n <= rw_p;
  addr_n <= config_mem(exec_cnt_p)(15 downto 8);
  data_n <= config_mem(exec_cnt_p)(7 downto 0);
  busy_n <= busy_p;
  config_finished_n <= config_finished_p;
  delay_cnt_n <= delay_cnt_p + 1;
  exec_cnt_n <= exec_cnt_p + 1;
  ce_delay_cnt <= '0';
  r_delay_cnt <= '0';
  ce_exec_cnt <= '0';
  ce_addr_data <= '0';

  --main:
  if busy_p = '0' then
   if start_config = '1' then
    config_finished_n <= '0';
    busy_n <= '1';
   end if;
  else
   if sccb_busy = '0' then
    if exec_cnt_p /= config_mem'length-1 then
     if exec_cnt_p = 1 and delay_cnt_p /= 99999 then
      ce_delay_cnt <= '1';
     else
      send_n <= '1';
      rw_n <= '0';
      ce_addr_data <= '1';
     end if;
    else
     config_finished_n <= '1';
     busy_n <= '0';
    end if;
   else
    if latch_sccb_busy = '0' then
     ce_exec_cnt <= '1';
     r_delay_cnt <= '1';
    end if;
    send_n <= '0';
   end if;
  end if;
 end process;

 output_process: process(send_p, rw_p, addr_p, data_p, busy_p, config_finished_p)
 begin
  send <= send_p;
  rw <= rw_p;
  addr <= addr_p;
  data <= data_p;
  busy <= busy_p;
  config_finished <= config_finished_p;
 end process;
end behavioral;