module tb_avalon_mem;   

    vlog_tb_utils vlog_tb_utils0();
   
    localparam aw = 32;
    localparam dw = 32;
   
    reg     wb_clk = 1'b1;
    reg     wb_rst = 1'b1;
   
    always #5 wb_clk <= ~wb_clk;
    initial  #100 wb_rst <= 0;
    
    assign wb_rst_n = !wb_rst;
    
    integer Tp = 1;
   
    // avalon master
    wire [31:0]  avm_address;
    wire [31:0]  avm_writedata;
    wire [3:0]   avm_byteenable;
    wire [2:0]   avm_burstcount;
    wire         avm_write;
    wire         avm_read;
    
    reg          avm_waitrequest;
    reg          avm_readdatavalid;
    reg  [31:0]  avm_readdata;
    
    // Attempt to simulate avalon bus responses
    reg [2:0]    burstcount;
    always @(posedge wb_clk) begin
        if (wb_rst) begin            
            avm_waitrequest <= 1'b0;
            avm_readdatavalid <= 1'b0;
            avm_readdata <= 32'b0;
            burstcount <= 3'b0;
        end
        else begin
            if (avm_write) begin
                $display("Write: %x=%x sel=%b burstlength = %x", avm_address, avm_writedata,
                          avm_byteenable, avm_burstcount);
            end
            if (avm_read) begin
                $display("read detected");
            end
            
        end
    end
 
    
    // Write brust test wires
    reg writeburst_do;
    wire writeburst_done;
    
    reg [31:0]  writeburst_address;
    reg [1:0]   writeburst_dword_length;
    reg [3:0]   writeburst_byteenable_0;
    reg [3:0]   writeburst_byteenable_1;
    reg [55:0]  writeburst_data;
    
    // Writeline test wires
    reg writeline_do;              // input         writeline_do
    wire writeline_done;           // output        writeline_done  
    reg [31:0]  writeline_address; // input [31:0]  writeline_address
    reg [127:0] writeline_line;    // input [127:0] writeline_line


    task task_waitclock_n;
        input integer n;

        begin
            repeat(n) begin
                @(posedge wb_clk);
            end
        end
    endtask // task_waitclock_n    
    

    task task_reset;
    begin
        // wb_rst is already being held high for 100 units
           
        // Init writeburst
        writeburst_do = 1'b0;
        writeburst_address = 32'b0;
        writeburst_dword_length = 2'b0;
        writeburst_byteenable_0 = 4'b0;
        writeburst_byteenable_1 = 4'b0;
        writeburst_data = 56'b0;
        
        // Init writeline
        writeline_do = 1'b0;       // input         writeline_do,
        writeline_address = 32'b0; // input [31:0]  writeline_address,
        writeline_line = 128'b0;   // input [127:0] writeline_line,
           
        // Wait until reset has been released
        @(negedge wb_rst);        
        $display("%d : RESET HAS BEEN RELEASED", $time);
    end
    endtask // reset
    
    task task_writeburst;
    
        input [31:0]  writeburst_address_i;
        input [1:0]   writeburst_dword_length_i;
        input [3:0]   writeburst_byteenable_0_i;
        input [3:0]   writeburst_byteenable_1_i;
        input [55:0]  writeburst_data_i;
        integer i;
        
        begin
            writeburst_address      <= #Tp writeburst_address_i;
            writeburst_dword_length <= #Tp writeburst_dword_length_i;
            writeburst_byteenable_0 <= #Tp writeburst_byteenable_0_i;
            writeburst_byteenable_1 <= #Tp writeburst_byteenable_1_i;
            writeburst_data         <= #Tp writeburst_data_i;
            writeburst_do           <= #Tp 1'b1;
            i = 0;
            while (~writeburst_done) begin
                i = i + 1;
                task_waitclock_n(1);
            end
            //waitclock;
            $display("Writeburst: %x=%x sel=%b burstlength = %x acked in %d clocks", writeburst_address_i, writeburst_data_i,
                {writeburst_byteenable_1_i, writeburst_byteenable_0_i},
                writeburst_dword_length_i, i);

            writeburst_do <= #Tp 1'b0;
            writeburst_address <= #Tp 32'b0;
            writeburst_dword_length <= #Tp 2'b0;
            writeburst_byteenable_0 <= #Tp 4'b0;
            writeburst_byteenable_1 <= #Tp 4'b0;
            writeburst_data <= #Tp 56'b0;
            writeburst_do   <= #Tp 1'b0;
        end
    endtask // writeburst
    
    task task_writeline;
    
        input [31:0]  writeline_address_i; // input [31:0]  writeline_address,
        input [127:0] writeline_line_i;    // input [127:0] writeline_line,
        integer i;
        
        begin
            writeline_address <= #Tp writeline_address_i;
            writeline_line    <= #Tp writeline_line_i;
            writeline_do      <= #Tp 1'b1;
            i = 0;
            while (~writeline_done) begin
                i = i + 1;
                task_waitclock_n(1);
            end
            //waitclock;
            $display("Writeline: %x=%x acked in %d clocks", writeline_address_i,
                                                            writeline_line_i, i);
            writeline_do      <= #Tp 1'b0;
            writeline_line    <= #Tp 128'b0;
            writeline_address <= #Tp 32'b0;
        end
    endtask // writeline

    initial begin
        
        // Reset all logic
        task_reset;
        
        // Wait a few clock cycles
        task_waitclock_n(5);
        
        // Now try writeburst
        // task_writeburst(address, writeburst_length, byteendable_0, byteenable_1, data)
        //task_writeburst(32'h0101, 2'd0, 4'b1111, 4'b0101, 56'h23_4567_89ab_cdef);
        //task_waitclock_n(5);
        //task_writeburst(32'h0101, 2'd1, 4'b1111, 4'b0101, 56'h23_4567_89ab_cdef);
        //task_waitclock_n(5);
        //task_writeburst(32'h0101, 2'd2, 4'b1111, 4'b0101, 56'h23_4567_89ab_cdef);
        //task_waitclock_n(5);
        //task_writeburst(32'h0101, 2'd3, 4'b1111, 4'b0101, 56'h23_4567_89ab_cdef);
        //task_waitclock_n(5);
        
        // Wait another few clocks
        //task_waitclock_n(5);
        
        //$display();
        // Now try writeline
        task_writeline(32'h0101, 128'h8888_7777_6666_5555__4444_3333_2222_1111);
        
        // Wait another few clocks
        task_waitclock_n(5);

        
    end

    avalon_mem dut
    (// global
     .clk(wb_clk),                     // input               clk,
     .rst_n(wb_rst_n),                  // input               rst_n,
    
     //RESP:
     .writeburst_do(writeburst_do),                     // input               writeburst_do,
     .writeburst_done(writeburst_done),                 // output              writeburst_done,
    
     .writeburst_address(writeburst_address),           // input       [31:0]  writeburst_address,
     .writeburst_dword_length(writeburst_dword_length), // input       [1:0]   writeburst_dword_length,
     .writeburst_byteenable_0(writeburst_byteenable_0), // input       [3:0]   writeburst_byteenable_0,
     .writeburst_byteenable_1(writeburst_byteenable_1), // input       [3:0]   writeburst_byteenable_1,
     .writeburst_data(writeburst_data),                 // input       [55:0]  writeburst_data,
     //END
    
     //RESP:
     .writeline_do(writeline_do),           // input               writeline_do,
     .writeline_done(writeline_done),       // output              writeline_done,
    
     .writeline_address(writeline_address), // input       [31:0]  writeline_address,
     .writeline_line(writeline_line),       // input       [127:0] writeline_line,
     //END
    
     //RESP:
     .readburst_do(1'b0),            // input               readburst_do,
     .readburst_done(),          // output              readburst_done,
    
     .readburst_address(32'b0),       // input       [31:0]  readburst_address,
     .readburst_dword_length(2'b0),  // input       [1:0]   readburst_dword_length,
     .readburst_byte_length(4'b0),   // input       [3:0]   readburst_byte_length,
     .readburst_data(),          // output      [95:0]  readburst_data,
     //END
    
     //RESP:
     .readline_do(1'b0),             // input               readline_do,
     .readline_done(),           // output              readline_done,
    
     .readline_address(32'b0),        // input       [31:0]  readline_address,
     .readline_line(),           // output      [127:0] readline_line,
     //END
    
     //RESP:
     .readcode_do(1'b0),             // input               readcode_do,
     .readcode_done(),           // output              readcode_done,
    
     .readcode_address(32'b0),        // input       [31:0]  readcode_address,
     .readcode_line(),           // output      [127:0] readcode_line,
     .readcode_partial(),        // output      [31:0]  readcode_partial,
     .readcode_partial_done(),   // output              readcode_partial_done,
     //END
    
      // Avalon master
     .avm_address(avm_address),       // output reg  [31:0]  avm_address,
     .avm_writedata(avm_writedata),   // output reg  [31:0]  avm_writedata,
     .avm_byteenable(avm_byteenable), // output reg  [3:0]   avm_byteenable,
     .avm_burstcount(avm_burstcount), // output reg  [2:0]   avm_burstcount,
     .avm_write(avm_write),           // output reg          avm_write
     .avm_read(avm_read),             // output reg          avm_read
    
     .avm_waitrequest(avm_waitrequest),     // input         avm_waitrequest
     .avm_readdatavalid(avm_readdatavalid), // input         avm_readdatavalid,
     .avm_readdata(avm_readdata)            // input [31:0]  avm_readdata,
    );
/*   
    wb_bfm_memory #(.DEBUG (6))
        wb_mem_model0
        (.wb_clk_i (wb_clk),
            .wb_rst_i (wb_rst),
            .wb_adr_i (wb_m2s_adr),
            .wb_dat_i (wb_m2s_dat),
            .wb_sel_i (wb_m2s_sel),
            .wb_we_i  (wb_m2s_we ),
            .wb_cyc_i (wb_m2s_cyc),
            .wb_stb_i (wb_m2s_stb),
            .wb_cti_i (wb_m2s_cti),
            .wb_bte_i (wb_m2s_bte),
            .wb_dat_o (wb_s2m_dat),
            .wb_ack_o (wb_s2m_ack),
            .wb_err_o (wb_s2m_err),
            .wb_rty_o (wb_s2m_rty));
*/
endmodule
