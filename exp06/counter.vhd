library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
    generic(
        WIDTH: natural := 24 -- Tamanho em bits
    );
    port (
        clock, reset: in std_logic; -- Clock e reset assincrono ativo alto
        enable: in std_logic; -- Habilita contagem
        load: in std_logic; -- Carga paralela
        up: in std_logic; -- 0: contagem decrescente, 1: crescente
        data_i: in std_logic_vector(WIDTH-1 downto 0); -- Entrada paralela
        fix: in std_logic; -- Para arrumar defasagem
        data_o: out std_logic_vector(WIDTH-1 downto 0) -- Saida paralela
    );
end counter;

architecture impl of counter is
    signal cont: unsigned(WIDTH-1 downto 0) := to_unsigned(0, WIDTH);
    constant MAX_VALUE: unsigned(WIDTH-1 downto 0) := (others => '1');
    constant MIN_VALUE: unsigned(WIDTH-1 downto 0) := (others => '0');
    constant ONE_VALUE: unsigned(WIDTH-1 downto 0) := to_unsigned(1, WIDTH);
    constant TWO_VALUE: unsigned(WIDTH-1 downto 0) := to_unsigned(2, WIDTH); 
begin
    process(clock)
    begin
        
        if rising_edge(clock) then
            
            if (reset = '1') then
                if(fix = '1') then
                    cont <= TWO_VALUE;
                else
                    cont <= ONE_VALUE;
                end if;

            elsif (enable = '1') then

                if (load = '1') then
                    cont <= unsigned(data_i);

                elsif (up = '1') then
                    if cont = MAX_VALUE then
                        cont <= MIN_VALUE;

                    else
                        cont <= cont + 1;
                    end if;
                
                elsif (up = '0') then
                    if cont = MIN_VALUE then
                        cont <= MAX_VALUE;

                    else
                        cont <= cont - 1;
                    end if;
                end if;
            end if;
        end if;

        data_o <= std_logic_vector(cont);

    end process;

end architecture; 
