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

entity cm0_wrapper is
 port(
   clkm : in std_logic;
   rstn : in std_logic;
   ahbmi : in  ahb_mst_in_type;
   ahbmo : out ahb_mst_out_type
   );
end;

architecture structural of cm0_wrapper is

--signal HRDATA : std_logic_vector (31 downto 0);
--signal CM0LED : std_logic;
signal ahbi : ahb_mst_in_type;
signal ahbo : ahb_mst_out_type;
signal COstwire1 : std_logic_vector (31 downto 0);
signal COstwire2 : std_logic_vector (2 downto 0);
signal COstwire3 : std_logic_vector (1 downto 0); 
signal COstwire4 : std_logic_vector (31 downto 0);
signal COstwire5 : std_logic; 
signal COstwire6 : std_logic_vector (31 downto 0);
signal COstwire7 : std_logic;

component CORTEXM0DS
  port(
    HCLK : in std_logic;
    HRESETn : in std_logic;
    HADDR : out std_logic_vector (31 downto 0); -- AHB transaction address
    HSIZE : out std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
    HTRANS : out std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
    HWDATA : out std_logic_vector (31 downto 0); -- AHB write-data
    HWRITE : out std_logic; -- AHB write control
    HRDATA : in std_logic_vector (31 downto 0);
    HREADY : in std_logic; -- AHB stall signal
    NMI: in std_logic;
    IRQ: in std_logic_vector(15 downto 0);
    HRESP: in std_logic;
    RXEV: in std_logic;
    HBURST: out std_logic_vector (2 downto 0);
    HPORT: out std_logic_vector (3 downto 0);
    LOCKUP:out std_logic;
    SYSRESETREQ:out std_logic;
    SLEEPING:out std_logic
    );
end component;

component AHB_bridge
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    ahbi : in ahb_mst_in_type;
    ahbo : out ahb_mst_out_type;
    HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
    HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
    HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
    HWRITE : in std_logic; -- AHB write control
    HRDATA : out std_logic_vector (31 downto 0); -- AHB read-data
    HREADY : out std_logic -- AHB stall signal
);
end component;

begin
  
--cm0_led blink when 09090900
--ledblink: process(HRDATA, CM0LED, clkm)
-- begin
  --  if falling_edge(clkm) then
  --   if HRDATA = "00001001000010010000100100001001" then
   --     CM0LED <= '1';
   --   else
   --    CM0LED <= '0'; 
  --  end if;
 -- end if;
--end process;
--cm0_led<=CM0LED;


CORTEXM0DS1 : CORTEXM0DS port map(
HCLK=>clkm,
HRESETn => rstn,
HADDR=>COstwire1,
HSIZE=>COstwire2,
HTRANS=>COstwire3,
HWDATA=>COstwire4,
HWRITE=>COstwire5,
HRDATA=>COstwire6,
HREADY=>COstwire7,
NMI =>'0',
IRQ =>(others=>'0'),
HRESP =>'0',
RXEV =>'0',
HBURST => OPEN,
HPORT => OPEN,
LOCKUP => OPEN,
SYSRESETREQ => OPEN,
SLEEPING =>OPEN
);

AHBbridge : AHB_bridge port map(
clkm=>clkm,
rstn=>rstn,
ahbi=>ahbmi,
ahbo=>ahbmo,
HADDR=>COstwire1,
HSIZE=>COstwire2,
HTRANS=>COstwire3,
HWDATA=>COstwire4,
HWRITE=>COstwire5,
HRDATA=>COstwire6,
HREADY=>COstwire7

);


end structural;
