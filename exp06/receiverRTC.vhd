library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity baudRateGenerator is
    generic (
        WIDTH: natural := 24;       -- Tamanho em Bits
        CLOCK_V: natural := 1843200      -- Clock em Hz
    );
    port (
        clock, reset: in std_logic; -- Reset assincrono ativo alto
        divisor: in std_logic_vector(15 downto 0); -- Divisor
        baudOut_n: out std_logic -- Saida do clock dividida
    );
end baudRateGenerator;

architecture impl of baudRateGenerator is
    type estado is (L, D);
    signal EA, PE: estado;

    -- Sinais do clock
    signal div: std_logic_vector(WIDTH-1 downto 0);

    -- Sinais contador
    signal rst_c: std_logic;
    signal data: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal count: std_logic_vector(WIDTH-1 downto 0);

    component counter is
        port (
            clock, reset: in std_logic; -- Clock e reset assincrono ativo alto
            enable: in std_logic; -- Habilita contagem
            load: in std_logic; -- Carga paralela
            up: in std_logic; -- 0: contagem decrescente, 1: crescente
            data_i: in std_logic_vector(WIDTH-1 downto 0); -- Entrada paralela
            fix: in std_logic; -- Para arrumar defasagem
            data_o: out std_logic_vector(WIDTH-1 downto 0) -- Saida paralela
        );
    end component;

begin
    contador: counter port map(clock, rst_c, '1', '0', '1', data, '1', count);

    -- Divisor do clock
    div <= std_logic_vector(resize(resize(unsigned(divisor), WIDTH) * to_unsigned(8, WIDTH), WIDTH));

    -- Processo do clock
    down_clock: process(clock, reset)
    begin
        if(reset = '1') then
            rst_c <= '1';

        elsif(clock'event and clock = '1') then
            if(count = div) then
                EA <= PE;
                rst_c <= '1';
            else
                rst_c <= '0';
            end if;
        end if;
    end process down_clock;

    PE <= L when EA=D else
          D when EA=L else
          D;

    baudOut_n <= '1' when EA=L else '0';

end architecture;