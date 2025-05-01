library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity receiver is
    port(
        clk        : in std_logic;
        reset      : in std_logic;
        baud_tick  : in std_logic;
        serial_in  : in std_logic;
        read_en    : in std_logic;
        data_out   : out std_logic_vector(7 downto 0);
        lsr_status : out std_logic_vector(7 downto 0);
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
            parity_err  : out std_logic;
            framing_err : out std_logic;
            write_rbr   : out std_logic;
            stop_bit    : out std_logic
        );
    end component;

    signal shift_s, load_s, pe, fe, write_rbr, dr, oe, ready_s : std_logic;
    signal bits : integer range 0 to 10;
    signal data_rsr, data_rbr : std_logic_vector(7 downto 0);

begin
    reg: rsr
        port map(
            clk => clk,
            reset => reset,
            load => load_s,
            shift => shift_s,
            serial_in => serial_in,
            data_out => data_rsr
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
            parity_err => pe,
            framing_err => fe,
            write_rbr => write_rbr,
            stop_bit => open
        );

    -- RBR: registrador com detecção de overwrite
    process(clk, reset)
    begin
        if reset = '1' then
            data_rbr <= (others => '0');
            dr <= '0';
            oe <= '0';
        elsif rising_edge(clk) then
            if write_rbr = '1' then
                if dr = '1' then
                    oe <= '1'; -- dado anterior ainda não lido
                else
                    data_rbr <= data_rsr;
                    dr <= '1';
                    oe <= '0';
                end if;
            end if;

            if read_en = '1' then
                dr <= '0';
                oe <= '0';
            end if;
        end if;
    end process;

    lsr_status <= "000" & fe & pe & oe & dr;
    data_out <= data_rbr;
    ready <= dr;
end architecture;
