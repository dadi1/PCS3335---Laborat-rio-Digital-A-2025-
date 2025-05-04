library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity THR is
    port (
        clock , reset: in std_logic; --Clock e reset assincrono ativo alto
		  mux: in std_logic_vector (1 downto 0); --verifica se thr carrega ou nao
        data_i: in std_logic_vector (7 downto 0 ); --Entradas paralela
        data_o: out std_logic_vector(7 downto 0) --Saida paralela
    );
end THR;

architecture comportamental of THR is
    signal data_reg : std_logic_vector (7 downto 0) := (others => '0'); --armazena o array de data do input

begin
    process(clock, reset) 
    begin
        if reset = '1' then --reset
            data_reg <= (others => '0');
        elsif (clock'event and clock = '1') then
				if mux = "01" then
					data_reg <= data_i;
				end if;
        end if;
    end process ; -- identifier
	 
	 data_o <= data_reg;
   
end comportamental ; -- comportamental