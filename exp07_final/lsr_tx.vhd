-- ================================================================
--  LSR_TX  –  Line‑Status Register (versão Transmitter)
--  Bits relevantes:
--    bit 5  = THRE   (Transmitter‑Holding‑Register Empty)
--    bit 6  = TEMT   (Transmitter Empty)
--  Demais bits não usados → ‘0’
-- ================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LSR_TX is
  port (
    clock , reset        : in  std_logic;               -- clk / reset assíncrono
    data_request , endbit: in  std_logic;               -- sinais do TTC
    mux                  : in  std_logic_vector(1 downto 0); -- write enable
    data_o               : out std_logic_vector(7 downto 0)  -- saída paralela
  );
end LSR_TX;

architecture comportamental of LSR_TX is
  signal data : std_logic_vector(7 downto 0) := "01000000";   -- THRE=0, TEMT=1
begin

  process (clock, reset)
  begin
    if reset = '1' then
      data <= "01000000";              -- TEMT=1 após reset
    elsif rising_edge(clock) then
      if mux = "01" then               -- escrita no THR (carregando dado p/ Tx)
        data <= "00100000";            -- THRE=0, TEMT=0
      elsif data_request = '1' then    -- TTC requisita novo byte
        data <= (others => '0');       -- limpa THRE/TEMT temporariamente
      elsif endbit = '1' then          -- fim da transmissão do byte
        data <= "01000000";            -- THRE=1, TEMT=1
      end if;
    end if;
  end process;

  data_o <= data;                      -- exporta para o transmissor / topo
end comportamental;
