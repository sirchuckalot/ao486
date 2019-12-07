//======================================================== conditions
wire cond_0 = state == STATE_IDLE;
wire cond_1 = io_write_do && io_write_done == `FALSE && dcache_busy == `FALSE;
wire cond_2 = io_read_do && io_read_done == `FALSE && dcache_busy == `FALSE;
wire cond_3 = state == STATE_WRITE_1;
wire cond_4 = wb_io_waitrequest_i == `FALSE || address_out_of_bounds;
wire cond_5 = write_two_stage;
wire cond_6 = state == STATE_WRITE_2;
wire cond_7 = state == STATE_READ_1;
wire cond_8 = wb_io_readdatavalid_i || address_out_of_bounds;
wire cond_9 = read_two_stage;
wire cond_10 = wb_io_waitrequest_i == `FALSE;
wire cond_11 = state == STATE_READ_2;
//======================================================== saves
wire  io_read_done_to_reg =
    (cond_0)? (  `FALSE) :
    (cond_7 && cond_8 && ~cond_9)? ( `TRUE) :
    (cond_11 && cond_8)? ( `TRUE) :
    io_read_done;
wire [15:0] wb_io_address_o_to_reg =
    (cond_0 && cond_1)? (    { io_write_address[15:2], 2'b0 }) :
    (cond_0 && ~cond_1 && cond_2)? (     { io_read_address[15:2], 2'b0 }) :
    (cond_3 && cond_4 && cond_5)? (     { write_address_next[15:2], 2'b0 }) :
    (cond_7 && cond_8 && cond_9)? (     { read_address_next[15:2], 2'b0 }) :
    wb_io_address_o;
wire [3:0] wb_io_byteenable_o_to_reg =
    (cond_0 && cond_1)? ( write_1_byteenable) :
    (cond_0 && ~cond_1 && cond_2)? (  read_1_byteenable) :
    (cond_3 && cond_4 && cond_5)? (  write_2_byteenable) :
    (cond_7 && cond_8 && cond_9)? (  read_2_byteenable) :
    wb_io_byteenable_o;
wire [31:0] wb_io_writedata_o_to_reg =
    (cond_0 && cond_1)? (  write_1_data) :
    (cond_3 && cond_4 && cond_5)? (   write_2_data) :
    wb_io_writedata_o;
wire  was_readdatavalid_to_reg =
    (cond_0 && ~cond_1 && cond_2)? ( `FALSE) :
    was_readdatavalid;
wire  wb_io_read_o_reg_to_reg =
    (cond_0 && ~cond_1 && cond_2)? (    `TRUE) :
    (cond_7 && cond_8 && cond_9)? ( `TRUE) :
    (cond_7 && cond_8 && ~cond_9)? ( `FALSE) :
    (cond_7 && cond_10)? ( `FALSE) :
    (cond_11 && cond_8)? ( `FALSE) :
    (cond_11 && cond_10)? ( `FALSE) :
    wb_io_read_o_reg;
wire [31:0] io_read_data_to_reg =
    (cond_7 && cond_8)? ( read_data_1) :
    (cond_11 && cond_8)? ( read_data_2) :
    io_read_data;
wire  io_write_done_to_reg =
    (cond_0)? ( `FALSE) :
    (cond_3 && cond_4 && ~cond_5)? ( `TRUE) :
    (cond_6 && cond_4)? ( `TRUE) :
    io_write_done;
wire  wb_io_write_o_reg_to_reg =
    (cond_0 && cond_1)? (  `TRUE) :
    (cond_3 && cond_4 && cond_5)? (   `TRUE) :
    (cond_3 && cond_4 && ~cond_5)? ( `FALSE) :
    (cond_6 && cond_4)? ( `FALSE) :
    wb_io_write_o_reg;
wire [2:0] state_to_reg =
    (cond_0 && cond_1)? ( STATE_WRITE_1) :
    (cond_0 && ~cond_1 && cond_2)? ( STATE_READ_1) :
    (cond_3 && cond_4 && cond_5)? ( STATE_WRITE_2) :
    (cond_3 && cond_4 && ~cond_5)? ( STATE_IDLE) :
    (cond_6 && cond_4)? ( STATE_IDLE) :
    (cond_7 && cond_8 && cond_9)? ( STATE_READ_2) :
    (cond_7 && cond_8 && ~cond_9)? ( STATE_IDLE) :
    (cond_11 && cond_8)? ( STATE_IDLE) :
    state;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) io_read_done <= 1'd0;
    else              io_read_done <= io_read_done_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_io_address_o <= 16'd0;
    else              wb_io_address_o <= wb_io_address_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_io_byteenable_o <= 4'd0;
    else              wb_io_byteenable_o <= wb_io_byteenable_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_io_writedata_o <= 32'd0;
    else              wb_io_writedata_o <= wb_io_writedata_o_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) was_readdatavalid <= 1'd0;
    else              was_readdatavalid <= was_readdatavalid_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_io_read_o_reg <= 1'd0;
    else              wb_io_read_o_reg <= wb_io_read_o_reg_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) io_read_data <= 32'd0;
    else              io_read_data <= io_read_data_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) io_write_done <= 1'd0;
    else              io_write_done <= io_write_done_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wb_io_write_o_reg <= 1'd0;
    else              wb_io_write_o_reg <= wb_io_write_o_reg_to_reg;
end
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) state <= 3'd0;
    else              state <= state_to_reg;
end
//======================================================== sets
