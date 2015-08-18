/*
 *  ao486 Nexys 4 DDR board tesbench
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

// The following is to get rid of the warning about not initializing the ROM
// altera message_off 10030

`timescale 1ps/100fs

module nexy4_ddr_top_tb;

  localparam RESET_PERIOD = 200000; //in pSec


  //***************************************************************************
  // External board clock crystal parameter
  //***************************************************************************
  parameter CLK100MHZ_FREQ         = 100.0;
  localparam real CLK100MHZ_PERIOD = (1000000.0/(2*CLK100MHZ_FREQ));

  reg                     sys_rst;
  reg                     clk100mhz_i;


  //**************************************************************************//
  // Reset Generation
  //**************************************************************************//
  initial begin
    sys_rst_n = 1'b0;
    #RESET_PERIOD
    sys_rst_n = 1'b1;
   end

  //**************************************************************************//
  // Clock Generation
  //**************************************************************************//

  initial
    clk100mhz_i = 1'b0;
  always
  	clk100mhz_i = #CLK100MHZ_PERIOD ~clk100mhz_i;
  	
  	
 nexys4_ddr_top dut (

  // clock input
  .clk100mhz_i(clk100mhz_i),

  // Board cpu reset button
  .cpu_resetn_i(sys_rst_n),

  // 7 segment display
  .ca(),
  .cb(),
  .cc(),
  .cd(),
  .ce(),
  .cf(),
  .cg(),
  .dp(),

  .an(),
  
  // UART signals
  .uart_txd_in(),
  .uart_rxd_out()
  
);

endmodule
