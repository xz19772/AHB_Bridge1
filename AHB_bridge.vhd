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
entity AHB_bridge is
 port(
 -- Clock and Reset -----------------
 clkm : in std_logic;
 rstn : in std_logic;
 -- AHB Master records --------------
 ahbi : in ahb_mst_in_type;
 ahbo : out ahb_mst_out_type;
 -- ARM Cortex-M0 AHB-Lite signals --
 HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
 HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
 HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
 HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
 HWRITE : in std_logic; -- AHB write control
 HRDATA : out std_logic_vector (31 downto 0); -- AHB read-data
 HREADY : out std_logic -- AHB stall signal
 );
end;
architecture structural of AHB_bridge is

signal dmai : ahb_dma_in_type;
signal dmao : ahb_dma_out_type;
signal stahwire1 : ahb_dma_in_type;
signal stahwire2: ahb_dma_out_type;

--declare a component for state_machine
component state_machine
  port(
    clkm : in std_logic;
    rstn : in std_logic;
    HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
    HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
    HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
    HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
    HWRITE : in std_logic; -- AHB write control
    HREADY : out std_logic;
    dmai : out ahb_dma_in_type;
    dmao : in ahb_dma_out_type
    );
end component;


--declare a component for ahbmst
component ahbmst
  port(
    clk : in std_logic;
    rst : in std_logic;
    ahbi : in ahb_mst_in_type;
    ahbo : out ahb_mst_out_type;
    dmai : in ahb_dma_in_type;
    dmao : out ahb_dma_out_type
    );
end component;

--declare a component for data_swapper
component data_swapper
  port(
    clkm : in std_logic;
    HRDATA : out std_logic_vector (31 downto 0);
    dmao : in ahb_dma_out_type
  );
end component;


begin
--instantiate state_machine component and make the connections
statemachine : state_machine port map(
clkm=>clkm,
rstn=>rstn,
HADDR=>HADDR,
HSIZE=>HSIZE,
HTRANS=>HTRANS,
HWDATA=>HWDATA,
HWRITE=>HWRITE,
HREADY=>HREADY,
dmai=>stahwire1,
dmao=>stahwire2
);
--instantiate the ahbmst component and make the connections
ahbmst1 : ahbmst port map(
clk=>clkm,
rst=>rstn,
ahbi=>ahbi,
ahbo=>ahbo,
dmai=>stahwire1,
dmao=>stahwire2
);
--instantiate the data_swapper component and make the connections
dataswapper : data_swapper port map(
clkm => clkm,
HRDATA=>HRDATA,
dmao=>stahwire2
);
end structural;