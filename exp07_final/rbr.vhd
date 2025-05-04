library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Receiver Buffer Register (novo para a Exp. 7)
entity RBR is
  port (
    clock , reset : in  std_logic;              -- clock = clk_out do RTC (baudrate/16)
    load          : in  std_logic;              -- pulso alto no fim de recepção válida
    read          : in  std_logic;              -- pulso alto quando CPU/usuário lê RBR
    data_i        : in  std_logic_vector(7 downto 0); -- byte recebido do RSR
    data_o        : out std_logic_vector(7 downto 0); -- saída para barramento / display
    dr_o          : out std_logic;              -- LSR bit 0  (Data Ready)
    oe_o          : out std_logic               -- LSR bit 1  (Overrun Error)
  );
end RBR;

architecture rtl of RBR is
  signal dr  : std_logic := '0';
  signal oe  : std_logic := '0';
  signal reg : std_logic_vector(7 downto 0) := (others=>'0');
begin
  process(clock, reset)
  begin
    if reset='1' then
      reg <= (others=>'0');
      dr  <= '0';
      oe  <= '0';
    elsif rising_edge(clock) then
      -- leitura da CPU/usuário tem prioridade em limpar o DR (bit 0)
      if read='1' then
        dr <= '0';
        -- na especificação oficial, OE só baixa na leitura do LSR.
        -- como a leitura do LSR ainda não foi implementada, podemos limpar OE aqui também.
        oe <= '0';
      end if;

      -- chegada de novo dado
      if load='1' then
        -- se DR já estava alto e o dado anterior não foi lido, gera overrun
        if dr='1' then
          oe <= '1';
        end if;
        reg <= data_i;
        dr  <= '1';
      end if;
    end if;
  end process;

  data_o <= reg;
  dr_o   <= dr;
  oe_o   <= oe;
end rtl;
