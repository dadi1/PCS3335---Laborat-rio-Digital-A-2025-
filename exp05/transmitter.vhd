library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity transmitter is
    port (
        clk         : in std_logic;
        reset       : in std_logic;
        enable      : in std_logic;
        baud_tick   : in std_logic;
        serial_out  : out std_logic
    );
end entity;

architecture Behavioral of transmitter is

    -- Estados da FSM
    type state_type is (IDLE, SEND, WAIT);
    signal state : state_type := IDLE;

    -- Constante a ser transmitida (ASCII 'I')
    constant DATA : std_logic_vector(7 downto 0) := "01001001";

    -- Bit de paridade (calculado uma vez)
    signal parity : std_logic;

    -- Saídas do registrador
    signal shift_data : std_logic_vector(7 downto 0);
    signal serial_bit : std_logic;

    -- Sinais de controle
    signal shift_control : std_logic_vector(1 downto 0); -- para shiftregister
    signal counter_out : std_logic_vector(3 downto 0);
    signal bit_index : unsigned(3 downto 0); -- para comparação
    signal counter_enable : std_logic := '0';
    signal counter_reset : std_logic := '1';

    -- Estados fixos de transmissão
    constant TOTAL_BITS : integer := 11; -- start + 8 data + paridade + stop

    -- Contador componente
    component counter is
        generic(
            WIDTH: natural := 4
        );
        port (
            clock, reset : in std_logic;
            enable : in std_logic;
            load : in std_logic;
            up : in std_logic;
            data_i : in std_logic_vector(WIDTH-1 downto 0);
            data_o : out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    -- Registrador componente
    component shiftregister is
        generic(
            WIDTH: natural := 8
        );
        port(
            clock, reset: in std_logic;
            loadOrShift: in std_logic_vector(1 downto 0);
            serial_i : in std_logic;
            data_i: in std_logic_vector(WIDTH-1 downto 0);
            data_o : out std_logic_vector(WIDTH-1 downto 0);
            serial_o_r: out std_logic;
            serial_o_l: out std_logic
        );
    end component;

begin

    -- Instancia o registrador de deslocamento
    TSR: shiftregister
        generic map (WIDTH => 8)
        port map (
            clock       => clk,
            reset       => reset,
            loadOrShift => shift_control,
            serial_i    => '0',
            data_i      => DATA,
            data_o      => shift_data,
            serial_o_r  => serial_bit,
            serial_o_l  => open
        );

    -- Instancia o contador de bits transmitidos
    BIT_CNT: counter
        generic map (WIDTH => 4)
        port map (
            clock   => clk,
            reset   => counter_reset,
            enable  => counter_enable,
            load    => '0',
            up      => '1',
            data_i  => (others => '0'),
            data_o  => counter_out
        );

    -- Calcula paridade par
    parity <= DATA(0) xor DATA(1) xor DATA(2) xor DATA(3) xor
              DATA(4) xor DATA(5) xor DATA(6) xor DATA(7);

    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            counter_enable <= '0';
            counter_reset <= '1';
            shift_control <= "00"; -- nada
            serial_out <= '1';

        elsif rising_edge(clk) then
            if baud_tick = '1' then
                case state is
                    when IDLE =>
                        serial_out <= '1';
                        shift_control <= "00";
                        counter_enable <= '0';
                        counter_reset <= '1';

                        if enable = '1' then
                            shift_control <= "11"; -- carga paralela
                            counter_reset <= '1';
                            state <= SEND;
                        end if;

                    when SEND =>
                        counter_reset <= '0';
                        counter_enable <= '1';

                        bit_index <= unsigned(counter_out);
                        case to_integer(bit_index) is
                            when 0 =>
                                serial_out <= '0'; -- start bit
                            when 1 to 8 =>
                                serial_out <= serial_bit;
                                shift_control <= "01"; -- shift right
                            when 9 =>
                                serial_out <= parity;
                                shift_control <= "00";
                            when 10 =>
                                serial_out <= '1'; -- stop bit
                                shift_control <= "00";
                            when others =>
                                serial_out <= '1';
                        end case;

                        if bit_index = TOTAL_BITS - 1 then
                            state <= WAIT;
                            counter_enable <= '0';
                            counter_reset <= '1';
                        end if;

                    when WAIT =>
                        serial_out <= '1';
                        shift_control <= "00";
                        counter_enable <= '0';
                        counter_reset <= '1';
                        if enable = '0' then
                            state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

end architecture;
