-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2015.1 (win64) Build 1215546 Mon Apr 27 19:22:08 MDT 2015
-- Date        : Sun Aug 16 07:54:30 2015
-- Host        : picker-laptop running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/pickerfamily/Documents/GitHub/sirchuckalot/ao486/boards/nexys4-ddr/syn/vivado/ao486_nexys4-ddr.srcs/sources_1/ip/pll/pll_stub.vhdl
-- Design      : pll
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pll is
  Port ( 
    inclk0 : in STD_LOGIC;
    c0 : out STD_LOGIC;
    c1 : out STD_LOGIC;
    c2 : out STD_LOGIC;
    c3 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC
  );

end pll;

architecture stub of pll is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "inclk0,c0,c1,c2,c3,reset,locked";
begin
end;
