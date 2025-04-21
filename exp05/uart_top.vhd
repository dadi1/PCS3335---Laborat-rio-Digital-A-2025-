library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_top is
    port (
        clk_50      : in std_logic;
        start_top   : in std_logic;
        rst_top     : in std_logic;
        load_top    : in std_logic;
        thr_in_top  : in std_logic_vector(7 downto 0);
        lcr_in_top  : in std_logic_vector(7 downto 0);
        serial_tx   : out std_logic;
        bit5        : out std_logic;
        bit6        : out std_logic
    );
end uart_top;

architecture behaviour of uart_top is

    component pll
        port (
            clk_in  : in std_logic;
            clk_out : out std_logic
        );
    end component;

    component baudRateGenerator
        port (
            clk       : in std_logic;
            rst       : in std_logic;
            divisor   : in std_logic_vector(15 downto 0);
            baudOut_n : out std_logic
        );
    end component;

    component serialTransmitter
        port (
            clk       : in std_logic;
            rst       : in std_logic;
            starts    : in std_logic;
            data_in   : in std_logic_vector(7 downto 0);
            lcr_says  : in std_logic_vector(7 downto 0);
            done      : out std_logic;
            tx        : out std_logic
        );
    end component;

    component lineControlRegister
        port (
            reg_in   : in std_logic_vector(7 downto 0);
            load     : in std_logic;
            rst      : in std_logic;
            clk      : in std_logic;
            reg_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    component transmitterHoldingRegister
        port (
            reg_in   : in std_logic_vector(7 downto 0);
            load     : in std_logic;
            rst      : in std_logic;
            clk      : in std_logic;
            reg_out  : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk_1p8432   : std_logic;
    signal baud_clk     : std_logic;
    signal thr_out      : std_logic_vector(7 downto 0);
    signal lcr_out      : std_logic_vector(7 downto 0);
    signal done_aux     : std_logic;

    constant DIVISOR : std_logic_vector(15 downto 0) := x"000C";

begin

    pll_inst: pll
        port map (
            clk_in  => clk_50,
            clk_out => clk_1p8432
        );

    brg_inst: baudRateGenerator
        port map (
            clk       => clk_1p8432,
            rst       => rst_top,
            divisor   => DIVISOR,
            baudOut_n => baud_clk
        );

    tx_inst: serialTransmitter
        port map (
            clk      => baud_clk,
            rst      => rst_top,
            starts   => start_top,
            data_in  => thr_out,
            lcr_says => lcr_out,
            done     => done_aux,
            tx       => serial_tx
        );

    lcr_inst: lineControlRegister
        port map (
            reg_in  => lcr_in_top,
            load    => load_top,
            rst     => rst_top,
            clk     => baud_clk,
            reg_out => lcr_out
        );

    thr_inst: transmitterHoldingRegister
        port map (
            reg_in  => thr_in_top,
            load    => load_top,
            rst     => rst_top,
            clk     => baud_clk,
            reg_out => thr_out
        );

    process(baud_clk, rst_top)
    begin
        if rst_top = '1' then
            bit5 <= '0';
            bit6 <= '0';
        elsif rising_edge(baud_clk) then
            if load_top = '1' then
                if start_top = '0' then
                    bit5 <= '1';
                    bit6 <= '0';
                else
                    bit5 <= '0';
                    bit6 <= '0';
                end if;
            elsif done_aux = '1' then
                bit5 <= '0';
                bit6 <= '1';
            else
                bit5 <= '0';
                bit6 <= '0';
            end if;
        end if;
    end process;

end behaviour;
