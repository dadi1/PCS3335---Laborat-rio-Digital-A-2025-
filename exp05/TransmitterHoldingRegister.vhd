library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transmitterHoldingRegister is
    port (
        reg_in : in std_logic_vector(7 downto 0);
        load   : in std_logic;
        rst    : in std_logic;
        clk    : in std_logic;
        reg_out : out std_logic_vector(7 downto 0)
    );
end transmitterHoldingRegister;

architecture behaviour of transmitterHoldingRegister is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            reg_out <= "00000000";
        elsif rising_edge(clk) then
            if load = '1' then
                reg_out <= reg_in;
            else
                reg_out <= reg_in;
            end if;
        end if;
    end process;
end behaviour;
