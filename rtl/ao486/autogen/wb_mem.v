//======================================================== conditions
wire cond_0 = state == STATE_IDLE;
wire cond_1 = read_burst_done_trigger;
wire cond_2 = read_line_done_trigger;
wire cond_3 = read_code_done_trigger;
wire cond_4 = writeburst_do;
wire cond_5 = writeburst_dword_length == 2'd1;
wire cond_6 = writeburst_dword_length != 2'd1;
wire cond_7 = writeline_do;
wire cond_8 = readburst_do && ~(readburst_done);
wire cond_9 = readline_do && ~(readline_done);
wire cond_10 = readcode_do && ~(readcode_done);
wire cond_11 = state == STATE_WRITE;
wire cond_12 = (wb_ack_i) && counter == 2'd0;
wire cond_13 = (wb_ack_i) && counter != 2'd0;
wire cond_14 = state == STATE_READ;
wire cond_15 = wb_readdatavalid_i;
wire cond_16 = current_burstcount - { 1'b0, counter } == 3'd1;
wire cond_17 = current_burstcount - { 1'b0, counter } == 3'd2;
wire cond_18 = current_burstcount - { 1'b0, counter } == 3'd3;
wire cond_19 = current_burstcount - { 1'b0, counter } == 3'd4;
wire cond_20 = counter == 2'd0;
wire cond_21 = current_burstcount == 3'd4;
wire cond_22 = wb_ack_i == `FALSE;
wire cond_23 = state == STATE_READ_CODE;
wire cond_24 = counter == 2'd3;
wire cond_25 = counter == 2'd2;
wire cond_26 = counter == 2'd1;
wire cond_27 = counter < 2'd3;
//======================================================== saves
wire  wb_we_o_to_reg =
    (cond_0 && cond_4)? (         `TRUE) :
    (cond_0 && ~cond_4 && cond_7)? (          `TRUE) :
    (cond_11 && cond_12)? (  `FALSE) :
    (cond_11 && cond_13)? (  `FALSE) :
    wb_we_o;
wire [2:0] wb_cti_o_to_reg =
    (cond_0 && cond_4 && cond_5)? (    3'b000) :
    (cond_0 && cond_4 && cond_6)? (    3'b010) :
    (cond_11 && cond_12)? ( 3'b000) :
    (cond_11 && cond_13)? ( 3'b111) :
    wb_cti_o;
wire  wb_read_o_to_reg =
    (cond_0 && ~cond_4 && ~cond_7 && cond_8)? (      `TRUE) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && cond_9)? (      `TRUE) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && ~cond_9 && cond_10)? (      `TRUE) :
    (cond_14 && cond_15 && cond_20)? ( `FALSE) :
    (cond_14 && cond_22)? ( `FALSE) :
    (cond_23 && cond_15 && cond_20)? ( `FALSE) :
    (cond_23 && cond_22)? ( `FALSE) :
    wb_read_o;
wire [2:0] current_burstcount_to_reg =
    (cond_0 && ~cond_4 && cond_7)? (     3'd4) :
    (cond_0 && ~cond_4 && ~cond_7 && cond_8)? ( { 1'b0, readburst_dword_length }) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && cond_9)? ( 3'd4) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && ~cond_9 && cond_10)? ( 3'd4) :
    current_burstcount;
wire  wb_stb_o_to_reg =
    (cond_0 && cond_4)? (        `TRUE) :
    (cond_11 && cond_12)? ( `FALSE) :
    (cond_11 && cond_13)? ( `FALSE) :
    wb_stb_o;
wire [31:0] bus_2_to_reg =
    (cond_0 && ~cond_4 && cond_7)? (         writeline_line[127:96]) :
    (cond_14 && cond_15 && cond_18)? ( wb_dat_i) :
    (cond_23 && cond_15 && cond_26)? ( wb_dat_i) :
    bus_2;
wire [1:0] wb_bte_o_to_reg =
    (cond_0 && cond_4 && cond_5)? (    2'd0  ) :
    (cond_0 && cond_4 && cond_6)? (    2'd0  ) :
    (cond_11 && cond_12)? ( 2'd0  ) :
    (cond_11 && cond_13)? ( 2'd0  ) :
    wb_bte_o;
wire [31:0] bus_1_to_reg =
    (cond_0 && ~cond_4 && cond_7)? (         writeline_line[95:64]) :
    (cond_11 && cond_13)? (    bus_2) :
    (cond_14 && cond_15 && cond_17)? ( wb_dat_i) :
    (cond_23 && cond_15 && cond_25)? ( wb_dat_i) :
    bus_1;
wire  read_code_done_trigger_to_reg =
    (cond_0 && cond_3)? ( `FALSE) :
    (cond_23 && cond_15 && cond_20)? ( `TRUE) :
    read_code_done_trigger;
wire [31:0] wb_dat_o_to_reg =
    (cond_0 && cond_4)? (        writeburst_data[31:0]) :
    (cond_0 && ~cond_4 && cond_7)? ( writeline_line[31:0]) :
    (cond_11 && cond_13)? ( bus_0) :
    wb_dat_o;
wire [31:0] bus_0_to_reg =
    (cond_0 && cond_4)? (           { 8'd0, writeburst_data[55:32] }) :
    (cond_0 && ~cond_4 && cond_7)? (         writeline_line[63:32]) :
    (cond_11 && cond_13)? (    bus_1) :
    (cond_14 && cond_15 && cond_16)? ( wb_dat_i) :
    (cond_23 && cond_15 && cond_24)? ( wb_dat_i) :
    bus_0;
wire [1:0] counter_to_reg =
    (cond_0 && cond_4 && cond_5)? (     2'd0) :
    (cond_0 && cond_4 && cond_6)? (     writeburst_dword_length - 2'd1) :
    (cond_0 && ~cond_4 && cond_7)? (    2'd3) :
    (cond_0 && ~cond_4 && ~cond_7 && cond_8)? (    readburst_dword_length - 2'd1) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && cond_9)? (    2'd3) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && ~cond_9 && cond_10)? (    2'd3) :
    (cond_11 && cond_13)? (  counter - 2'd1) :
    (cond_14 && cond_15)? ( counter - 2'd1) :
    (cond_23 && cond_15)? ( counter - 2'd1) :
    counter;
wire [31:0] bus_3_to_reg =
    (cond_14 && cond_15 && cond_19)? ( wb_dat_i) :
    (cond_23 && cond_15 && cond_20)? ( wb_dat_i) :
    bus_3;
wire  read_line_done_trigger_to_reg =
    (cond_0 && cond_2)? ( `FALSE) :
    (cond_14 && cond_15 && cond_20 && cond_21)? ( `TRUE) :
    read_line_done_trigger;
wire [31:0] bus_code_partial_to_reg =
    (cond_23 && cond_15)? ( wb_dat_i) :
    bus_code_partial;
wire [3:0] wb_sel_o_to_reg =
    (cond_0 && cond_4)? (        writeburst_byteenable_0) :
    (cond_0 && ~cond_4 && cond_7)? (     4'hF) :
    (cond_0 && ~cond_4 && ~cond_7 && cond_8)? ( read_burst_byteenable) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && cond_9)? ( 4'hF) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && ~cond_9 && cond_10)? ( 4'hF) :
    (cond_11 && cond_12)? ( 4'b0000) :
    (cond_11 && cond_13)? ( byteenable_next) :
    wb_sel_o;
wire [31:0] wb_adr_o_to_reg =
    (cond_0 && cond_4)? (        { writeburst_address[31:2], 2'd0 }) :
    (cond_0 && ~cond_4 && cond_7)? (        { writeline_address[31:4], 4'd0 }) :
    (cond_0 && ~cond_4 && ~cond_7 && cond_8)? (    { readburst_address[31:2], 2'd0 }) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && cond_9)? (    { readline_address[31:4], 4'd0 }) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && ~cond_9 && cond_10)? (    { readcode_address[31:2], 2'd0 }) :
    wb_adr_o;
wire [1:0] state_to_reg =
    (cond_0 && cond_4)? (           STATE_WRITE) :
    (cond_0 && ~cond_4 && cond_7)? (      STATE_WRITE) :
    (cond_0 && ~cond_4 && ~cond_7 && cond_8)? (      STATE_READ) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && cond_9)? (      STATE_READ) :
    (cond_0 && ~cond_4 && ~cond_7 && ~cond_8 && ~cond_9 && cond_10)? (      STATE_READ_CODE) :
    (cond_11 && cond_12)? (    STATE_IDLE) :
    (cond_11 && cond_13)? (    STATE_IDLE) :
    (cond_14 && cond_15 && cond_20)? ( STATE_IDLE) :
    (cond_23 && cond_15 && cond_20)? ( STATE_IDLE) :
    state;
wire [3:0] byteenable_next_to_reg =
    (cond_0 && cond_4)? ( writeburst_byteenable_1) :
    (cond_0 && ~cond_4 && cond_7)? (    4'hF) :
    byteenable_next;
wire  read_burst_done_trigger_to_reg =
    (cond_0 && cond_1)? ( `FALSE) :
    (cond_14 && cond_15 && cond_20 && ~cond_21)? (`TRUE) :
    read_burst_done_trigger;
wire  wb_cyc_o_to_reg =
    (cond_0 && cond_4)? (        `TRUE) :
    (cond_11 && cond_12)? ( `FALSE) :
    (cond_11 && cond_13)? ( `FALSE) :
    wb_cyc_o;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_we_o <= 1'd0;
    else              wb_we_o <= wb_we_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_cti_o <= 3'd0;
    else              wb_cti_o <= wb_cti_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_read_o <= 1'd0;
    else              wb_read_o <= wb_read_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) current_burstcount <= 3'd0;
    else              current_burstcount <= current_burstcount_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_stb_o <= 1'd0;
    else              wb_stb_o <= wb_stb_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) bus_2 <= 32'd0;
    else              bus_2 <= bus_2_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_bte_o <= 2'd0;
    else              wb_bte_o <= wb_bte_o_to_reg;
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
    if(rst_n == 1'b0) wb_dat_o <= 32'd0;
    else              wb_dat_o <= wb_dat_o_to_reg;
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
    if(rst_n == 1'b0) bus_3 <= 32'd0;
    else              bus_3 <= bus_3_to_reg;
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
    if(rst_n == 1'b0) wb_sel_o <= 4'd0;
    else              wb_sel_o <= wb_sel_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_adr_o <= 32'd0;
    else              wb_adr_o <= wb_adr_o_to_reg;
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
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_cyc_o <= 1'd0;
    else              wb_cyc_o <= wb_cyc_o_to_reg;
end
//======================================================== sets
assign readline_done =
    (cond_0 && cond_2)? (`TRUE) :
    1'd0;
assign readcode_partial_done =
    (cond_23 && cond_15 && cond_27)? (`TRUE) :
    1'd0;
assign readburst_done =
    (cond_0 && cond_1)? (`TRUE) :
    1'd0;
assign writeline_done =
    (cond_0 && ~cond_4 && cond_7)? (`TRUE) :
    1'd0;
assign writeburst_done =
    (cond_0 && cond_4)? (`TRUE) :
    1'd0;
assign readcode_done =
    (cond_0 && cond_3)? (`TRUE) :
    1'd0;
