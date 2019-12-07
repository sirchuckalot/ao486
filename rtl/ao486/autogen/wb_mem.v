//======================================================== conditions
wire cond_0 = state == STATE_IDLE;
wire cond_1 = read_burst_done_trigger;
wire cond_2 = read_line_done_trigger;
wire cond_3 = read_code_done_trigger;
wire cond_4 = writeburst_do;
wire cond_5 = writeline_do;
wire cond_6 = readburst_do && ~(readburst_done);
wire cond_7 = readline_do && ~(readline_done);
wire cond_8 = readcode_do && ~(readcode_done);
wire cond_9 = state == STATE_WRITE;
wire cond_10 = ~(wb_waitrequest_i) && counter == 2'd0;
wire cond_11 = ~(wb_waitrequest_i) && counter != 2'd0;
wire cond_12 = state == STATE_READ;
wire cond_13 = wb_readdatavalid_i;
wire cond_14 = wb_burstcount_o - { 1'b0, counter } == 3'd1;
wire cond_15 = wb_burstcount_o - { 1'b0, counter } == 3'd2;
wire cond_16 = wb_burstcount_o - { 1'b0, counter } == 3'd3;
wire cond_17 = wb_burstcount_o - { 1'b0, counter } == 3'd4;
wire cond_18 = counter == 2'd0;
wire cond_19 = wb_burstcount_o == 3'd4;
wire cond_20 = wb_waitrequest_i == `FALSE;
wire cond_21 = state == STATE_READ_CODE;
wire cond_22 = counter == 2'd3;
wire cond_23 = counter == 2'd2;
wire cond_24 = counter == 2'd1;
wire cond_25 = counter < 2'd3;
//======================================================== saves
wire  wb_read_o_to_reg =
    (cond_0 && ~cond_4 && ~cond_5 && cond_6)? (      `TRUE) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? (      `TRUE) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? (      `TRUE) :
    (cond_12 && cond_13 && cond_18)? ( `FALSE) :
    (cond_12 && cond_20)? ( `FALSE) :
    (cond_21 && cond_13 && cond_18)? ( `FALSE) :
    (cond_21 && cond_20)? ( `FALSE) :
    wb_read_o;
wire [3:0] wb_byteenable_o_to_reg =
    (cond_0 && cond_4)? (     writeburst_byteenable_0) :
    (cond_0 && ~cond_4 && cond_5)? (     4'hF) :
    (cond_0 && ~cond_4 && ~cond_5 && cond_6)? ( read_burst_byteenable) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? ( 4'hF) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? ( 4'hF) :
    (cond_9 && cond_11)? ( byteenable_next) :
    wb_byteenable_o;
wire [31:0] bus_2_to_reg =
    (cond_0 && ~cond_4 && cond_5)? (         writeline_line[127:96]) :
    (cond_12 && cond_13 && cond_16)? ( wb_readdata_i) :
    (cond_21 && cond_13 && cond_24)? ( wb_readdata_i) :
    bus_2;
wire [31:0] bus_1_to_reg =
    (cond_0 && ~cond_4 && cond_5)? (         writeline_line[95:64]) :
    (cond_9 && cond_11)? (         bus_2) :
    (cond_12 && cond_13 && cond_15)? ( wb_readdata_i) :
    (cond_21 && cond_13 && cond_23)? ( wb_readdata_i) :
    bus_1;
wire  read_code_done_trigger_to_reg =
    (cond_0 && cond_3)? ( `FALSE) :
    (cond_21 && cond_13 && cond_18)? ( `TRUE) :
    read_code_done_trigger;
wire  wb_write_o_to_reg =
    (cond_0 && cond_4)? (          `TRUE) :
    (cond_0 && ~cond_4 && cond_5)? (          `TRUE) :
    (cond_9 && cond_10)? (  `FALSE) :
    wb_write_o;
wire [31:0] bus_0_to_reg =
    (cond_0 && cond_4)? (         { 8'd0, writeburst_data[55:32] }) :
    (cond_0 && ~cond_4 && cond_5)? (         writeline_line[63:32]) :
    (cond_9 && cond_11)? (         bus_1) :
    (cond_12 && cond_13 && cond_14)? ( wb_readdata_i) :
    (cond_21 && cond_13 && cond_22)? ( wb_readdata_i) :
    bus_0;
wire [1:0] counter_to_reg =
    (cond_0 && cond_4)? (    writeburst_dword_length - 2'd1) :
    (cond_0 && ~cond_4 && cond_5)? (    2'd3) :
    (cond_0 && ~cond_4 && ~cond_5 && cond_6)? (    readburst_dword_length - 2'd1) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? (    2'd3) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? (    2'd3) :
    (cond_9 && cond_11)? ( counter - 2'd1) :
    (cond_12 && cond_13)? ( counter - 2'd1) :
    (cond_21 && cond_13)? ( counter - 2'd1) :
    counter;
wire [2:0] wb_burstcount_o_to_reg =
    (cond_0 && cond_4)? (     { 1'b0, writeburst_dword_length }) :
    (cond_0 && ~cond_4 && cond_5)? (     3'd4) :
    (cond_0 && ~cond_4 && ~cond_5 && cond_6)? ( { 1'b0, readburst_dword_length }) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? ( 3'd4) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? ( 3'd4) :
    wb_burstcount_o;
wire [31:0] bus_3_to_reg =
    (cond_12 && cond_13 && cond_17)? ( wb_readdata_i) :
    (cond_21 && cond_13 && cond_18)? ( wb_readdata_i) :
    bus_3;
wire [31:0] wb_address_o_to_reg =
    (cond_0 && cond_4)? (        { writeburst_address[31:2], 2'd0 }) :
    (cond_0 && ~cond_4 && cond_5)? (        { writeline_address[31:4], 4'd0 }) :
    (cond_0 && ~cond_4 && ~cond_5 && cond_6)? (    { readburst_address[31:2], 2'd0 }) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? (    { readline_address[31:4], 4'd0 }) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? (    { readcode_address[31:2], 2'd0 }) :
    wb_address_o;
wire  read_line_done_trigger_to_reg =
    (cond_0 && cond_2)? ( `FALSE) :
    (cond_12 && cond_13 && cond_18 && cond_19)? ( `TRUE) :
    read_line_done_trigger;
wire [31:0] bus_code_partial_to_reg =
    (cond_21 && cond_13)? ( wb_readdata_i) :
    bus_code_partial;
wire [31:0] wb_writedata_o_to_reg =
    (cond_0 && cond_4)? (         writeburst_data[31:0]) :
    (cond_0 && ~cond_4 && cond_5)? ( writeline_line[31:0]) :
    (cond_9 && cond_11)? ( bus_0) :
    wb_writedata_o;
wire [1:0] state_to_reg =
    (cond_0 && cond_4)? (      STATE_WRITE) :
    (cond_0 && ~cond_4 && cond_5)? (      STATE_WRITE) :
    (cond_0 && ~cond_4 && ~cond_5 && cond_6)? (      STATE_READ) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && cond_7)? (      STATE_READ) :
    (cond_0 && ~cond_4 && ~cond_5 && ~cond_6 && ~cond_7 && cond_8)? (      STATE_READ_CODE) :
    (cond_9 && cond_10)? (      STATE_IDLE) :
    (cond_12 && cond_13 && cond_18)? ( STATE_IDLE) :
    (cond_21 && cond_13 && cond_18)? ( STATE_IDLE) :
    state;
wire [3:0] byteenable_next_to_reg =
    (cond_0 && cond_4)? (    writeburst_byteenable_1) :
    (cond_0 && ~cond_4 && cond_5)? (    4'hF) :
    byteenable_next;
wire  read_burst_done_trigger_to_reg =
    (cond_0 && cond_1)? ( `FALSE) :
    (cond_12 && cond_13 && cond_18 && ~cond_19)? (`TRUE) :
    read_burst_done_trigger;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_read_o <= 1'd0;
    else              wb_read_o <= wb_read_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_byteenable_o <= 4'd0;
    else              wb_byteenable_o <= wb_byteenable_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) bus_2 <= 32'd0;
    else              bus_2 <= bus_2_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) bus_1 <= 32'd0;
    else              bus_1 <= bus_1_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) read_code_done_trigger <= 1'd0;
    else              read_code_done_trigger <= read_code_done_trigger_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_write_o <= 1'd0;
    else              wb_write_o <= wb_write_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) bus_0 <= 32'd0;
    else              bus_0 <= bus_0_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) counter <= 2'd0;
    else              counter <= counter_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_burstcount_o <= 3'd0;
    else              wb_burstcount_o <= wb_burstcount_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) bus_3 <= 32'd0;
    else              bus_3 <= bus_3_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_address_o <= 32'd0;
    else              wb_address_o <= wb_address_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) read_line_done_trigger <= 1'd0;
    else              read_line_done_trigger <= read_line_done_trigger_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) bus_code_partial <= 32'd0;
    else              bus_code_partial <= bus_code_partial_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_writedata_o <= 32'd0;
    else              wb_writedata_o <= wb_writedata_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 2'd0;
    else              state <= state_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) byteenable_next <= 4'd0;
    else              byteenable_next <= byteenable_next_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) read_burst_done_trigger <= 1'd0;
    else              read_burst_done_trigger <= read_burst_done_trigger_to_reg;
end
//======================================================== sets
assign readline_done =
    (cond_0 && cond_2)? (`TRUE) :
    1'd0;
assign readcode_partial_done =
    (cond_21 && cond_13 && cond_25)? (`TRUE) :
    1'd0;
assign readburst_done =
    (cond_0 && cond_1)? (`TRUE) :
    1'd0;
assign writeline_done =
    (cond_0 && ~cond_4 && cond_5)? (`TRUE) :
    1'd0;
assign writeburst_done =
    (cond_0 && cond_4)? (`TRUE) :
    1'd0;
assign readcode_done =
    (cond_0 && cond_3)? (`TRUE) :
    1'd0;
