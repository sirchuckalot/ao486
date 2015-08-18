/*
 *  Wishbone Compatible BIOS ROM core using megafunction ROM
 *  Copyright (C) 2010  Donna Polehn <dpolehn@verizon.net>
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

module bootrom (
    input clk,
    input rst,

    // Wishbone slave interface
    input  [31:0] wb_dat_i,
    output [31:0] wb_dat_o,
    input  [31:0] wb_adr_i,
    input         wb_we_i,
    input         wb_stb_i,
    input         wb_cyc_i,
    input  [ 3:0] wb_sel_i,
    output        wb_ack_o
  );

  parameter rom_adr_width = 14;  // 16Kbytes rom

  // Net declarations
  reg  [31:0] rom[0:((2**rom_adr_width)/4)-1];  // Instantiate the 16KByte byte ROM
  wire [ 11:0] rom_addr;  // (16 * 1024)/4
  wire        stb;

  // Combinatorial logic
  assign rom_addr = wb_adr_i[13:2];  // convert to byte to word address
  assign stb      = wb_stb_i & wb_cyc_i;
  assign wb_ack_o = stb;
  assign wb_dat_o = rom[rom_addr];

  initial $readmemb("mon88.rom", rom);

endmodule
