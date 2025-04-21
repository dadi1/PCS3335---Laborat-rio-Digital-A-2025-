library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity serialTransmitter is
    port (
        clk        : in std_logic;
        rst        : in std_logic;
        starts     : in std_logic;
        data_in    : in std_logic_vector(7 downto 0);
        lcr_says   : in std_logic_vector(7 downto 0);
        done       : out std_logic;
        tx         : out std_logic
    );
end serialTransmitter;

architecture behaviour of serialTransmitter is

    type state_type is (IDLE, LOAD, START, DATA, PARITY, STOP, INTERMISSION);
    signal state : state_type := IDLE;

    constant BIT_TICKS : integer := 16;
    constant INTERMISSION_TICKS : integer := (BIT_TICKS * 2);

    signal tick_count : integer range 0 to 15 := 0;
    signal data_bit_index : integer range 0 to 7 := 0;
    signal intermission_count : integer := 0;
    signal data_aux : std_logic_vector(7 downto 0);
    signal no_bits : integer range 0 to 7;
    signal parity_bit : std_logic;
    signal stop_ticks : integer;

begin

    stop_ticks <= BIT_TICKS when lcr_says(2) = '0' else 2 * BIT_TICKS;

    process(clk, rst, lcr_says(6))
    begin
        if rst = '1' then
            state <= IDLE;
            tick_count <= 0;
            data_bit_index <= 0;
            intermission_count <= 0;
            tx <= '1';
            done <= '0';

        elsif lcr_says(6) = '1' then
            tick_count <= 0;
            data_bit_index <= 0;
            intermission_count <= 0;
            tx <= '0';
            done <= '0';

        elsif rising_edge(clk) then

            -- Cálculo do bit de paridade conforme a quantidade de bits selecionados
            case lcr_says(1 downto 0) is
                when "00" =>
                    parity_bit <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4);
                when "01" =>
                    parity_bit <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5);
                when "10" =>
                    parity_bit <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5) xor data_in(6);
                when "11" =>
                    parity_bit <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5) xor data_in(6) xor data_in(7);
            end case;

            -- Determina quantos bits de dados serão enviados
            case lcr_says(1 downto 0) is
                when "00" => no_bits <= 4;
                when "01" => no_bits <= 5;
                when "10" => no_bits <= 6;
                when "11" => no_bits <= 7;
            end case;

            case state is
                when IDLE =>
                    tx <= '1';
                    tick_count <= 0;
                    data_bit_index <= 0;
                    intermission_count <= 0;
                    state <= LOAD;

                when LOAD =>
                    tx <= '1';
                    tick_count <= 0;
                    data_bit_index <= 0;
                    intermission_count <= 0;
                    data_aux <= data_in;
                    if starts = '1' then
                        state <= START;
                    else
                        state <= LOAD;
                    end if;

                when START =>
                    tx <= '0';
                    done <= '0';
                    if tick_count = BIT_TICKS - 1 then
                        tick_count <= 0;
                        state <= DATA;
                        data_bit_index <= 0;
                    else
                        tick_count <= tick_count + 1;
                    end if;

                when DATA =>
                    tx <= data_aux(data_bit_index);
                    done <= '0';
                    if tick_count = BIT_TICKS - 1 then
                        tick_count <= 0;
                        data_bit_index <= data_bit_index + 1;
                        if data_bit_index = no_bits then
                            state <= PARITY;
                        else
                            state <= DATA;
                        end if;
                    else
                        tick_count <= tick_count + 1;
                    end if;

                when PARITY =>
                    done <= '0';
                    if tick_count = BIT_TICKS - 1 then
                        tick_count <= 0;
                        state <= STOP;
                    else
                        tick_count <= tick_count + 1;
                    end if;

                when STOP =>
                    tx <= '1';
                    done <= '0';
                    if tick_count = stop_ticks - 1 then
                        tick_count <= 0;
                        state <= INTERMISSION;
                        intermission_count <= 0;
                    else
                        tick_count <= tick_count + 1;
                    end if;

                when INTERMISSION =>
                    tx <= '1';
                    done <= '1';
                    if intermission_count = INTERMISSION_TICKS - 1 then
                        intermission_count <= 0;
                        state <= IDLE;
                    else
                        intermission_count <= intermission_count + 1;
                    end if;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end behaviour;
