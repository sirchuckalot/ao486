/*
 *  ao486 SoC top level file for Nexys 4 DDR board
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

module nexys4_ddr_top (

  // clock input
  input         clk100mhz_i,

  // Board cpu reset button
  input         cpu_resetn_i,

  // 7 segment display
  output        ca,
  output        cb,
  output        cc,
  output        cd,
  output        ce,
  output        cf,
  output        cg,
  output        dp,

  output [7:0]  an,
  
  // UART signals
  input         uart_txd_in,
  output        uart_rxd_out
  
);
  
  ////////////////////////////////////////////////////////////////////////
  //
  // Clock and reset generation module
  //
  ////////////////////////////////////////////////////////////////////////

  wire  async_rst;
  wire  wb_clk, wb_rst;

  wire ddr_sys_clk_200;
  wire ddr_sys_rst;
  
  wire sys_clk_100;
  wire sys_rst;

  wire  vga_clk;
  wire  vga_rst;
  
  wire wb_clk;
  wire wb_rst;

  clkgen clkgen0 (

    // Main clocks in, depending on board
    .clk_pad_i(clk100mhz_i),    // 100 Mhz Single ended clock capable pin
    // Asynchronous, active low reset in
    .rst_n_pad_i(cpu_resetn_i),
    // Input reset - through a buffer, asynchronous
    .async_rst_o(async_rst),

    // 200Mhz DDR2 clock and syncronized reset out
    .ddr_sys_clk_200_o(ddr_sys_clk_200),
    .ddr_sys_rst_o(ddr_sys_rst),

    // System clock and reset out
    .sys_clk_100_o(sys_clk_100),
    .sys_rst_o(sys_rst),

    // VGA clock and reset out
    .vga_clk_25_o(vga_clk),
    .vga_rst_o(vga_rst),

    // Wishbone clock and reset out
    .wb_clk_12_5_o(wb_clk),
    .wb_rst_o(wb_rst)

  );  

  ////////////////////////////////////////////////////////////////////////
  //
  // Modules interconnections
  //
  ////////////////////////////////////////////////////////////////////////
  `include "wb_intercon.vh"

  ////////////////////////////////////////////////////////////////////////
  //
  // ao486 CPU
  //
  ////////////////////////////////////////////////////////////////////////

  wire ao486_rst_n;
  assign ao486_rst_n = !wb_rst;

  wire  [15:0]  hardware_irq;
  
  wire interrupt_do;
  wire [7:0] interrupt_vector;
  wire interrupt_done;

  // Unused inputs
  assign av_m2s_cpu_io_burstcount = 8'b0;
  assign av_m2s_cpu_io_address[31:16] = 16'b0;

  ao486 ao486 (

    .clk(wb_clk),
    .rst_n(ao486_rst_n),
    
    //-----------------------Hardware Interrupt Request -------------------
    .interrupt_do(interrupt_do),
    .interrupt_vector(interrupt_vector),
    .interrupt_done(interrupt_done),
    
    //---------------------- Altera Avalon memory bus ---------------------
    .avm_address(av_m2s_cpu_mem_address),
    .avm_writedata(av_m2s_cpu_mem_writedata),
    .avm_byteenable(av_m2s_cpu_mem_byteenable),
    .avm_burstcount(av_m2s_cpu_mem_burstcount),
    .avm_write(av_m2s_cpu_mem_write),
    .avm_read(av_m2s_cpu_mem_read),
    
    .avm_waitrequest(av_s2m_cpu_mem_waitrequest),
    .avm_readdatavalid(av_s2m_cpu_mem_readdatavalid),
    .avm_readdata(av_s2m_cpu_mem_readdata),
    
    //---------------------- Altera Avalon io bus -------------------------
    .avalon_io_address(av_m2s_cpu_io_address[15:0]),
    .avalon_io_byteenable(av_m2s_cpu_io_byteenable),
    
    .avalon_io_read(av_m2s_cpu_io_read),
    .avalon_io_readdatavalid(av_s2m_cpu_io_readdatavalid),    
    .avalon_io_readdata(av_s2m_cpu_io_readdata),
    
    .avalon_io_write(av_m2s_cpu_io_write),
    .avalon_io_writedata(av_m2s_cpu_io_writedata),
    
    .avalon_io_waitrequest(av_s2m_cpu_io_waitrequest)
  );

  ////////////////////////////////////////////////////////////////////////
  //
  // Bootrom
  //
  ////////////////////////////////////////////////////////////////////////

  // Unused inputs
  assign wb_s2m_bootrom_mem_err = 1'b0;
  assign wb_s2m_bootrom_mem_rty = 1'b0;

  bootrom bootrom_mem (
    .clk(wb_clk),
    .rst(wb_rst),

    // Wishbone slave interface
    .wb_dat_i(wb_m2s_bootrom_mem_dat),
    .wb_dat_o(wb_s2m_bootrom_mem_dat),
    .wb_adr_i(wb_m2s_bootrom_mem_adr),
    .wb_we_i(wb_m2s_bootrom_mem_we),
    .wb_stb_i(wb_m2s_bootrom_mem_stb),
    .wb_cyc_i(wb_m2s_bootrom_mem_cyc),
    .wb_sel_i(wb_m2s_bootrom_mem_sel),
    .wb_ack_o(wb_s2m_bootrom_mem_ack)
  );

  ////////////////////////////////////////////////////////////////////////
  //
  // Postcode port and hex display output
  //
  ////////////////////////////////////////////////////////////////////////

  // post code
  wire [7:0] postcode;

  // Unused inputs
  assign wb_s2m_post_io_err = 1'b0;
  assign wb_s2m_post_io_rty = 1'b0;

  post post (
    .wb_clk_i (wb_clk),
    .wb_rst_i (wb_rst),

    .wb_stb_i (wb_m2s_post_io_stb),
    .wb_cyc_i (wb_m2s_post_io_cyc),
    .wb_adr_i (wb_m2s_post_io_adr[19:1]),
    .wb_we_i  (wb_m2s_post_io_we),
    .wb_sel_i (wb_m2s_post_io_sel[1:0]),
    .wb_dat_i (wb_m2s_post_io_dat),
    .wb_dat_o (wb_s2m_post_io_dat),
    .wb_ack_o (wb_s2m_post_io_ack),

    .postcode (postcode_o)
  ); 

  // Segment display
  wire [6:0] hex7_;
  wire [6:0] hex6_;
  wire [6:0] hex5_;
  wire [6:0] hex4_;
  wire [6:0] hex3_;
  wire [6:0] hex2_;
  wire [6:0] hex1_;
  wire [6:0] hex0_;

  hex_display hex16 (
    .num ({postcode, 4'b0, 20'b0}),
    .en  (1'b1),

    .hex0 (hex0_),
    .hex1 (hex1_),
    .hex2 (hex2_),
    .hex3 (hex3_),
    .hex4 (hex4_),
    .hex5 (hex5_),
    .hex6 (hex6_),
    .hex7 (hex7_)
  );

  sSegDisplay sSegDisplay (
    .ck(sys_clk_100),                         // 100 MHz system clock
    .number({1'b1, hex7_,                     // in  std_logic_vector (63 downto 0) -- eight digit number to be displayed
             1'b1, hex6_,                     // also the dp is not provided in the seg_7 decoder
             1'b1, hex5_,
             1'b1, hex4_,
             1'b1, hex3_,
             1'b1, hex2_,
             1'b1, hex1_,
             1'b1, hex0_}),
    .seg({ dp ,cg, cf, ce, cd, cc, cb, ca }), // out  std_logic_vector (7 downto 0)    -- display cathodes
    .an(an)                                   // out  std_logic_vector (7 downto 0));  -- display anodes (active-low, due to transistor complementing)
  );

  ////////////////////////////////////////////////////////////////////////
  //
  // RS232 8250 uart
  //
  ////////////////////////////////////////////////////////////////////////

  // RS232 8250 Uart Interrupt Request
  wire uart_irq;

  // Unused inputs
  assign wb_s2m_uart_io_err = 1'b0;
  assign wb_s2m_uart_io_rty = 1'b0;

  // RS232 COM1 Port
  serial uart_io (
    .wb_clk_i (wb_clk),                   // Main Clock
    .wb_rst_i (wb_rst),                   // Reset Line
    .wb_adr_i (wb_m2s_uart_io_adr[2:1]),  // Address lines
    .wb_sel_i (wb_m2s_uart_io_sel[1:0]),       // Select lines
    .wb_dat_i (wb_m2s_uart_io_dat),       // Command to send
    .wb_dat_o (wb_s2m_uart_io_dat),
    .wb_we_i  (wb_m2s_uart_io_we),        // Write enable
    .wb_stb_i (wb_m2s_uart_io_stb),
    .wb_cyc_i (wb_m2s_uart_io_cyc),
    .wb_ack_o (wb_s2m_uart_io_ack),
    .wb_tgc_o (uart_irq),                 // Interrupt request

    .rs232_tx (uart_rxd_out),             // UART signals
    .rs232_rx (uart_txd_in)               // serial input/output
  );

  ////////////////////////////////////////////////////////////////////////
  //
  // Interrupt assignment
  //
  ////////////////////////////////////////////////////////////////////////

  assign hardware_irq[0] = 0;
  assign hardware_irq[1] = 0;
  assign hardware_irq[2] = 0;
  assign hardware_irq[3] = 0;
  assign hardware_irq[4] = uart_irq;
  assign hardware_irq[5] = 0;
  assign hardware_irq[6] = 0;
  assign hardware_irq[7] = 0;
  assign hardware_irq[8] = 0;
  assign hardware_irq[9] = 0;
  assign hardware_irq[10] = 0;
  assign hardware_irq[11] = 0;
  assign hardware_irq[12] = 0;
  assign hardware_irq[13] = 0;
  assign hardware_irq[14] = 0;
  assign hardware_irq[15] = 0;

endmodule // nexys4_ddr_top