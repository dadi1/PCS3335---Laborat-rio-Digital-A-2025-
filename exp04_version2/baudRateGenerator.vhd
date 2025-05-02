library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudRateGenerator is
    port (
        clock , reset : in std_logic ; --Clock e reset assincrono ativo alto
        baudOut_n : out std_logic --saida do clock dividida
    ) ;
end baudRateGenerator ;

architecture comportamental of baudRateGenerator is
    component counter
        generic (
            DIV: natural:= 8 --Tamanho em bits do divisor
				);
        port (
            clock, reset: in std_logic; --Clock e reset sincrono ativo alto
            enable: in std_logic; --Habilita a contagem
            divisor : in std_logic_vector (DIV-1 downto 0 );
            data_o: out std_logic --Saida 
        );
    end component;
    signal enable: std_logic := '1';
	 signal divisor: std_logic_vector(3 downto 0) := "1100";


begin

    contador: counter --divide o clock
        generic map(4)
        port map(clock, reset, enable, divisor, baudOut_n);


end comportamental ; -- comportamental