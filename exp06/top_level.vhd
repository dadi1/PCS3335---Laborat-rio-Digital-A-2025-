
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity top_level is
    port(
        REFCLK    : in  std_logic;  -- Clock de referência
        RESET     : in  std_logic;  -- Reset global
        ENABLE    : in  std_logic;  -- Habilita o receiver
        SERIAL_IN : in  std_logic;  -- Entrada serial para o receiver
		  SERIAL_OUT: out std_logic;
        LCR_LOAD  : in  std_logic;  -- Sinal para carregar o LCR
        LCR       : in  std_logic_vector(6 downto 0);  -- Parâmetro LCR
        SEG_1   : out std_logic_vector(6 downto 0);  -- Display 7-seg para os 4 MSB
        SEG_0   : out std_logic_vector(6 downto 0);   -- Display 7-seg para os 4 LSB
		  ERRO: out std_logic
    );
end top_level;

architecture rtl of top_level is

	 constant DIVISOR_12 : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(12, 16));

    -- Componentes utilizados
    component ip_pll is
        port (
            refclk   : in  std_logic;
            rst      : in  std_logic;
            outclk_0 : out std_logic;
            locked   : out std_logic
        );
    end component;

    component baudRateGenerator is
        generic (
            WIDTH   : natural := 24;
            CLOCK_V : natural := 1843200
        );
        port(
            clock     : in  std_logic;
            reset     : in  std_logic;
            divisor   : in  std_logic_vector(15 downto 0);
            baudOut_n : out std_logic
        );
    end component;

    component receiver is
        generic(
            WIDTH_CONT : natural := 24;
            WIDTH_REGS : natural := 8
        );
        port(
            clock     : in std_logic;
            reset     : in std_logic;
            enable    : in std_logic;
            serial_in : in std_logic;
            LCR_load  : in std_logic;
            LCR       : in std_logic_vector(6 downto 0);
            THR_out   : out std_logic_vector(WIDTH_REGS-1 downto 0);
            error_sig : out std_logic;
            LSR       : out std_logic_vector(1 downto 0)
        );
    end component;
  
    component hex2seg is
        port(
            hex : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Sinais internos
    signal pll_clk      : std_logic;
    signal pll_locked   : std_logic;
    signal brg_clk      : std_logic;
    signal rec_THR      : std_logic_vector(7 downto 0);
    signal rec_error    : std_logic;
    signal rec_LSR      : std_logic_vector(1 downto 0);
    
    signal hex_0_in   : std_logic_vector(3 downto 0);
    signal hex_1_in    : std_logic_vector(3 downto 0);
	 

begin

	 ERRO <= rec_error;

    -- Instância do PLL
    pll_inst: ip_pll
        port map(
            refclk   => REFCLK,
            rst      => RESET,
            outclk_0 => pll_clk,
            locked   => pll_locked
        );
        
    -- Instância do Baud Rate Generator (BRG)
    brg_inst: baudRateGenerator
        generic map(
            WIDTH => 24,
            CLOCK_V => 1843200
        )
        port map(
            clock     => pll_clk,
            reset     => RESET,
            divisor   => DIVISOR_12,
            baudOut_n => brg_clk
        );

    -- Instância do Receiver
    receiver_inst: receiver
        generic map(
            WIDTH_CONT => 24,
            WIDTH_REGS => 8
        )
        port map(
            clock     => brg_clk,   -- O clock do receiver vem do BRG
            reset     => RESET,
            enable    => ENABLE,
            serial_in => SERIAL_IN,
            LCR_load  => LCR_LOAD,
            LCR       => LCR,
            THR_out   => rec_THR,
            error_sig => rec_error,
            LSR       => rec_LSR
        );
        
    -- Extração dos nibble inferiores e superiores do THR_out
    hex_0_in <= rec_THR(3 downto 0);
    hex_1_in <= rec_THR(7 downto 4);

	 
	 SERIAL_OUT <= SERIAL_IN;

    -- Instância para o display dos 4 LSB
    hex2seg_0: hex2seg
        port map(
            hex => hex_0_in,
            seg => SEG_1
        );

    -- Instância para o display dos 4 MSB
    hex2seg_1: hex2seg
        port map(
            hex => hex_1_in,
            seg => SEG_0
        );

end architecture rtl;