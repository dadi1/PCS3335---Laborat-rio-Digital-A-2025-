library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baudRateGenerator is
    generic (
            WIDTH: natural := 24 -- Largura do contador.
    );
    port (
        clock, reset : in std_logic; -- Clock e reset assíncronos.
        divisor : in std_logic_vector(15 downto 0); -- divisor programável.
        baudOut_n: out std_logic -- Saída do clock dividido.
    );
end baudRateGenerator;

architecture impl of baudRateGenerator is

    -- Definindo os estados para formar o duty cycle de 50%
    type estado is (L,D);
    signal EA: estado := L;
    signal PE: estado;

    -- Sinais de clock dividio.
    signal div: std_logic_vector(WIDTH-1 downto 0);

    -- Sinais para o contador
    signal reset_c: std_logic := '1';
    signal data: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal count: std_logic_vector(WIDTH-1 downto 0);

    -- Declaração do componente contador.
    component counter is
        port (
            clock, reset : in std_logic; -- Clock e reset assíncrono ativo alto.
            enable : in std_logic; -- Habilita contagem.
            load : in std_logic; -- Carga paralela.
            up : in std_logic; -- 0 : contagem decrescente , 1 : crescente.
            data_i : in std_logic_vector(WIDTH-1 downto 0); -- Entrada paralela.
            data_o : out std_logic_vector(WIDTH-1 downto 0) -- Saída paralela.
        );
    end counter;

begin

    -- Instanciação do contador
    contador: counter
        port map (
            clock => clock,
            reset => reset_c,
            enable => '1',
            load => '0',
            up => '1',
            data_i => data,
            data_o => count
        )
    
    -- Calculo do divisor ajustado: divisor *8( para gerar baud x16 conforme UART típica).
    div <= std_logic_vector(resize(resize(unsigned(divisor), WIDTH * to_unsigned(8, WIDTH), WIDTH)));

    -- FSM + controle do contador
    down_clock: process(clock, reset)
    begin
        if reset = '1' then
            EA <= L;
            reset_c <= '1';
        
        elsif rising_edge(clock) then
            --Sempre atualiza o estado.
            EA <= PE;

            -- Reinicia o contador ao atingir o divisor.
            if count = div then
                reset_c <= '1';
            else 
                reset_c <= '0';
            end if;
        end if;
    end process down_clock;

    -- Lógica de transição de estados (FSM simples tipo toggle)
    process(EA)
    begin
        case EA is 
            when L =>
                PE <= D;
            WHEN D =>
                PE <= L;
            when others =>
                PE <=  L;
        end case;
    end process;

    -- Saída do clock dividido baseado no estado atualiza
    baudOut_n <= '1' when EA = L else '0';
end architecture