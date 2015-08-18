/*
 *  Handles clock generation and reset signals for Nexys 4 DDR board
 *  Copyright (C) 2015  Charley Picker <charleypicker@yahoo.com>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

module clkgen (
  // Main clocks in, depending on board
  input clk_pad_i,    // 100 Mhz Single ended clock capable pin
  // Asynchronous, active low reset in
  input rst_n_pad_i,
  // Input reset - through a buffer, asynchronous
  output  async_rst_o,

  // 200Mhz DDR2 clock and syncronized reset out
  output ddr_sys_clk_200_o,
  output ddr_sys_rst_o,

  // System clock and reset out
  output sys_clk_100_o,
  output sys_rst_o,
  
  // VGA clock and reset out
  output vga_clk_25_o,
  output vga_rst_o,
  
  // Wishbone clock and reset out
  output wb_clk_12_5_o,
  output wb_rst_o
  
);

  // First, deal with the asychronous reset
  wire  async_rst;
  wire  async_rst_n;

  assign  async_rst_n  = rst_n_pad_i;
  assign  async_rst  = ~async_rst_n;

  // Everyone likes active-high reset signals...
  assign  async_rst_o = ~async_rst_n;

  //
  // Declare synchronous reset wires here
  //

  // An active-low synchronous reset signal (usually a PLL lock signal)
  wire  sync_rst_n;

  //
  // Master clock generator
  //

  pll pll (
      .inclk0  (clk_pad_i),          // 100 Mhz Single ended clock capable pin
      .c0 (ddr_sys_clk_200_o),  // 200 Mhz to DDR2 System Controller
      .c1 (sys_clk_100_o),      // 100 Mhz memory wishbone clock
      .c2 (vga_clk_25_o),       // 25Mhz - vga_clk
      .c3 (wb_clk_12_5_o),      // 12.5 Mhz
      .reset    (async_rst),          // active high async cpu reset pushbutton
      .locked   (sync_rst_n)
    );

  //
  // Reset generation
  //
  //

  // Reset generation for DDR2 controller
  reg [15:0]  ddr_rst_shr;

  always @(posedge ddr_sys_clk_200_o or posedge async_rst)
    if (async_rst)
      ddr_rst_shr <= 16'hffff;
    else
      ddr_rst_shr <= {ddr_rst_shr[14:0], ~(sync_rst_n)};

  assign ddr_sys_rst_o = ddr_rst_shr[15];

  // Reset generation for system clock
  reg [15:0]  sys_rst_shr;

  always @(posedge sys_clk_100_o or posedge async_rst)
    if (async_rst)
      sys_rst_shr <= 16'hffff;
    else
      sys_rst_shr <= {sys_rst_shr[14:0], ~(sync_rst_n)};

  assign sys_rst_o = sys_rst_shr[15];
  
  // Reset generation for VGA clock
  reg [15:0]  vga_rst_shr;

  always @(posedge vga_clk_25_o or posedge async_rst)
    if (async_rst)
      vga_rst_shr <= 16'hffff;
    else
      vga_rst_shr <= {vga_rst_shr[14:0], ~(sync_rst_n)};

  assign vga_rst_o = vga_rst_shr[15];

  // Reset generation for wishbone
  reg [15:0]  wb_rst_shr;

  always @(posedge wb_clk_12_5_o or posedge async_rst)
    if (async_rst)
      wb_rst_shr <= 16'hffff;
    else
      wb_rst_shr <= {wb_rst_shr[14:0], ~(sync_rst_n)};

  assign wb_rst_o = wb_rst_shr[15];

endmodule // clkgen