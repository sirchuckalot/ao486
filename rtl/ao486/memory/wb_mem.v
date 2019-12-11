/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

`include "defines.v"

//PARSED_COMMENTS: this file contains parsed script comments

module wb_mem(
    // global
    input               clk,
    input               rst_n,
    
    //RESP:
    input               writeburst_do,
    output              writeburst_done,
    
    input       [31:0]  writeburst_address,
    input       [1:0]   writeburst_dword_length,
    input       [3:0]   writeburst_byteenable_0,
    input       [3:0]   writeburst_byteenable_1,
    input       [55:0]  writeburst_data,
    //END
    
    //RESP:
    input               writeline_do,
    output              writeline_done,
    
    input       [31:0]  writeline_address,
    input       [127:0] writeline_line,
    //END
    
    //RESP:
    input               readburst_do,
    output              readburst_done,
    
    input       [31:0]  readburst_address,
    input       [1:0]   readburst_dword_length,
    input       [3:0]   readburst_byte_length,
    output      [95:0]  readburst_data,
    //END
    
    //RESP:
    input               readline_do,
    output              readline_done,
    
    input       [31:0]  readline_address,
    output      [127:0] readline_line,
    //END
    
    //RESP:
    input               readcode_do,
    output              readcode_done,
    
    input       [31:0]  readcode_address,
    output      [127:0] readcode_line,
    output      [31:0]  readcode_partial,
    output              readcode_partial_done,
    //END
    
    // Wishbone master
    output reg  [31:0]  wb_adr_o,
    output reg  [31:0]  wb_dat_o,
    output reg  [3:0]   wb_sel_o,
    output reg          wb_we_o,
    output reg          wb_cyc_o, // New signal
    output reg          wb_stb_o, // New signal
    output reg [2:0]    wb_cti_o, // New signal
    output reg [1:0]    wb_bte_o, // New signal
    output reg          wb_read_o,
    
    input       [31:0]  wb_dat_i,
    input               wb_ack_i,
    input               wb_readdatavalid_i,
    input               wb_err_i, // New signal
    input               wb_rty_i  // New signal
);

//------------------------------------------------------------------------------

reg [31:0]  bus_0;
reg [31:0]  bus_1;
reg [31:0]  bus_2;
reg [31:0]  bus_3;

reg [3:0]   byteenable_next;
reg [1:0]   counter;
reg [1:0]   state;

reg [2:0]   current_burstcount;

reg         read_burst_done_trigger;
reg         read_line_done_trigger;
reg         read_code_done_trigger;

reg [31:0]  bus_code_partial;

//------------------------------------------------------------------------------

localparam [1:0] STATE_IDLE      = 2'd0;
localparam [1:0] STATE_WRITE     = 2'd1;
localparam [1:0] STATE_READ      = 2'd2;
localparam [1:0] STATE_READ_CODE = 2'd3;


//------------------------------------------------------------------------------

assign readburst_data   = { bus_2, bus_1, bus_0 };

assign readline_line    = { bus_3, bus_2, bus_1, bus_0 };

assign readcode_line    = { bus_3, bus_2, bus_1, bus_0 };

assign readcode_partial = bus_code_partial;

//------------------------------------------------------------------------------

// synthesis translate_off
wire _unused_ok = &{ 1'b0, writeburst_address[1:0], writeline_address[3:0], readline_address[3:0], readcode_address[1:0],  1'b0 };
// synthesis translate_on

//------------------------------------------------------------------------------

wire [3:0] read_burst_byteenable =
    (readburst_byte_length == 4'd1 && readburst_address[1:0] == 2'd0)?  4'b0001 :
    (readburst_byte_length == 4'd1 && readburst_address[1:0] == 2'd1)?  4'b0010 :
    (readburst_byte_length == 4'd1 && readburst_address[1:0] == 2'd2)?  4'b0100 :
    (readburst_byte_length == 4'd1 && readburst_address[1:0] == 2'd3)?  4'b1000 :
    
    (readburst_byte_length == 4'd2 && readburst_address[1:0] == 2'd0)?  4'b0011 :
    (readburst_byte_length == 4'd2 && readburst_address[1:0] == 2'd1)?  4'b0110 :
    (readburst_byte_length == 4'd2 && readburst_address[1:0] == 2'd2)?  4'b1100 :
    
    (readburst_byte_length == 4'd3 && readburst_address[1:0] == 2'd0)?  4'b0111 :
    (readburst_byte_length == 4'd3 && readburst_address[1:0] == 2'd1)?  4'b1110 :
    
                                                                        4'b1111;

//------------------------------------------------------------------------------


/*******************************************************************************SCRIPT

IF(state == STATE_IDLE);
    
    IF(read_burst_done_trigger);
        SET(readburst_done);
        SAVE(read_burst_done_trigger, `FALSE);
    ENDIF();
    
    IF(read_line_done_trigger);
        SET(readline_done);
        SAVE(read_line_done_trigger, `FALSE);
    ENDIF();
    
    IF(read_code_done_trigger);
        SET(readcode_done);
        SAVE(read_code_done_trigger, `FALSE);
    ENDIF();
    
    IF(writeburst_do);
    
        SAVE(wb_adr_o,        { writeburst_address[31:2], 2'd0 });
        SAVE(wb_sel_o,        writeburst_byteenable_0);
        SAVE(byteenable_next, writeburst_byteenable_1);
        SAVE(wb_we_o,         `TRUE);
        SAVE(wb_cyc_o,        `TRUE); // New signal
        SAVE(wb_stb_o,        `TRUE); // New signal
        
        // Single classic cycle
        IF(writeburst_dword_length == 2'd1);
            SAVE(wb_cti_o,    3'b000); // New signal - CTI_CLASSIC
            SAVE(wb_bte_o,    2'd0  ); // New signal - BTE_LINEAR
            SAVE(counter,     2'd0);
        ENDIF();
        
        // Everything else is burst cycles
        IF(writeburst_dword_length != 2'd1);
            SAVE(wb_cti_o,    3'b010); // New signal - CTI_INC_BURST
            SAVE(wb_bte_o,    2'd0  ); // New signal - BTE_LINEAR
            SAVE(counter,     writeburst_dword_length - 2'd1);
        ENDIF();
        
        SAVE(wb_dat_o,        writeburst_data[31:0]);
        SAVE(bus_0,           { 8'd0, writeburst_data[55:32] });

        SET(writeburst_done);
        SAVE(state,           STATE_WRITE);

    ELSE_IF(writeline_do);

        SAVE(wb_adr_o,           { writeline_address[31:4], 4'd0 });
        SAVE(wb_sel_o,           4'hF);
        SAVE(byteenable_next,    4'hF);
        SAVE(current_burstcount, 3'd4);
        SAVE(wb_we_o,            `TRUE);
        
        SAVE(wb_cyc_o,           `TRUE);  // New signal
        SAVE(wb_stb_o,           `TRUE);  // New signal        
        SAVE(wb_cti_o,           3'b010); // New signal - CTI_INC_BURST
        SAVE(wb_bte_o,           2'd0  ); // New signal - BTE_LINEAR

        SAVE(wb_dat_o,           writeline_line[31:0]);
        SAVE(bus_0,              writeline_line[63:32]);
        SAVE(bus_1,              writeline_line[95:64]);
        SAVE(bus_2,              writeline_line[127:96]);

        SET(writeline_done);
        SAVE(counter,            2'd3);
        SAVE(state,              STATE_WRITE);

    ELSE_IF(readburst_do && ~(readburst_done));

        SAVE(wb_adr_o,    { readburst_address[31:2], 2'd0 });
        SAVE(wb_sel_o, read_burst_byteenable);
        SAVE(current_burstcount, { 1'b0, readburst_dword_length });
        SAVE(wb_read_o,      `TRUE);

        SAVE(counter,    readburst_dword_length - 2'd1);
        SAVE(state,      STATE_READ);

    ELSE_IF(readline_do && ~(readline_done));

        SAVE(wb_adr_o,    { readline_address[31:4], 4'd0 });
        SAVE(wb_sel_o, 4'hF);
        SAVE(current_burstcount, 3'd4);
        SAVE(wb_read_o,      `TRUE);

        SAVE(counter,    2'd3);
        SAVE(state,      STATE_READ);

    ELSE_IF(readcode_do && ~(readcode_done));

        SAVE(wb_adr_o,    { readcode_address[31:2], 2'd0 });
        SAVE(wb_sel_o, 4'hF);
        SAVE(current_burstcount, 3'd4);
        SAVE(wb_read_o,      `TRUE);

        SAVE(counter,    2'd3);
        SAVE(state,      STATE_READ_CODE);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_WRITE);    

    // End classic cycle
    IF((wb_ack_i) && counter == 2'd0);
        SAVE(wb_sel_o, 4'b0000);        
        SAVE(wb_we_o,  `FALSE);
        SAVE(wb_cyc_o, `FALSE); // New Signal
        SAVE(wb_stb_o, `FALSE); // New Signal
        SAVE(wb_cti_o, 3'b000); // New Signal - CTI_CLASSIC
        SAVE(wb_bte_o, 2'd0  ); // New Signal
        SAVE(state,    STATE_IDLE);
    ENDIF();
    
    // End burst cycle
    IF((wb_ack_i) && counter == 2'd1);
        SAVE(wb_we_o,  `FALSE);
        SAVE(wb_cyc_o, `FALSE); // New Signal
        SAVE(wb_stb_o, `FALSE); // New Signal
        SAVE(wb_cti_o, 3'b111); // New Signal - CTI_END_OF_BURST
        SAVE(wb_bte_o, 2'd0  ); // New Signal
        SAVE(state,    STATE_IDLE);
    ENDIF();
    
    // Everything except count == 0 is burst cycle
    IF((wb_ack_i) && counter != 2'd0);
        SAVE(wb_dat_o, bus_0);
        SAVE(bus_0,    bus_1);
        SAVE(bus_1,    bus_2);
        
        SAVE(wb_sel_o, byteenable_next);
        
        SAVE(counter,  counter - 2'd1);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT

IF(state == STATE_READ);
        
    IF(wb_readdatavalid_i);
        IF(current_burstcount - { 1'b0, counter } == 3'd1); SAVE(bus_0, wb_dat_i); ENDIF();
        IF(current_burstcount - { 1'b0, counter } == 3'd2); SAVE(bus_1, wb_dat_i); ENDIF();
        IF(current_burstcount - { 1'b0, counter } == 3'd3); SAVE(bus_2, wb_dat_i); ENDIF();
        IF(current_burstcount - { 1'b0, counter } == 3'd4); SAVE(bus_3, wb_dat_i); ENDIF();
        
        SAVE(counter, counter - 2'd1);
                
        IF(counter == 2'd0);
            IF(current_burstcount == 3'd4); SAVE(read_line_done_trigger, `TRUE);
            ELSE();                     SAVE(read_burst_done_trigger,`TRUE);
            ENDIF();
            
            SAVE(wb_read_o, `FALSE);
            SAVE(state, STATE_IDLE);
        ENDIF();
    ENDIF();
    
    IF(wb_ack_i == `FALSE);
        SAVE(wb_read_o, `FALSE);
    ENDIF();
ENDIF();
*/

/*******************************************************************************SCRIPT
    
IF(state == STATE_READ_CODE);

    IF(wb_readdatavalid_i);
        SAVE(bus_code_partial, wb_dat_i);
        
        IF(counter == 2'd3); SAVE(bus_0, wb_dat_i); ENDIF();
        IF(counter == 2'd2); SAVE(bus_1, wb_dat_i); ENDIF();
        IF(counter == 2'd1); SAVE(bus_2, wb_dat_i); ENDIF();
        IF(counter == 2'd0); SAVE(bus_3, wb_dat_i); ENDIF();
        
        SAVE(counter, counter - 2'd1);
        
        IF(counter < 2'd3); SET(readcode_partial_done); ENDIF();
        
        IF(counter == 2'd0);
            SAVE(read_code_done_trigger, `TRUE);
            
            SAVE(wb_read_o, `FALSE);
            SAVE(state, STATE_IDLE);
        ENDIF();
    ENDIF();
    
    IF(wb_ack_i == `FALSE);
        SAVE(wb_read_o, `FALSE);
    ENDIF();
ENDIF();
*/

//------------------------------------------------------------------------------

`include "autogen/wb_mem.v"

endmodule
