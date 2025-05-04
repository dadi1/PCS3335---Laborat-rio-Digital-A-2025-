library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LSR is
    port (
        clock , reset, data_request, endbit: in std_logic; --Clock e reset assincrono ativo alto
		  mux: in std_logic_vector (1 downto 0);
        data_o: out std_logic_vector(7 downto 0) --Saida paralela
    );
end LSR;

architecture comportamental of LSR is
    signal data : std_logic_vector (7 downto 0) := (others => '0'); --armazena o array de data do input

begin
    process(clock, reset) 
    begin
        if reset = '1' then --reset
            data <= "00100000";
        elsif (clock'event and clock = '1') then
				if(mux = "01") then
					data <= "00010000";
				elsif(data_request = '1') then
					data <= (others => '0');
				elsif(endbit = '1') then
					data <= "00100000";
				end if;
        end if;
    end process ; -- identifier
	 
	 data_o <= data;
   
end comportamental ; -- comportamental