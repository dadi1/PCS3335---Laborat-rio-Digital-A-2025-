library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_top is
    port (
        clk_50MHz    : in std_logic;
        reset        : in std_logic;
        enable_tx    : in std_logic;
        divisor      : in std_logic_vector(15 downto 0);
        serial_out   : out std_logic
    );
end entity;

architecture Structural of uart_top is

    -- Sinal do BRG
    signal baud_tick : std_logic;

    component baudRateGenerator
        port (
            clock      : in std_logic;
            reset      : in std_logic;
            divisor    : in std_logic_vector(15 downto 0);
            baudOut_n  : out std_logic
        );
    end component;

    component transmitter
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            enable      : in std_logic;
            baud_tick   : in std_logic;
            serial_out  : out std_logic
        );
    end component;

begin

    -- Instância do BRG
    brg_inst: baudRateGenerator
        port map (
            clock      => clk_50MHz,
            reset      => reset,
            divisor    => divisor,
            baudOut_n  => baud_tick
        );

    -- Instância do transmissor UART
    tx_inst: transmitter
        port map (
            clk        => clk_50MHz,
            reset      => reset,
            enable     => enable_tx,
            baud_tick  => baud_tick,
            serial_out => serial_out
        );

end architecture;
