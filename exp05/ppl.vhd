library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ppl is
    port(
        clk_in: in std_logic;
        clk_out: out std_logic
    );
end ppl

architecture Behavioral of ppl is
begin
    clk_out <= cli_in;
end Behavioral