library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rtc is
    port(
        clk         : in std_logic;
        reset       : in std_logic;
        baud_tick   : in std_logic;
        serial_in   : in std_logic;
        data_ready  : out std_logic;
        shift       : out std_logic;
        load        : out std_logic;
        bit_count   : out integer range 0 to 10; -- até 8 dados + paridade + stop
        parity_err  : out std_logic;
        framing_err : out std_logic;
        write_rbr   : out std_logic;
        stop_bit    : out std_logic
    );
end entity;

architecture Behavioral of rtc is
    type state_type is (IDLE, RECEIVE, DONE);
    signal state : state_type := IDLE;
    signal count : integer range 0 to 10 := 0;
    signal parity_calc : std_logic := '0';
    signal stop_sample : std_logic := '1';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            count <= 0;
            data_ready <= '0';
            shift <= '0';
            load <= '0';
            parity_err <= '0';
            framing_err <= '0';
            write_rbr <= '0';
        elsif rising_edge(clk) then
            shift <= '0';
            load <= '0';
            data_ready <= '0';
            write_rbr <= '0';

            if baud_tick = '1' then
                case state is
                    when IDLE =>
                        if serial_in = '0' then -- detecta start bit
                            load <= '1';
                            count <= 0;
                            parity_calc <= '0';
                            state <= RECEIVE;
                        end if;

                    when RECEIVE =>
                        if count < 8 then -- bits de dados
                            shift <= '1';
                            parity_calc <= parity_calc xor serial_in;
                        elsif count = 8 then -- bit de paridade
                            if serial_in /= parity_calc then
                                parity_err <= '1';
                            else
                                parity_err <= '0';
                            end if;
                        elsif count = 9 then -- stop bit
                            stop_sample <= serial_in;
                            if serial_in /= '1' then
                                framing_err <= '1';
                            else
                                framing_err <= '0';
                            end if;
                            data_ready <= '1';
                            write_rbr <= '1';
                            state <= DONE;
                        end if;
                        count <= count + 1;

                    when DONE =>
                        state <= IDLE;
                        count <= 0;
                end case;
            end if;
        end if;
    end process;

    bit_count <= count;
    stop_bit <= stop_sample;
end architecture;
