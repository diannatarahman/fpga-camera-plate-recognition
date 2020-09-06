library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity simple_edge_detect is
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
end simple_edge_detect;

architecture behavioral of simple_edge_detect is
signal r_p, r_n : std_logic;
signal latch_threshold : std_logic_vector(9 downto 0);
begin

 clock_process: process(clk)
 begin
  if rising_edge(clk) then
   if reset = '1' or en = '0' then
    r_p <= '0';
   else
    r_p <= r_n;
   end if;
   if t_en = '1' then
    latch_threshold <= threshold;
   end if;
  end if;
 end process;

 next_state_process: process(latch_threshold, op1, op2)
 variable s : unsigned(9 downto 0);
 begin
  if unsigned(op1) < unsigned(op2) then
   s := unsigned(op2) - unsigned(op1);
  else
   s := unsigned(op1) - unsigned(op2);
  end if;
  if s < unsigned(latch_threshold) then
   r_n <= '0';
  else
   r_n <= '1';
  end if;
 end process;

 r <= r_p;
end behavioral;