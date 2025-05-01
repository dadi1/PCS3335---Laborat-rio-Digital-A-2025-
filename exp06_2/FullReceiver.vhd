library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity receiver is
    port(
        clk        : in std_logic;
        reset      : in std_logic;
        baud_tick  : in std_logic;
        serial_in  : in std_logic;
        data_out   : out std_logic_vector(7 downto 0);
        lsr_status : out std_logic_vector(7 downto 0); -- só PE (bit 2) usado
        ready      : out std_logic
    );
end entity;

architecture Structural of receiver is
    component rsr
        port(
            clk, reset, load, shift: in std_logic;
            serial_in: in std_logic;
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    component rtc
        port(
            clk, reset, baud_tick: in std_logic;
            serial_in   : in std_logic;
            data_ready  : out std_logic;
            shift       : out std_logic;
            load        : out std_logic;
            bit_count   : out integer range 0 to 10;
            parity_err  : out std_logic
        );
    end component;

    signal shift_s, load_s, parity_error, ready_s : std_logic;
    signal bits : integer range 0 to 10;
    signal data_s : std_logic_vector(7 downto 0);

begin
    reg: rsr
        port map(
            clk => clk,
            reset => reset,
            load => load_s,
            shift => shift_s,
            serial_in => serial_in,
            data_out => data_s
        );

    fsm: rtc
        port map(
            clk => clk,
            reset => reset,
            baud_tick => baud_tick,
            serial_in => serial_in,
            data_ready => ready_s,
            shift => shift_s,
            load => load_s,
            bit_count => bits,
            parity_err => parity_error
        );

    lsr_status <= "00000" & parity_error & "00"; -- PE = bit 2
    data_out <= data_s;
    ready <= ready_s;
end architecture;
