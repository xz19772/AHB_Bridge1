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


entity data_swapper is
port(
  clkm : in std_logic;
  HRDATA : out std_logic_vector (31 downto 0);
  dmao : in ahb_dma_out_type;
  cm0_led : out std_logic
);
end;

architecture structural of data_swapper is
  
  signal blink : std_logic_vector (31 downto 0);
  
  
begin
  blink(7 downto 0) <= dmao.rdata(31 downto 24);
  blink(15 downto 8) <= dmao.rdata(23 downto 16);
  blink(23 downto 16) <= dmao.rdata(15 downto 8);
  blink(31 downto 24) <= dmao.rdata(7 downto 0);
  HRDATA <= blink;
  
  ledblink: process(blink, clkm)
 begin
   if falling_edge(clkm) then
     if blink = "00001001000010010000100100001001" then
        cm0_led <= '1';
      else
       cm0_led <= '0'; 
    end if;
  end if;
end process;

end structural;