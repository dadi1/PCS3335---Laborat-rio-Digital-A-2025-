library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
	port(clock, reset : in std_logic ; --Clock e reset assincrono ativo alto
	saida_s: out std_logic;
	clk_baud_s: out std_logic;
	clk_fsm_s: out std_logic;
	control_0s: out std_logic;
	control_1s: out std_logic
	);
end toplevel;

architecture comportamental of toplevel is
	component ip_pll
			port (
				refclk   : in  std_logic := '0'; --  refclk.clk
				rst      : in  std_logic := '0'; --   reset.reset
				outclk_0 : out std_logic;        -- outclk0.clk
				locked   : out std_logic         --  locked.export
			);
	end component;
	
	component counter
        generic (
            DIV: natural:= 8 --Tamanho em bits
        );
        port (
            clock, reset: in std_logic; --Clock e reset sincrono ativo alto
            enable: in std_logic; --Habilita a contagem
            divisor : in std_logic_vector (15 downto 0 );
            data_o: out std_logic --Saida 
        );
    end component;
	 
	 component baudRateGenerator 
		  port (
			  clock , reset : in std_logic ; --Clock e reset assincrono ativo alto
			  baudOut_n : out std_logic --saida do clock dividida
			);
	 end component;
	  
	 component fsm
		  port (
			 clock, reset: in std_logic;
			 control: out std_logic_vector(1 downto 0);
			 rst: out std_logic;
			 clk_out: out std_logic
		  );
	 end component;
	 
	 component shiftregister
		generic (
			  WIDTH: natural := 8 --Tamanho em bits
		 );
		 port (
			  clock , reset: in std_logic; --Clock e reset assincrono ativo alto
			  loadOrShift: in std_logic_vector (1 downto 0 );
					--00: bit start
					--01: desloca
					--10: bit par
					--11: bit fim
			  data_i: in std_logic_vector (WIDTH-1 downto 0 ); --Entradas paralela
			  serial_o: out std_logic --Saida serial
		 );
	 end component;
	 signal locked: std_logic;
	 signal pll_clock: std_logic;
	 
	 signal divisor: std_logic_vector(15 downto 0) := "0000000000001100";
	 signal baudOut_n: std_logic; --clock intermediario
	 signal control: std_logic_vector(1 downto 0); --sinais de controle registrador
	 
	--sinais de controle
	 signal controle: std_logic_vector(1 downto 0);
	 signal rst: std_logic;
	 signal clk_reg: std_logic;
	 
	 signal data_i: std_logic_vector(10 downto 0) := "00100000101"; --sinal entrada registrador
	 
begin
	 pll: ip_pll
			port map(clock, reset, pll_clock, locked);

	 baud: baudRateGenerator
			port map(pll_clock, reset, baudOut_n);
			
	 statemachine: fsm
			port map(baudOut_n, reset, controle, rst, clk_reg);
	
	 reg: shiftregister
			generic map(11)
			port map(clk_reg, rst, controle, data_i, saida_s);
			
	clk_baud_s <= baudOut_n; --sinal teste saida baud
	clk_fsm_s <= clk_reg; --sinal teste saida do clock da maquina de estados
	control_0s <= controle(0); --sinal teste controle 0
	control_1s <= controle (1); --sinal teste controle 1
end comportamental;