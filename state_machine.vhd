library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;


entity state_machine is
 port(
  -- Clock and Reset -----------------
  clkm : in std_logic;
  rstn : in std_logic;
  -- ARM Cortex-M0 AHB-Lite signals --
  HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
  HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
  HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
  HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
  HWRITE : in std_logic; -- AHB write control
  HREADY : out std_logic; -- AHB stall signal
  dmai : out ahb_dma_in_type;
  dmao : in ahb_dma_out_type
  );
 end;

architecture structural of state_machine is
-----------define the states
type state_type is (idle, instr_fetch);
signal curstate, nextstate: state_type;


begin

dmai.address <= HADDR;
dmai.size <= HSIZE;
dmai.wdata <= HWDATA;
dmai.write <= HWRITE;
dmai.burst <= '0';
dmai.busy <= '0';
dmai.irq <= '0';

process(clkm, rstn)
  begin
    if rstn = '0' then
      curstate <= idle;
    elsif rising_edge(clkm) then
      curstate <= nextstate;
    else
      curstate <= curstate;
  end if;
end process;

process(curstate, HTRANS, dmao.ready)
  begin
    case curstate is
      when idle =>
        HREADY <= '1';
        dmai.start <= '0';
          if HTRANS = "10" then
            dmai.start <= '1';
            nextstate <= instr_fetch;
          else
            nextstate <= idle;
        end if;

       when instr_fetch =>
        HREADY <= '0';
        dmai.start <= '0';
          if dmao.ready = '1' then
            HREADY <= '1';
            nextstate <= idle;
          else
            nextstate <= instr_fetch;
          end if;
    end case;
end process;


end structural;
