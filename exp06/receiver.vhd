library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity receiver is
    generic(
        WIDTH_CONT: natural := 24; -- Tamanho em bits
        WIDTH_REGS: natural := 8  -- Tamanho em bits
    );
    port(
        clock, reset: in std_logic;
        enable: in std_logic;
        serial_in: in std_logic;
        LCR_load: in std_logic;
        LCR: in std_logic_vector(6 downto 0);
        THR_out: out std_logic_vector(WIDTH_REGS-1 downto 0);
        error_sig: out std_logic;
        LSR: out std_logic_vector(1 downto 0)
    );
end entity;

architecture impl of receiver is

    -- Sinais para conectar ambos
    signal rst_rsr: std_logic;
    signal enable_rsr: std_logic;
    signal LCR_out: std_logic_vector(6 downto 0);
    signal parity: std_logic;
    signal data_transfer: std_logic_vector(WIDTH_REGS-1 downto 0);
    signal done: std_logic;
    signal saida: std_logic_vector(WIDTH_REGS-1 downto 0);

    -- Sinais do LCR
    signal load_LCR: std_logic_vector(1 downto 0);
    signal non: std_logic := '0';

    -- Registrador para LCR
    component shiftregister is
        generic(
            WIDTH: natural := 8
        );
        port (
            clock, reset: in std_logic; -- Reset assincrono
            loadOrShift: in std_logic_vector(1 downto 0);
            serial_i: in std_logic;
            data_i: in std_logic_vector(WIDTH-1 downto 0);
            data_o: out std_logic_vector(WIDTH-1 downto 0);
            serial_o_r: out std_logic;
            serial_o_l: out std_logic
        );
    end component;

    -- RSR
    component RSR is
        generic(
            WIDTH_CONT: natural := 24; -- Tamanho em bits
            WIDTH_REGS: natural := 8  -- Tamanho em bits
        );
        port(
            clock, reset: in std_logic;
            enable:       in std_logic;
            serial_in:    in std_logic;
            LCR:          in std_logic_vector(6 downto 0);
            isParityOk:   out std_logic;
            data_out:     out std_logic_vector(7 downto 0);
            isDone:       out std_logic
            );
    end component;

    -- RTC
    component RTC is
        generic(
            WIDTH_CONT: natural := 24; -- Tamanho em bits
            WIDTH_REGS: natural := 8  -- Tamanho em bits
        );
        port(
            clock, reset: in std_logic;
            enable: in std_logic;
            serial_in: in std_logic;
            LCR: in std_logic_vector(6 downto 0);
            data_in: in std_logic_vector(WIDTH_REGS-1 downto 0);
            isDoneRSR: in std_logic;
            isParityOk: in std_logic;
            enable_RSR: out std_logic;
            data_out: out std_logic_vector(WIDTH_REGS-1 downto 0);
            RSR_rst: out std_logic;
            error_sig: out std_logic
        );
    end component;

begin

    LCR_reg: shiftregister
        generic map(WIDTH => 7)
        port map(clock, reset, load_LCR, non, LCR, LCR_out, open, open);

    module_RSR: RSR
        generic map(WIDTH_CONT => WIDTH_CONT, WIDTH_REGS => WIDTH_REGS)
        port map(clock, rst_rsr, enable_rsr, serial_in, LCR_out, parity, data_transfer, done);

    module_RTC: RTC
        generic map(WIDTH_CONT => WIDTH_CONT, WIDTH_REGS => WIDTH_REGS)
        port map(clock, reset, enable, serial_in, LCR_out, data_transfer, done, parity, enable_rsr, saida, rst_rsr, error_sig);

    load_LCR <= "11" when LCR_load = '1' else
                "00";

    LSR(0) <= done;
    LSR(1) <= '1' when unsigned(saida) = 0 else
              '0';

    THR_out <= saida;

end architecture;