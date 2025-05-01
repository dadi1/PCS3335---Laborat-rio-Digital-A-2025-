library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rsr is
    port(
        clk     : in std_logic;
        reset   : in std_logic;
        load    : in std_logic; -- início da recepção
        shift    : in std_logic;
        serial_in: in std_logic;
        data_out : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of rsr is
    signal reg : std_logic_vector(7 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                reg <= (others => '0');
            elsif shift = '1' then
                reg <= serial_in & reg(7 downto 1); -- desloca para direita
            end if;
        end if;
    end process;

    data_out <= reg;
end architecture;