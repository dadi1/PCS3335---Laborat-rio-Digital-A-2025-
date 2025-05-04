library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
  port (
    clock, reset: in std_logic;
    control: out std_logic_vector(1 downto 0);
    rst: out std_logic;
	 clk_out: out std_logic
  ) ;
end fsm;

architecture comportamental of fsm is

    component counter
        generic (
            DIV: natural:= 8 --Tamanho em bits
        );
        port (
            clock, reset: in std_logic; --Clock e reset sincrono ativo alto
            enable: in std_logic; --Habilita a contagem
            divisor : in std_logic_vector (DIV-1 downto 0 );
            data_o: out std_logic --Saida 
        );
    end component; 

    signal enable: std_logic := '1';
    signal divisor: std_logic_vector(4 downto 0) := "10000";
    signal clk: std_logic;

    type estado_t is (RESETAR, START, DESLOCA, PAR, FIM);
    signal PE,EA : estado_t;

begin

    contador: counter --divide o clock em 16
        generic map(DIV => 5)
        port map (clock, reset, enable, divisor, clk);
		  
    
    sincrono: process(clk, reset) --troca de estados
		variable count: integer := 0; --contador de deslocamentos
    begin
        if (reset='1') then
          EA <= RESETAR; --reseta os estados
			 count := 0;
        elsif (rising_edge(clk)) then
			 if(EA=DESLOCA and count < 8) then	--mantem o estado de deslocar
				EA <= DESLOCA;
				count := count +1; 
			 else
				EA <= PE; --troca de estado
				count := 0;
			 end if;
        end if;
    end process sincrono;

    PE <= --proximos estados
        RESETAR when reset='1' else
        START when EA=RESETAR or EA= FIM else
        DESLOCA when EA=START else
        PAR when EA=DESLOCA else
        FIM when EA= PAR else
        RESETAR;


    control <= --saida de controle registrador
        "00" when EA=START else
        "01" when EA=DESLOCA else
        "10" when EA=PAR else
        "11" when EA=FIM else
        "11";
    
    rst <= --saida de reset registrador
        '1' when EA=RESETAR else
        '0';
		  
	clk_out <= clk; --saida de clock registrador

end comportamental ; -- comportamental