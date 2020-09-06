library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ov7670_sccb is
end tb_ov7670_sccb;

architecture behavior of tb_ov7670_sccb is
-- component declaration for the unit under test (uut)
component ov7670_sccb
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

--inputs
signal clk_100mhz : std_logic := '0';
signal reset : std_logic := '1';
signal pwdn_trig : std_logic := '0';
signal send : std_logic := '0';
signal rw : std_logic := '0';
signal addr : std_logic_vector(7 downto 0) := (others => '0');
signal din : std_logic_vector(7 downto 0) := (others => '0');
--bidirs
signal siod : std_logic := 'z';
--outputs
signal dout : std_logic_vector(7 downto 0);
signal sioc : std_logic;
signal busy : std_logic;
signal pwdn : std_logic;
-- clock period definitions
constant clk_100mhz_period : time := 10 ns;
begin
 -- instantiate the unit under test (uut)
 uut: ov7670_sccb port map (
  clk_100mhz => clk_100mhz,
  reset => reset,
  pwdn_trig => pwdn_trig,
  send => send,
  rw => rw,
  addr => addr,
  din => din,
  dout => dout,
  sioc => sioc,
  siod => siod,
  busy => busy,
  pwdn => pwdn
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

 -- stimulus process
 stim_proc2: process
 begin
  wait for 100 ns;
  wait for clk_100mhz_period*10;
  send <= '1';
  rw <= '0';
  addr <= x"ab";
  din <= x"cd";
  wait for 100 ns;
  wait for clk_100mhz_period*10;
  send <= '0';
  addr <= x"00";
  din <= x"00";
  wait until busy = '0';
 end process;
end;