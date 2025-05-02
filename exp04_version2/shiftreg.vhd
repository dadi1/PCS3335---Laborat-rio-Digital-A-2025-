library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shiftregister is
    generic (
        WIDTH: natural := 12 --Tamanho em bits
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
end shiftregister;

architecture comportamental of shiftregister is
    signal data : std_logic_vector (7 downto 0); --armazena o array de data do input

begin
    process(clock, reset) 
    begin
        if reset = '1' then --reset
            serial_o <= '1';
        elsif clock'event and clock = '1' then
            if loadOrShift = "00" then
                serial_o <= data_i(WIDTH-1); --bit start
                data <= data_i(WIDTH-2 downto 2); -- carrega vetor de dados
            elsif loadOrShift = "01" then
                serial_o <= data(0); --joga bit menos significativo vetor de dados
                data <= '0' & data(7 downto 1); --desloca vetor de dados direita
            elsif loadOrShift = "10" then
                serial_o <= data_i(1); --bit par
            elsif loadOrShift = "11" then
                serial_o <= data_i(0); --bit fim
            end if;
        end if;
        
    end process ; -- identifier

   
end comportamental ; -- comportamental