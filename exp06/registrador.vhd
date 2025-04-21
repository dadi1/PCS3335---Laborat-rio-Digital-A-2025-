library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shiftregister is
    generic(
        WIDTH: natural := 8
    );

    port (
        clock, reset: in std_logic; -- Reset assincrono
        loadOrShift: in std_logic_vector(1 downto 0);
        serial_i: in std_logic;
        data_i: in std_logic_vector(WIDTH-1 downto 0);
        data_o: out std_logic_vector(WIDTH-1 downto 0);
        serial_o_r: out std_logic;
        serial_o_l: out std_logic
    );
end shiftregister;

architecture impl of shiftregister is
    constant MIN_VALUE: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal registrador: std_logic_vector(WIDTH-1 downto 0) := (others => '0');

begin
    process(clock, reset)
    begin
        if reset = '1' then
            registrador <= MIN_VALUE;
        
        elsif (clock'event and clock = '1') then

            if(loadOrShift = "11") then
                registrador <= data_i;
            
            elsif(loadOrShift = "10") then
                for i in WIDTH-1 downto 1 loop
                    registrador(i) <= registrador(i-1);
                end loop;
                registrador(0) <= '0';

            elsif(loadOrShift = "01") then
                for i in 0 to WIDTH-2 loop
                    registrador(i) <= registrador(i+1);
                end loop;
                registrador(WIDTH-1) <= '0';
            end if;
        end if;
        serial_o_r <= registrador(0);
        serial_o_l <= registrador(WIDTH - 1);
        data_o <= registrador;
    end process;
end architecture;