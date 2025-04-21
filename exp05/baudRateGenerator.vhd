library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity baudRateGenerator is
    port (
        clk       : in std_logic;
        rst       : in std_logic;
        divisor   : in std_logic_vector(15 downto 0);
        baudOut_n : out std_logic
    );
end entity baudRateGenerator;

architecture behaviour of baudRateGenerator is
    signal count    : unsigned(15 downto 0) := (others => '0');
    signal div_val  : unsigned(15 downto 0);
    signal clk_out  : std_logic := '0';
begin
    div_val <= unsigned(divisor);

    process(clk, rst)
    begin
        if rst = '1' then
            count <= (others => '0');
            clk_out <= '1';
        elsif rising_edge(clk) then
            if count = div_val - 1 then
                count <= (others => '0');
                clk_out <= '1';
            else
                count <= count + 1;
                clk_out <= '0';
            end if;
        end if;
    end process;

    baudOut_n <= clk_out;
end behaviour;
