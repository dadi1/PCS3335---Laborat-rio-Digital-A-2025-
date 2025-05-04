library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	generic (
	DIV: natural:= 8 --Tamanho em bits divisor
	);
	port (
	clock, reset: in std_logic; --Clock e reset assincrono ativo alto
	enable: in std_logic; --Habilita a contagem
   divisor : in std_logic_vector (DIV-1 downto 0);
	data_o: out std_logic --Saida 
	);
end counter;
    
architecture comportamental of counter is
	signal IQ: unsigned (DIV-1 downto 0) := (others => '0');

	begin
	process (clock, reset)
	begin
		if reset = '1' then
            	IQ <= (others=> '0'); -- reset sincronizado
		elsif clock'event and clock = '1' then
        	if enable = '1' then
            	if IQ = unsigned(divisor)-1 then --compara valor com divisor
                	data_o <= '1'; --clock ativo alto
                    IQ <= (others => '0'); --zera o contador
                elsif IQ > (unsigned(divisor)/2) then
                    data_o <= '0';
                    IQ <= IQ + 1;
                else
                    IQ<= IQ + 1;                    
            	end if;
        	end if;
    	end if;
	end process;

	
end comportamental;