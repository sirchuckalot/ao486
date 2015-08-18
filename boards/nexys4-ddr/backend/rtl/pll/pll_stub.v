// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2015.1 (win64) Build 1215546 Mon Apr 27 19:22:08 MDT 2015
// Date        : Sun Aug 16 07:54:30 2015
// Host        : picker-laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/pickerfamily/Documents/GitHub/sirchuckalot/ao486/boards/nexys4-ddr/syn/vivado/ao486_nexys4-ddr.srcs/sources_1/ip/pll/pll_stub.v
// Design      : pll
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module pll(inclk0, c0, c1, c2, c3, reset, locked)
/* synthesis syn_black_box black_box_pad_pin="inclk0,c0,c1,c2,c3,reset,locked" */;
  input inclk0;
  output c0;
  output c1;
  output c2;
  output c3;
  input reset;
  output locked;
endmodule
