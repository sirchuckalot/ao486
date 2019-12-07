wire exe_int_2_int_trap_same_exception;
assign exe_int_2_int_trap_same_exception = (v8086_mode && (`DESC_IS_CODE_CONFORMING(exe_descriptor) || exe_descriptor[`DESC_BITS_DPL] != 2'd0));

wire        e_cmpxchg_eq;
wire [32:0] e_cmpxchg_sub;
wire [31:0] e_cmpxchg_result;
assign e_cmpxchg_eq = (exe_is_8bit       && eax[7:0]  == dst[7:0]) || (exe_operand_16bit && eax[15:0] == dst[15:0]) || (exe_operand_32bit && eax[31:0] == dst[31:0]);
assign e_cmpxchg_sub = eax - dst;
assign e_cmpxchg_result = (e_cmpxchg_eq)? src : e_cmpxchg_sub[31:0];

reg e_wbinvd_code_done;
reg e_wbinvd_data_done;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0)       e_wbinvd_code_done <= `FALSE; else if(exe_reset)      e_wbinvd_code_done <= `FALSE; else if(exe_ready)      e_wbinvd_code_done <= `FALSE; else if(invdcode_done)  e_wbinvd_code_done <= `TRUE;
end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0)         e_wbinvd_data_done <= `FALSE; else if(exe_reset)        e_wbinvd_data_done <= `FALSE; else if(exe_ready)        e_wbinvd_data_done <= `FALSE; else if(wbinvddata_done)  e_wbinvd_data_done <= `TRUE;
end

reg e_invd_code_done;
reg e_invd_data_done;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0)       e_invd_code_done <= `FALSE; else if(exe_reset)      e_invd_code_done <= `FALSE; else if(exe_ready)      e_invd_code_done <= `FALSE; else if(invdcode_done)  e_invd_code_done <= `TRUE;
end
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0)       e_invd_data_done <= `FALSE; else if(exe_reset)      e_invd_data_done <= `FALSE; else if(exe_ready)      e_invd_data_done <= `FALSE; else if(invddata_done)  e_invd_data_done <= `TRUE;
end

wire e_bcd_condition_cf;
wire exe_bcd_condition_af;
wire exe_bcd_condition_cf;
wire [15:0] e_aaa_sum_ax;
wire [15:0] e_aaa_result;
wire [15:0] e_aas_sub_ax;
wire [15:0] e_aas_result;
wire [7:0]  e_daa_sum_low;
wire [7:0]  e_daa_step1;
wire [7:0]  e_daa_sum_high;
wire [7:0]  e_daa_result;
wire [7:0]  e_das_sub_low;
wire [7:0]  e_das_step1;
wire [7:0]  e_das_sub_high;
wire [7:0]  e_das_result;
assign e_bcd_condition_cf = (dst[7:0] > 8'h99 || cflag);
assign exe_bcd_condition_af = dst[3:0] > 4'd9 || aflag;
assign exe_bcd_condition_cf = e_bcd_condition_cf || (exe_bcd_condition_af && (cflag || (exe_cmd == `CMD_DAA)? dst[7:0] > 8'hF9 : dst[7:0] < 8'h06));
assign e_aaa_sum_ax = dst[15:0] + 16'h0106;
assign e_aaa_result = (exe_bcd_condition_af)? { e_aaa_sum_ax[15:8], 4'b0, e_aaa_sum_ax[3:0] } : { dst[15:8], 4'd0, dst[3:0] };
assign e_aas_sub_ax = dst[15:0] - 16'h0106;
assign e_aas_result = (exe_bcd_condition_af)? { e_aas_sub_ax[15:8], 4'b0, e_aas_sub_ax[3:0] } : { dst[15:8], 4'b0, dst[3:0] };
assign e_daa_sum_low  = dst[7:0] + 8'h06;
assign e_daa_step1    = (exe_bcd_condition_af)? e_daa_sum_low : dst[7:0];
assign e_daa_sum_high = e_daa_step1 + 8'h60;
assign e_daa_result   = (e_bcd_condition_cf)? e_daa_sum_high : e_daa_step1;
assign e_das_sub_low  = dst[7:0] - 8'h06;
assign e_das_step1    = (exe_bcd_condition_af)? e_das_sub_low : dst[7:0];
assign e_das_sub_high = e_das_step1 - 8'h60;
assign e_das_result   = (e_bcd_condition_cf)? e_das_sub_high : e_das_step1;

wire exe_jecxz_condition;
assign exe_jecxz_condition = (exe_address_16bit)? ecx[15:0] == 16'd0 : ecx == 32'd0;

wire signed [31:0] e_bound_min;
wire signed [31:0] e_bound_max;
wire signed [31:0] e_bound_dst;
assign e_bound_min = (exe_operand_16bit)? { {16{exe_buffer[15]}}, exe_buffer[15:0] } : exe_buffer;
assign e_bound_max = (exe_operand_16bit)? { {16{src[15]}},        src[15:0] }        : src;
assign e_bound_dst = (exe_operand_16bit)? { {16{dst[15]}},        dst[15:0] }        : dst;
assign exe_bound_fault = exe_cmd == `CMD_BOUND && exe_cmdex == `CMDEX_BOUND_STEP_LAST && (e_bound_dst < e_bound_min || e_bound_dst > e_bound_max);

wire [31:0] e_cr0_reg;
assign e_cr0_reg = { cr0_pg, cr0_cd, cr0_nw, 10'b0, cr0_am, 1'b0, cr0_wp, 10'b0, cr0_ne, 1'b1, cr0_ts, cr0_em, cr0_mp, cr0_pe };

wire exe_cmd_loop_ecx;
wire exe_cmd_loop_condition;
assign exe_cmd_loop_ecx = (exe_address_16bit)? ecx[15:0] != 16'd1 : ecx != 32'd1;
assign exe_cmd_loop_condition = (exe_cmdex == `CMDEX_LOOP_NE)?  exe_cmd_loop_ecx && zflag == `FALSE : (exe_cmdex == `CMDEX_LOOP_E)?   exe_cmd_loop_ecx && zflag == `TRUE : exe_cmd_loop_ecx;

wire [4:0]  e_bit_selector;
wire        e_bit_selected;
wire        e_bit_value;
wire [31:0] e_bit_result;
assign e_bit_selector = (exe_operand_16bit)? { 1'b0, src[3:0] } : src[4:0];
assign e_bit_selected =  (e_bit_selector == 5'd0)?     dst[0] : (e_bit_selector == 5'd1)?     dst[1] : (e_bit_selector == 5'd2)?     dst[2] : (e_bit_selector == 5'd3)?     dst[3] : (e_bit_selector == 5'd4)?     dst[4] : (e_bit_selector == 5'd5)?     dst[5] : (e_bit_selector == 5'd6)?     dst[6] : (e_bit_selector == 5'd7)?     dst[7] : (e_bit_selector == 5'd8)?     dst[8] : (e_bit_selector == 5'd9)?     dst[9] : (e_bit_selector == 5'd10)?    dst[10] : (e_bit_selector == 5'd11)?    dst[11] : (e_bit_selector == 5'd12)?    dst[12] : (e_bit_selector == 5'd13)?    dst[13] : (e_bit_selector == 5'd14)?    dst[14] : (e_bit_selector == 5'd15)?    dst[15] : (e_bit_selector == 5'd16)?    dst[16] : (e_bit_selector == 5'd17)?    dst[17] : (e_bit_selector == 5'd18)?    dst[18] : (e_bit_selector == 5'd19)?    dst[19] : (e_bit_selector == 5'd20)?    dst[20] : (e_bit_selector == 5'd21)?    dst[21] : (e_bit_selector == 5'd22)?    dst[22] : (e_bit_selector == 5'd23)?    dst[23] : (e_bit_selector == 5'd24)?    dst[24] : (e_bit_selector == 5'd25)?    dst[25] : (e_bit_selector == 5'd26)?    dst[26] : (e_bit_selector == 5'd27)?    dst[27] : (e_bit_selector == 5'd28)?    dst[28] : (e_bit_selector == 5'd29)?    dst[29] : (e_bit_selector == 5'd30)?    dst[30] : dst[31];
assign e_bit_value = (exe_cmd == `CMD_BTC)?     ~e_bit_selected : (exe_cmd == `CMD_BTR)?     1'b0 : 1'b1;
assign e_bit_result = (e_bit_selector == 5'd0)?     { dst[31:1],  e_bit_value } : (e_bit_selector == 5'd1)?     { dst[31:2],  e_bit_value, dst[0] } : (e_bit_selector == 5'd2)?     { dst[31:3],  e_bit_value, dst[1:0] } : (e_bit_selector == 5'd3)?     { dst[31:4],  e_bit_value, dst[2:0] } : (e_bit_selector == 5'd4)?     { dst[31:5],  e_bit_value, dst[3:0] } : (e_bit_selector == 5'd5)?     { dst[31:6],  e_bit_value, dst[4:0] } : (e_bit_selector == 5'd6)?     { dst[31:7],  e_bit_value, dst[5:0] } : (e_bit_selector == 5'd7)?     { dst[31:8],  e_bit_value, dst[6:0] } : (e_bit_selector == 5'd8)?     { dst[31:9],  e_bit_value, dst[7:0] } : (e_bit_selector == 5'd9)?     { dst[31:10], e_bit_value, dst[8:0] } : (e_bit_selector == 5'd10)?    { dst[31:11], e_bit_value, dst[9:0] } : (e_bit_selector == 5'd11)?    { dst[31:12], e_bit_value, dst[10:0] } : (e_bit_selector == 5'd12)?    { dst[31:13], e_bit_value, dst[11:0] } : (e_bit_selector == 5'd13)?    { dst[31:14], e_bit_value, dst[12:0] } : (e_bit_selector == 5'd14)?    { dst[31:15], e_bit_value, dst[13:0] } : (e_bit_selector == 5'd15)?    { dst[31:16], e_bit_value, dst[14:0] } : (e_bit_selector == 5'd16)?    { dst[31:17], e_bit_value, dst[15:0] } : (e_bit_selector == 5'd17)?    { dst[31:18], e_bit_value, dst[16:0] } : (e_bit_selector == 5'd18)?    { dst[31:19], e_bit_value, dst[17:0] } : (e_bit_selector == 5'd19)?    { dst[31:20], e_bit_value, dst[18:0] } : (e_bit_selector == 5'd20)?    { dst[31:21], e_bit_value, dst[19:0] } : (e_bit_selector == 5'd21)?    { dst[31:22], e_bit_value, dst[20:0] } : (e_bit_selector == 5'd22)?    { dst[31:23], e_bit_value, dst[21:0] } : (e_bit_selector == 5'd23)?    { dst[31:24], e_bit_value, dst[22:0] } : (e_bit_selector == 5'd24)?    { dst[31:25], e_bit_value, dst[23:0] } : (e_bit_selector == 5'd25)?    { dst[31:26], e_bit_value, dst[24:0] } : (e_bit_selector == 5'd26)?    { dst[31:27], e_bit_value, dst[25:0] } : (e_bit_selector == 5'd27)?    { dst[31:28], e_bit_value, dst[26:0] } : (e_bit_selector == 5'd28)?    { dst[31:29], e_bit_value, dst[27:0] } : (e_bit_selector == 5'd29)?    { dst[31:30], e_bit_value, dst[28:0] } : (e_bit_selector == 5'd30)?    { dst[31],    e_bit_value, dst[29:0] } : { e_bit_value, dst[30:0] };

wire [4:0]  e_bit_scan_forward;
wire        e_bit_scan_zero;
wire [31:0] e_src_ze;
wire [4:0]  e_bit_scan_reverse;
assign e_bit_scan_forward = (src[0])?  5'd0 : (src[1])?  5'd1 : (src[2])?  5'd2 : (src[3])?  5'd3 : (src[4])?  5'd4 : (src[5])?  5'd5 : (src[6])?  5'd6 : (src[7])?  5'd7 : (src[8])?  5'd8 : (src[9])?  5'd9 : (src[10])? 5'd10 : (src[11])? 5'd11 : (src[12])? 5'd12 : (src[13])? 5'd13 : (src[14])? 5'd14 : (src[15])? 5'd15 : (src[16])? 5'd16 : (src[17])? 5'd17 : (src[18])? 5'd18 : (src[19])? 5'd19 : (src[20])? 5'd20 : (src[21])? 5'd21 : (src[22])? 5'd22 : (src[23])? 5'd23 : (src[24])? 5'd24 : (src[25])? 5'd25 : (src[26])? 5'd26 : (src[27])? 5'd27 : (src[28])? 5'd28 : (src[29])? 5'd29 : (src[30])? 5'd30 : (src[31])? 5'd31 : 5'd0;
assign e_src_ze = (exe_operand_16bit)? { 16'd0, src[15:0] } : src;
assign e_bit_scan_reverse = (e_src_ze[31])? 5'd31 : (e_src_ze[30])? 5'd30 : (e_src_ze[29])? 5'd29 : (e_src_ze[28])? 5'd28 : (e_src_ze[27])? 5'd27 : (e_src_ze[26])? 5'd26 : (e_src_ze[25])? 5'd25 : (e_src_ze[24])? 5'd24 : (e_src_ze[23])? 5'd23 : (e_src_ze[22])? 5'd22 : (e_src_ze[21])? 5'd21 : (e_src_ze[20])? 5'd20 : (e_src_ze[19])? 5'd19 : (e_src_ze[18])? 5'd18 : (e_src_ze[17])? 5'd17 : (e_src_ze[16])? 5'd16 : (e_src_ze[15])? 5'd15 : (e_src_ze[14])? 5'd14 : (e_src_ze[13])? 5'd13 : (e_src_ze[12])? 5'd12 : (e_src_ze[11])? 5'd11 : (e_src_ze[10])? 5'd10 : (e_src_ze[9])?  5'd9 : (e_src_ze[8])?  5'd8 : (e_src_ze[7])?  5'd7 : (e_src_ze[6])?  5'd6 : (e_src_ze[5])?  5'd5 : (e_src_ze[4])?  5'd4 : (e_src_ze[3])?  5'd3 : (e_src_ze[2])?  5'd2 : (e_src_ze[1])?  5'd1 : (e_src_ze[0])?  5'd0 : 5'd0;
assign e_bit_scan_zero = (exe_operand_16bit)? src[15:0] == 16'd0 : src[31:0] == 32'd0;

wire exe_cmd_lar_desc_invalid;
wire exe_cmd_lsl_desc_invalid;
wire exe_cmd_verr_desc_invalid;
wire exe_cmd_verw_desc_invalid;
assign exe_cmd_lar_desc_invalid = (~(exe_descriptor[`DESC_BIT_SEG]) && (exe_descriptor[`DESC_BITS_TYPE] == 4'd0  || exe_descriptor[`DESC_BITS_TYPE] == 4'd8 || exe_descriptor[`DESC_BITS_TYPE] == 4'd10 || exe_descriptor[`DESC_BITS_TYPE] == 4'd13) ) || (exe_descriptor[`DESC_BIT_SEG] && (`DESC_IS_DATA(exe_descriptor) || `DESC_IS_CODE_NON_CONFORMING(exe_descriptor)) && exe_privilege_not_accepted ) || (~(exe_descriptor[`DESC_BIT_SEG]) && (exe_descriptor[`DESC_BITS_TYPE] == `DESC_INTERRUPT_GATE_386 || exe_descriptor[`DESC_BITS_TYPE] == `DESC_INTERRUPT_GATE_286 || exe_descriptor[`DESC_BITS_TYPE] == `DESC_TRAP_GATE_386      || exe_descriptor[`DESC_BITS_TYPE] == `DESC_TRAP_GATE_286) ) || (~(exe_descriptor[`DESC_BIT_SEG]) && exe_privilege_not_accepted );
assign exe_cmd_lsl_desc_invalid = (~(exe_descriptor[`DESC_BIT_SEG]) && (exe_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_AVAIL_386 && exe_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_BUSY_386 && exe_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_AVAIL_286 && exe_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_BUSY_286 && exe_descriptor[`DESC_BITS_TYPE] != `DESC_LDT) ) || (~(exe_descriptor[`DESC_BIT_SEG]) && exe_privilege_not_accepted ) || (exe_descriptor[`DESC_BIT_SEG] && (`DESC_IS_DATA(exe_descriptor) || `DESC_IS_CODE_NON_CONFORMING(exe_descriptor)) && exe_privilege_not_accepted );
assign exe_cmd_verr_desc_invalid = (~(exe_descriptor[`DESC_BIT_SEG]) ) || (`DESC_IS_CODE_EO(exe_descriptor) || (`DESC_IS_CODE_NON_CONFORMING(exe_descriptor) && exe_privilege_not_accepted) ) || (`DESC_IS_DATA(exe_descriptor) && exe_privilege_not_accepted );
assign exe_cmd_verw_desc_invalid = (~(exe_descriptor[`DESC_BIT_SEG]) ) || (`DESC_IS_CODE(exe_descriptor) ) || (`DESC_IS_DATA_RO(exe_descriptor) || exe_privilege_not_accepted );

wire [3:0] e_io_allow_bits;
assign e_io_allow_bits = (glob_param_1[2:0] == 3'd0)?  src[3:0] : (glob_param_1[2:0] == 3'd1)?  src[4:1] : (glob_param_1[2:0] == 3'd2)?  src[5:2] : (glob_param_1[2:0] == 3'd3)?  src[6:3] : (glob_param_1[2:0] == 3'd4)?  src[7:4] : (glob_param_1[2:0] == 3'd5)?  src[8:5] : (glob_param_1[2:0] == 3'd6)?  src[9:6] : src[10:7];

wire [7:0] e_aad_result;
assign e_aad_result = mult_result[7:0] + dst[7:0];

wire [31:0] exe_new_tss_max;
assign exe_new_tss_max = (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? 32'h2B : 32'h67;

wire [1:0] e_cpl_current;
assign e_cpl_current = (glob_param_1[`MC_PARAM_1_FLAG_CPL_FROM_PARAM_3_BIT])? glob_param_3[`SELECTOR_BITS_RPL] : cpl;
assign exe_load_seg_gp_fault = exe_cmd == `CMD_load_seg && exe_cmdex == `CMDEX_load_seg_STEP_2 && ( (exe_segment < `SEGMENT_LDT && exe_segment != `SEGMENT_CS) && ( exe_descriptor[`DESC_BIT_SEG] == `FALSE || (exe_segment == `SEGMENT_SS && ( exe_selector[`SELECTOR_BITS_RPL] != e_cpl_current || `DESC_IS_CODE(exe_descriptor) || `DESC_IS_DATA_RO(exe_descriptor) || exe_descriptor[`DESC_BITS_DPL] != e_cpl_current )) || (exe_segment != `SEGMENT_SS && ( `DESC_IS_CODE_EO(exe_descriptor) || ((`DESC_IS_DATA(exe_descriptor) || `DESC_IS_CODE_NON_CONFORMING(exe_descriptor)) && exe_privilege_not_accepted) )) ) || (exe_segment == `SEGMENT_LDT && (exe_descriptor[`DESC_BIT_SEG] || exe_descriptor[`DESC_BITS_TYPE] != `DESC_LDT) ) || (exe_segment == `SEGMENT_TR && (exe_descriptor[`DESC_BIT_SEG] ||  (exe_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_AVAIL_386 && exe_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_AVAIL_286)) ) || (exe_segment == `SEGMENT_CS && ( exe_selector[`SELECTOR_BITS_RPL] < cpl || exe_descriptor[`DESC_BIT_SEG] == `FALSE || `DESC_IS_DATA(exe_descriptor) || (`DESC_IS_CODE_NON_CONFORMING(exe_descriptor) && exe_descriptor[`DESC_BITS_DPL] != exe_selector[`SELECTOR_BITS_RPL]) || (`DESC_IS_CODE_CONFORMING(exe_descriptor) && exe_descriptor[`DESC_BITS_DPL] > exe_selector[`SELECTOR_BITS_RPL]) )) );
assign exe_load_seg_ss_fault = exe_cmd == `CMD_load_seg && exe_cmdex == `CMDEX_load_seg_STEP_2 && ~(glob_param_1[`MC_PARAM_1_FLAG_NP_NOT_SS_BIT]) && exe_segment == `SEGMENT_SS && exe_descriptor[`DESC_BIT_P] == `FALSE;
assign exe_load_seg_np_fault = exe_cmd == `CMD_load_seg && exe_cmdex == `CMDEX_load_seg_STEP_2 && (glob_param_1[`MC_PARAM_1_FLAG_NP_NOT_SS_BIT] || exe_segment != `SEGMENT_SS) && exe_descriptor[`DESC_BIT_P] == `FALSE;

//======================================================== conditions
wire cond_0 = exe_cmd == `CMD_XCHG && exe_cmdex == `CMDEX_XCHG_implicit;
wire cond_1 = exe_cmd == `CMD_XCHG && exe_cmdex == `CMDEX_XCHG_modregrm;
wire cond_2 = exe_cmd == `CMD_XCHG && exe_cmdex == `CMDEX_XCHG_modregrm_LAST;
wire cond_3 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_int_trap_gate_STEP_0;
wire cond_4 = exe_cmd == `CMD_int_2 && exe_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_1;
wire cond_5 = v8086_mode && exe_descriptor[`DESC_BITS_DPL] != 2'd0;
wire cond_6 = ~(exe_trigger_gp_fault) && glob_param_3[15:2] == 14'd0;
wire cond_7 = exe_ready;
wire cond_8 = exe_cmd == `CMD_int_2 && exe_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_3;
wire cond_9 = glob_param_2 > glob_desc_2_limit;
wire cond_10 = exe_cmd == `CMD_int_2 && exe_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_5;
wire cond_11 = exe_cmd == `CMD_int_3 && (exe_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_4 || exe_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_5);
wire cond_12 = exe_mutex_current[`MUTEX_ACTIVE_BIT];
wire cond_13 = ~(exe_mutex_current[`MUTEX_ACTIVE_BIT]) && exe_ready;
wire cond_14 = exe_cmd == `CMD_int_3 && exe_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_6;
wire cond_15 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_STEP_0;
wire cond_16 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_STEP_1;
wire cond_17 = exc_soft_int_ib && v8086_mode && iopl < 2'd3;
wire cond_18 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_real_STEP_0;
wire cond_19 = { 6'd0, exc_vector[7:0], 2'b11 } > idtr_limit;
wire cond_20 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_real_STEP_1;
wire cond_21 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_real_STEP_2;
wire cond_22 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_real_STEP_3;
wire cond_23 = glob_param_2 > cs_limit;
wire cond_24 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_real_STEP_5;
wire cond_25 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_protected_STEP_0;
wire cond_26 = { 5'd0, exc_vector[7:0], 3'b111 } > idtr_limit;
wire cond_27 = exe_cmd == `CMD_int && exe_cmdex == `CMDEX_int_protected_STEP_1;
wire cond_28 = exe_descriptor[`DESC_BIT_SEG] || ( (   exe_descriptor[`DESC_BITS_TYPE] != `DESC_TASK_GATE && exe_descriptor[`DESC_BITS_TYPE] != `DESC_INTERRUPT_GATE_386 && exe_descriptor[`DESC_BITS_TYPE] != `DESC_INTERRUPT_GATE_286 && exe_descriptor[`DESC_BITS_TYPE] != `DESC_TRAP_GATE_386      && exe_descriptor[`DESC_BITS_TYPE] != `DESC_TRAP_GATE_286 ) || (exc_soft_int && exe_descriptor[`DESC_BITS_DPL] < cpl) );
wire cond_29 = ~(exe_trigger_gp_fault) && exe_descriptor[`DESC_BIT_P] == `FALSE;
wire cond_30 = exe_cmd == `CMD_int_2 && exe_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_0;
wire cond_31 = exe_int_2_int_trap_same_exception || (glob_param_2 > glob_desc_limit);
wire cond_32 = exe_cmd == `CMD_int_2 && exe_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_1;
wire cond_33 = exe_cmd == `CMD_int_2 && exe_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_2;
wire cond_34 = exe_cmd == `CMD_int_2 && exe_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_3;
wire cond_35 = exe_cmd == `CMD_int_2  && exe_cmdex >= `CMDEX_int_2_int_trap_gate_more_STEP_4;
wire cond_36 = exe_cmd == `CMD_int_3  && exe_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_0;
wire cond_37 = exe_cmd == `CMD_int_3  && exe_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_1;
wire cond_38 = exe_cmd == `CMD_int_3  && exe_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_2;
wire cond_39 = exe_cmd == `CMD_int_3  && exe_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_3;
wire cond_40 = exe_cmd == `CMD_IRET_2 && exe_cmdex == `CMDEX_IRET_2_protected_same_STEP_0;
wire cond_41 = glob_param_2 > glob_desc_limit;
wire cond_42 = exe_cmd == `CMD_IRET_2 && exe_cmdex == `CMDEX_IRET_2_protected_same_STEP_1;
wire cond_43 = exe_cmd == `CMD_IRET_2  && exe_cmdex == `CMDEX_IRET_2_protected_outer_STEP_3;
wire cond_44 = exe_cmd == `CMD_IRET_2  && exe_cmdex == `CMDEX_IRET_2_protected_outer_STEP_5;
wire cond_45 = exe_cmd == `CMD_IRET_2 && exe_cmdex == `CMDEX_IRET_2_protected_outer_STEP_6;
wire cond_46 = exe_cmd == `CMD_IRET && exe_cmdex == `CMDEX_IRET_real_v86_STEP_0;
wire cond_47 = v8086_mode && iopl < 2'd3;
wire cond_48 = exe_cmd == `CMD_IRET && exe_cmdex == `CMDEX_IRET_real_v86_STEP_1;
wire cond_49 = exe_cmd == `CMD_IRET && exe_cmdex == `CMDEX_IRET_real_v86_STEP_2;
wire cond_50 = ~(v8086_mode) && glob_param_2 > cs_limit;
wire cond_51 = exe_cmd == `CMD_IRET && exe_cmdex == `CMDEX_IRET_real_v86_STEP_3;
wire cond_52 = exe_cmd == `CMD_IRET && exe_cmdex == `CMDEX_IRET_task_switch_STEP_0;
wire cond_53 = glob_param_1[`SELECTOR_BIT_TI];
wire cond_54 = exe_cmd == `CMD_IRET && exe_cmdex == `CMDEX_IRET_task_switch_STEP_1;
wire cond_55 = glob_param_2[1] || exe_descriptor[`DESC_BIT_SEG] || (exe_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_BUSY_386 && exe_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_BUSY_286);
wire cond_56 = glob_param_2[1] == 1'b0 && ~(exe_trigger_ts_fault) && ~(exe_descriptor[`DESC_BIT_P]);
wire cond_57 = exe_cmd == `CMD_IRET && exe_cmdex >= `CMDEX_IRET_protected_to_v86_STEP_0;
wire cond_58 = exe_cmd == `CMD_IRET_2 && exe_cmdex == `CMDEX_IRET_2_protected_to_v86_STEP_6;
wire cond_59 = exe_cmd == `CMD_IRET_2 && exe_cmdex == `CMDEX_IRET_2_protected_outer_STEP_0;
wire cond_60 = glob_param_1[`SELECTOR_BITS_RPL] != glob_param_3[`SELECTOR_BITS_RPL];
wire cond_61 = exe_cmd == `CMD_CLI || exe_cmd == `CMD_STI;
wire cond_62 = exe_mutex_current[`MUTEX_EFLAGS_BIT];
wire cond_63 = (protected_mode && iopl < cpl) || (v8086_mode && iopl != 2'd3);
wire cond_64 = exe_cmd == `CMD_PUSHA;
wire cond_65 = exe_cmdex[2:0] == 3'd4;
wire cond_66 = exe_mutex_current[`MUTEX_ESP_BIT];
wire cond_67 = exe_cmd == `CMD_SCAS;
wire cond_68 = exe_cmd == `CMD_PUSH;
wire cond_69 = exe_cmdex == `CMDEX_PUSH_immediate_se;
wire cond_70 = exe_cmd == `CMD_ARPL;
wire cond_71 = exe_cmd == `CMD_RET_near && exe_cmdex != `CMDEX_RET_near_LAST;
wire cond_72 = exe_cmdex == `CMDEX_RET_near;
wire cond_73 = exe_cmdex == `CMDEX_RET_near_imm;
wire cond_74 = (exe_cmd == `CMD_LLDT || exe_cmd == `CMD_LTR) && exe_cmdex == `CMDEX_MOV_to_seg_LLDT_LTR_STEP_1;
wire cond_75 = cpl != 2'd0;
wire cond_76 = exe_cmd == `CMD_CMPXCHG;
wire cond_77 = exe_mutex_current[`MUTEX_EAX_BIT];
wire cond_78 = exe_cmd == `CMD_LODS;
wire cond_79 = exe_cmd == `CMD_SETcc;
wire cond_80 = exe_condition;
wire cond_81 = exe_cmd == `CMD_Shift && exe_decoder[13:12] == 2'b01;
wire cond_82 = exe_cmd == `CMD_Shift && exe_decoder[13:12] != 2'b01;
wire cond_83 = exe_cmd == `CMD_INC_DEC;
wire cond_84 = exe_cmd == `CMD_PUSH_MOV_SEG && { exe_cmdex[3], 3'b0 } == `CMDEX_PUSH_MOV_SEG_implicit;
wire cond_85 = exe_cmd == `CMD_PUSH_MOV_SEG && { exe_cmdex[3], 3'b0 } == `CMDEX_PUSH_MOV_SEG_modregrm;
wire cond_86 = exe_cmd == `CMD_WBINVD && exe_cmdex == `CMDEX_WBINVD_STEP_0;
wire cond_87 = cpl > 2'd0;
wire cond_88 = exe_cmd == `CMD_WBINVD && exe_cmdex == `CMDEX_WBINVD_STEP_1;
wire cond_89 = ~(e_wbinvd_code_done && e_wbinvd_data_done);
wire cond_90 = exe_cmd == `CMD_SGDT;
wire cond_91 = exe_cmdex == `CMDEX_SGDT_SIDT_STEP_1;
wire cond_92 = exe_cmdex == `CMDEX_SGDT_SIDT_STEP_2;
wire cond_93 = exe_cmd == `CMD_SIDT;
wire cond_94 = exe_cmd == `CMD_POPF && exe_cmdex == `CMDEX_POPF_STEP_0;
wire cond_95 = exe_cmd == `CMD_Jcc;
wire cond_96 = exe_condition && exe_branch_eip > cs_limit;
wire cond_97 = exe_cmd == `CMD_INS;
wire cond_98 = exe_mutex_current[`MUTEX_EDX_BIT];
wire cond_99 = exe_cmd == `CMD_IMUL;
wire cond_100 = mult_busy;
wire cond_101 = exe_cmd == `CMD_LEA;
wire cond_102 = exe_cmd == `CMD_MOVSX || exe_cmd == `CMD_MOVZX;
wire cond_103 = exe_cmd == `CMD_MOVS;
wire cond_104 = exe_cmd == `CMD_INVD && exe_cmdex == `CMDEX_INVD_STEP_0;
wire cond_105 = exe_cmd == `CMD_INVD && exe_cmdex == `CMDEX_INVD_STEP_1;
wire cond_106 = ~(e_invd_code_done && e_invd_data_done);
wire cond_107 = exe_cmd == `CMD_RET_far  && exe_cmdex == `CMDEX_RET_far_STEP_1;
wire cond_108 = exe_cmd == `CMD_RET_far && exe_cmdex == `CMDEX_RET_far_STEP_2;
wire cond_109 = (v8086_mode || real_mode) && glob_param_2 > cs_limit;
wire cond_110 = exe_cmd == `CMD_RET_far && exe_cmdex == `CMDEX_RET_far_same_STEP_3;
wire cond_111 = exe_cmd == `CMD_RET_far && exe_cmdex == `CMDEX_RET_far_outer_STEP_5;
wire cond_112 = exe_cmd == `CMD_RET_far && exe_cmdex == `CMDEX_RET_far_outer_STEP_6;
wire cond_113 = exe_cmd == `CMD_RET_far && exe_cmdex == `CMDEX_RET_far_outer_STEP_7;
wire cond_114 = exe_cmd == `CMD_RET_far && (exe_cmdex == `CMDEX_RET_far_real_STEP_3 || exe_cmdex == `CMDEX_RET_far_same_STEP_4);
wire cond_115 = exe_cmdex == `CMDEX_RET_far_real_STEP_3;
wire cond_116 = exe_cmd == `CMD_AAA || exe_cmd == `CMD_AAS || exe_cmd == `CMD_DAA || exe_cmd == `CMD_DAS;
wire cond_117 = exe_cmd == `CMD_STOS;
wire cond_118 = exe_cmd == `CMD_JCXZ;
wire cond_119 = exe_mutex_current[`MUTEX_ECX_BIT];
wire cond_120 = exe_jecxz_condition && exe_branch_eip > cs_limit;
wire cond_121 = exe_cmd == `CMD_XLAT;
wire cond_122 = exe_cmd == `CMD_BOUND && exe_cmdex == `CMDEX_BOUND_STEP_FIRST;
wire cond_123 = exe_cmd == `CMD_BOUND && exe_cmdex == `CMDEX_BOUND_STEP_LAST;
wire cond_124 = exe_bound_fault;
wire cond_125 = exe_cmd == `CMD_MOV;
wire cond_126 = exe_cmd == `CMD_MUL;
wire cond_127 = exe_cmd == `CMD_debug_reg && (exe_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0 || exe_cmdex == `CMDEX_debug_reg_MOV_load_STEP_0);
wire cond_128 = exe_cmdex == `CMDEX_debug_reg_MOV_load_STEP_0;
wire cond_129 = exe_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0 && exe_modregrm_reg == 3'd0;
wire cond_130 = exe_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0 && exe_modregrm_reg == 3'd1;
wire cond_131 = exe_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0 && exe_modregrm_reg == 3'd2;
wire cond_132 = exe_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0 && exe_modregrm_reg == 3'd3;
wire cond_133 = exe_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0 && (exe_modregrm_reg == 3'd4 || exe_modregrm_reg == 3'd6);
wire cond_134 = exe_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0 && (exe_modregrm_reg == 3'd5 || exe_modregrm_reg == 3'd7);
wire cond_135 = dr7[`DR7_BIT_GD];
wire cond_136 = exe_cmd == `CMD_control_reg && exe_cmdex == `CMDEX_control_reg_LMSW_STEP_0;
wire cond_137 = exe_cmd == `CMD_control_reg && exe_cmdex == `CMDEX_control_reg_MOV_store_STEP_0;
wire cond_138 = exe_modregrm_reg == 3'd0;
wire cond_139 = exe_modregrm_reg == 3'd2;
wire cond_140 = exe_modregrm_reg == 3'd3;
wire cond_141 = exe_cmd == `CMD_control_reg && exe_cmdex == `CMDEX_control_reg_MOV_load_STEP_0;
wire cond_142 = cpl > 2'd0 || (exe_modregrm_reg == 3'd0 && ((src[31] && ~(src[0])) || (src[29] && ~(src[30]))));
wire cond_143 = exe_cmd == `CMD_control_reg && exe_cmdex == `CMDEX_control_reg_SMSW_STEP_0;
wire cond_144 = exe_cmd == `CMD_LOOP;
wire cond_145 = exe_mutex_current[`MUTEX_ECX_BIT] || (exe_mutex_current[`MUTEX_EFLAGS_BIT] && (exe_cmdex == `CMDEX_LOOP_NE || exe_cmdex == `CMDEX_LOOP_E));
wire cond_146 = exe_cmd_loop_condition && exe_branch_eip > cs_limit;
wire cond_147 = exe_cmd == `CMD_NOT;
wire cond_148 = exe_cmd == `CMD_LGDT || exe_cmd == `CMD_LIDT;
wire cond_149 = { exe_cmd[6:2], 2'd0 } == `CMD_BTx;
wire cond_150 = { exe_cmd[6:1], 1'd0 } == `CMD_BSx;
wire cond_151 = exe_cmd == `CMD_BSF;
wire cond_152 = exe_cmd == `CMD_BSR;
wire cond_153 = exe_cmd == `CMD_JMP  && (exe_cmdex == `CMDEX_JMP_Ev_STEP_0  || exe_cmdex == `CMDEX_JMP_Ep_STEP_0  || exe_cmdex == `CMDEX_JMP_Ap_STEP_0);
wire cond_154 = exe_operand_32bit;
wire cond_155 = exe_cmd == `CMD_JMP  && exe_cmdex == `CMDEX_JMP_Jv_STEP_0;
wire cond_156 = exe_cmd == `CMD_CALL && exe_mutex_current[`MUTEX_ESP_BIT];
wire cond_157 = exe_cmd == `CMD_JMP  && exe_cmdex == `CMDEX_JMP_Ev_Jv_STEP_1;
wire cond_158 = exe_cmd == `CMD_JMP  && exe_cmdex == `CMDEX_JMP_Ep_STEP_1;
wire cond_159 = exe_cmd == `CMD_JMP  && exe_cmdex == `CMDEX_JMP_Ap_STEP_1;
wire cond_160 = exe_cmd == `CMD_JMP && exe_cmdex == `CMDEX_JMP_real_v8086_STEP_0;
wire cond_161 = exe_cmd == `CMD_JMP && exe_cmdex == `CMDEX_JMP_real_v8086_STEP_1;
wire cond_162 = exe_cmd == `CMD_JMP && exe_cmdex == `CMDEX_JMP_protected_seg_STEP_0;
wire cond_163 = exe_cmd == `CMD_JMP && exe_cmdex == `CMDEX_JMP_protected_seg_STEP_1;
wire cond_164 = exe_cmd == `CMD_JMP_2 && exe_cmdex == `CMDEX_JMP_2_call_gate_STEP_1;
wire cond_165 = glob_param_1[15:2] == 14'd0 || glob_descriptor[`DESC_BIT_SEG] == `FALSE || `DESC_IS_DATA(glob_descriptor) || (`DESC_IS_CODE_NON_CONFORMING(exe_descriptor) && exe_descriptor[`DESC_BITS_DPL] != cpl) || (`DESC_IS_CODE_CONFORMING(exe_descriptor)     && exe_descriptor[`DESC_BITS_DPL] > cpl);
wire cond_166 = exe_cmd == `CMD_JMP_2 && exe_cmdex == `CMDEX_JMP_2_call_gate_STEP_2;
wire cond_167 = exe_cmd == `CMD_JMP_2 && exe_cmdex == `CMDEX_JMP_2_call_gate_STEP_3;
wire cond_168 = exe_cmd == `CMD_INVLPG && exe_cmdex == `CMDEX_INVLPG_STEP_0;
wire cond_169 = exe_cmd == `CMD_INVLPG && exe_cmdex == `CMDEX_INVLPG_STEP_1;
wire cond_170 = ~(tlbflushsingle_done);
wire cond_171 = (exe_cmd == `CMD_LAR || exe_cmd == `CMD_LSL) && exe_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_LAST;
wire cond_172 = (exe_cmd == `CMD_LAR || exe_cmd == `CMD_LSL || exe_cmd == `CMD_VERR || exe_cmd == `CMD_VERW) && exe_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_2;
wire cond_173 = exe_cmd == `CMD_fpu && exe_cmdex == `CMDEX_ESC_STEP_0;
wire cond_174 = cr0_em || cr0_ts;
wire cond_175 = { exe_cmd[6:3], 3'd0 } == `CMD_Arith;
wire cond_176 = exe_cmd[2:1] == 2'b01 && exe_mutex_current[`MUTEX_EFLAGS_BIT];
wire cond_177 = exe_cmd == `CMD_CLTS;
wire cond_178 = exe_cmd == `CMD_PUSHF;
wire cond_179 = exe_mutex_current[`MUTEX_ESP_BIT] || exe_mutex_current[`MUTEX_EFLAGS_BIT];
wire cond_180 = exe_cmd == `CMD_XADD && exe_cmdex == `CMDEX_XADD_FIRST;
wire cond_181 = exe_cmd == `CMD_XADD && exe_cmdex == `CMDEX_XADD_LAST;
wire cond_182 = exe_cmd == `CMD_POP_seg;
wire cond_183 = exe_cmd == `CMD_NEG;
wire cond_184 = exe_cmd == `CMD_LEAVE;
wire cond_185 = exe_cmd == `CMD_POP && exe_cmdex == `CMDEX_POP_implicit;
wire cond_186 = exe_cmd == `CMD_POP && exe_cmdex == `CMDEX_POP_modregrm_STEP_0;
wire cond_187 = exe_cmd == `CMD_POP && exe_cmdex == `CMDEX_POP_modregrm_STEP_1;
wire cond_188 = exe_cmd == `CMD_io_allow && exe_cmdex == `CMDEX_io_allow_2;
wire cond_189 = (  exe_is_8bit                       && e_io_allow_bits[0]   != 1'd0) || (~(exe_is_8bit) && exe_operand_16bit && e_io_allow_bits[1:0] != 2'd0) || (~(exe_is_8bit) && exe_operand_32bit && e_io_allow_bits[3:0] != 4'd0);
wire cond_190 = exe_cmd == `CMD_TEST;
wire cond_191 = { exe_cmd[6:1], 1'd0 } == `CMD_SHxD;
wire cond_192 = exe_cmd == `CMD_AAD;
wire cond_193 = exe_cmd == `CMD_AAM;
wire cond_194 = exe_div_exception || div_busy;
wire cond_195 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_protected_STEP_1;
wire cond_196 = exe_cmd == `CMD_CALL_2  && exe_cmdex == `CMDEX_CALL_2_protected_seg_STEP_3;
wire cond_197 = exe_cmd == `CMD_CALL && (exe_cmdex == `CMDEX_CALL_Ev_STEP_0 || exe_cmdex == `CMDEX_CALL_Ep_STEP_0 || exe_cmdex == `CMDEX_CALL_Ap_STEP_0);
wire cond_198 = exe_cmdex == `CMDEX_CALL_Ev_STEP_0;
wire cond_199 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_Jv_STEP_0;
wire cond_200 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_Ev_Jv_STEP_1;
wire cond_201 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_Ep_STEP_1;
wire cond_202 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_Ap_STEP_1;
wire cond_203 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_real_v8086_STEP_0;
wire cond_204 = exe_operand_32bit && glob_param_2 > cs_limit;
wire cond_205 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_real_v8086_STEP_1;
wire cond_206 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_real_v8086_STEP_2;
wire cond_207 = exe_operand_16bit && glob_param_2 > cs_limit;
wire cond_208 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_real_v8086_STEP_3;
wire cond_209 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_protected_seg_STEP_0;
wire cond_210 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_protected_seg_STEP_1;
wire cond_211 = exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_protected_seg_STEP_2;
wire cond_212 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_protected_seg_STEP_4;
wire cond_213 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_STEP_0;
wire cond_214 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_same_STEP_0;
wire cond_215 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_same_STEP_1;
wire cond_216 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_same_STEP_2;
wire cond_217 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_protected_seg_STEP_3;
wire cond_218 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_same_STEP_3;
wire cond_219 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_1;
wire cond_220 = glob_param_3[15:2] == 14'd0;
wire cond_221 = exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_3;
wire cond_222 = ss_cache[`DESC_BIT_D_B];
wire cond_223 = exe_cmd == `CMD_CALL_3 && (exe_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_4 || exe_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_5);
wire cond_224 = exe_cmd == `CMD_CALL_3 && exe_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_6;
wire cond_225 = exe_cmd == `CMD_CALL_3 && exe_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_7;
wire cond_226 = glob_descriptor_2[`DESC_BIT_D_B];
wire cond_227 = exe_cmd == `CMD_CALL_3 && exe_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_8;
wire cond_228 = exe_cmd == `CMD_CALL_3 && exe_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_9;
wire cond_229 = exe_cmd == `CMD_CALL_3 && exe_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_10;
wire cond_230 = exe_cmd == `CMD_IN && exe_cmdex == `CMDEX_IN_protected;
wire cond_231 = exe_cmd == `CMD_IN && (exe_cmdex == `CMDEX_IN_dx || exe_cmdex == `CMDEX_IN_imm);
wire cond_232 = exe_cmdex == `CMDEX_IN_dx && exe_mutex_current[`MUTEX_EDX_BIT];
wire cond_233 = exe_cmd == `CMD_task_switch && exe_cmdex == `CMDEX_task_switch_STEP_1;
wire cond_234 = glob_desc_limit < exe_new_tss_max;
wire cond_235 = tr_limit < ((tr_cache[`DESC_BITS_TYPE] <= 4'd3)? 32'h29 : 32'h5F);
wire cond_236 = exe_cmd == `CMD_task_switch && exe_cmdex == `CMDEX_task_switch_STEP_2;
wire cond_237 = ~(tlbcheck_done) && ~(tlbcheck_page_fault);
wire cond_238 = tlbcheck_page_fault;
wire cond_239 = exe_cmd == `CMD_task_switch && exe_cmdex == `CMDEX_task_switch_STEP_3;
wire cond_240 = exe_cmd == `CMD_task_switch && exe_cmdex == `CMDEX_task_switch_STEP_4;
wire cond_241 = exe_cmd == `CMD_task_switch && exe_cmdex == `CMDEX_task_switch_STEP_5;
wire cond_242 = exe_cmd == `CMD_task_switch && exe_cmdex == `CMDEX_task_switch_STEP_7;
wire cond_243 = exe_cmd == `CMD_task_switch && exe_cmdex == `CMDEX_task_switch_STEP_8;
wire cond_244 = exe_cmd == `CMD_task_switch && exe_cmdex == `CMDEX_task_switch_STEP_10;
wire cond_245 = exe_cmd == `CMD_task_switch && exe_cmdex >= `CMDEX_task_switch_STEP_12 && exe_cmdex <= `CMDEX_task_switch_STEP_14;
wire cond_246 = exe_cmd == `CMD_task_switch_2;
wire cond_247 = exe_cmdex <= `CMDEX_task_switch_2_STEP_7;
wire cond_248 = exe_cmdex > `CMDEX_task_switch_2_STEP_7;
wire cond_249 = exe_cmd == `CMD_task_switch_3;
wire cond_250 = exe_cmd == `CMD_task_switch_4 && exe_cmdex == `CMDEX_task_switch_4_STEP_0;
wire cond_251 = exe_cmd == `CMD_task_switch_4 && exe_cmdex == `CMDEX_task_switch_4_STEP_2;
wire cond_252 = glob_param_2[2] || glob_param_2[2:0] == 3'b010 || ( glob_param_2[2:0] == 3'b000 && ( exe_descriptor[`DESC_BIT_SEG] || exe_descriptor[`DESC_BITS_TYPE] != `DESC_LDT ||  exe_descriptor[`DESC_BIT_P] == `FALSE ) );
wire cond_253 = exe_cmd == `CMD_task_switch_4 && exe_cmdex == `CMDEX_task_switch_4_STEP_3;
wire cond_254 = ~(v8086_mode);
wire cond_255 = glob_param_2[1:0] != 2'b00 || ( exe_descriptor[`DESC_BIT_SEG] == 1'b0 || `DESC_IS_CODE(exe_descriptor) || `DESC_IS_DATA_RO(exe_descriptor) || (exe_descriptor[`DESC_BIT_P] && ( exe_descriptor[`DESC_BITS_DPL] != wr_task_rpl || exe_descriptor[`DESC_BITS_DPL] != exe_selector[`SELECTOR_BITS_RPL] ) ) );
wire cond_256 = glob_param_2[1:0] == 2'b00 && exe_descriptor[`DESC_BIT_SEG] && `DESC_IS_DATA_RW(exe_descriptor) && ~(exe_descriptor[`DESC_BIT_P]);
wire cond_257 = exe_cmd == `CMD_task_switch_4 && exe_cmdex >= `CMDEX_task_switch_4_STEP_4 && exe_cmdex <= `CMDEX_task_switch_4_STEP_7;
wire cond_258 = glob_param_2[1:0] == 2'b10 || (glob_param_2[1:0] == 2'b00 && ( exe_descriptor[`DESC_BIT_SEG] == 1'b0 || `DESC_IS_CODE_EO(exe_descriptor) || ((`DESC_IS_DATA(exe_descriptor) || `DESC_IS_CODE_NON_CONFORMING(exe_descriptor)) && exe_privilege_not_accepted) ));
wire cond_259 = glob_param_2[1:0] == 2'b00 && ~(exe_trigger_ts_fault) && ~(exe_descriptor[`DESC_BIT_P]);
wire cond_260 = exe_cmd == `CMD_task_switch_4 && exe_cmdex == `CMDEX_task_switch_4_STEP_8;
wire cond_261 = glob_param_2[1:0] != 2'b00 || ( exe_descriptor[`DESC_BIT_SEG] == 1'b0 || `DESC_IS_DATA(exe_descriptor) || (`DESC_IS_CODE_NON_CONFORMING(exe_descriptor) && exe_descriptor[`DESC_BITS_DPL] != exe_selector[`SELECTOR_BITS_RPL]) || (`DESC_IS_CODE_CONFORMING(exe_descriptor)     && exe_descriptor[`DESC_BITS_DPL] >  exe_selector[`SELECTOR_BITS_RPL]) );
wire cond_262 = exe_cmd == `CMD_task_switch_4 && exe_cmdex == `CMDEX_task_switch_4_STEP_9;
wire cond_263 = exe_cmd == `CMD_task_switch_4 && exe_cmdex == `CMDEX_task_switch_4_STEP_10;
wire cond_264 = exe_eip > cs_limit;
wire cond_265 = exe_cmd == `CMD_POPA;
wire cond_266 = exe_cmd == `CMD_OUTS;
wire cond_267 = exe_cmd == `CMD_LxS;
wire cond_268 = exe_cmd == `CMD_IDIV || exe_cmd == `CMD_DIV;
wire cond_269 = exe_cmd == `CMD_load_seg && exe_cmdex == `CMDEX_load_seg_STEP_1;
wire cond_270 = protected_mode;
wire cond_271 = ((glob_param_1[18:16] == `SEGMENT_SS || glob_param_1[18:16] == `SEGMENT_TR || glob_param_1[18:16] == `SEGMENT_CS) && glob_param_1[15:2] == 14'd0) ||  ((glob_param_1[18:16] == `SEGMENT_LDT || glob_param_1[18:16] == `SEGMENT_TR) && glob_param_1[`SELECTOR_BIT_TI] == 1'b1);
wire cond_272 = exe_cmd == `CMD_load_seg && exe_cmdex == `CMDEX_load_seg_STEP_2;
wire cond_273 = ~(protected_mode && glob_param_1[15:2] == 14'd0);
wire cond_274 = exe_load_seg_gp_fault || exe_load_seg_ss_fault || exe_load_seg_np_fault;
wire cond_275 = exe_cmd == `CMD_BSWAP;
wire cond_276 = exe_cmd == `CMD_OUT && (exe_cmdex == `CMDEX_OUT_dx || exe_cmdex == `CMDEX_OUT_imm);
wire cond_277 = exe_cmdex == `CMDEX_OUT_dx && exe_mutex_current[`MUTEX_EDX_BIT];
wire cond_278 = exe_cmd == `CMD_OUT && exe_cmdex == `CMDEX_OUT_protected;
wire cond_279 = exe_cmd == `CMD_HLT && exe_cmdex == `CMDEX_HLT_STEP_0;
wire cond_280 = (exe_cmd == `CMD_CALL && exe_cmdex == `CMDEX_CALL_protected_STEP_0) || (exe_cmd == `CMD_JMP  && exe_cmdex == `CMDEX_JMP_protected_STEP_0);
wire cond_281 = glob_param_1[15:2] == 14'd0 || (exe_descriptor[`DESC_BIT_SEG] == `FALSE && ( exe_descriptor[`DESC_BITS_DPL] < cpl || exe_descriptor[`DESC_BITS_DPL] < exe_selector[`SELECTOR_BITS_RPL] || ((exe_descriptor[`DESC_BITS_TYPE] == 4'd1 || exe_descriptor[`DESC_BITS_TYPE] == 4'd9) && exe_selector[`SELECTOR_BIT_TI]) ||  exe_descriptor[`DESC_BITS_TYPE] == 4'd0  || exe_descriptor[`DESC_BITS_TYPE] == 4'd8  || exe_descriptor[`DESC_BITS_TYPE] == 4'd10 || exe_descriptor[`DESC_BITS_TYPE] == 4'd13 ||  exe_descriptor[`DESC_BITS_TYPE] == 4'd2  || exe_descriptor[`DESC_BITS_TYPE] == 4'd3  || exe_descriptor[`DESC_BITS_TYPE] == 4'd6  || exe_descriptor[`DESC_BITS_TYPE] == 4'd7  || exe_descriptor[`DESC_BITS_TYPE] == 4'd11 || exe_descriptor[`DESC_BITS_TYPE] == 4'd14 || exe_descriptor[`DESC_BITS_TYPE] == 4'd15)  ) || (exe_descriptor[`DESC_BIT_SEG] && ( `DESC_IS_DATA(exe_descriptor) || (`DESC_IS_CODE_NON_CONFORMING(exe_descriptor) && (exe_descriptor[`DESC_BITS_DPL] != cpl || exe_selector[`SELECTOR_BITS_RPL] > cpl)) || (`DESC_IS_CODE_CONFORMING(exe_descriptor)     &&  exe_descriptor[`DESC_BITS_DPL] > cpl))  ) ;
wire cond_282 = ~(exe_trigger_gp_fault) && exe_descriptor[`DESC_BIT_P] == `FALSE &&  (exe_descriptor[`DESC_BIT_SEG] || exe_descriptor[`DESC_BITS_TYPE] == 4'd1 || exe_descriptor[`DESC_BITS_TYPE] == 4'd9 ||  exe_descriptor[`DESC_BITS_TYPE] == 4'd4 || exe_descriptor[`DESC_BITS_TYPE] == 4'd12 ||  exe_descriptor[`DESC_BITS_TYPE] == 4'd5)  ;
wire cond_283 = (exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_task_switch_STEP_0) || (exe_cmd == `CMD_JMP    && exe_cmdex == `CMDEX_JMP_task_switch_STEP_0);
wire cond_284 = exe_cmd == `CMD_CALL_2;
wire cond_285 = exe_cmd == `CMD_JMP;
wire cond_286 = (exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_task_gate_STEP_1) || (exe_cmd == `CMD_JMP    && exe_cmdex == `CMDEX_JMP_task_gate_STEP_1) || (exe_cmd == `CMD_int    && exe_cmdex == `CMDEX_int_task_gate_STEP_1);
wire cond_287 = glob_param_1[`SELECTOR_BIT_TI] || glob_descriptor[`DESC_BIT_SEG] || (glob_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_AVAIL_386 && glob_descriptor[`DESC_BITS_TYPE] != `DESC_TSS_AVAIL_286);
wire cond_288 = exe_cmd == `CMD_int;
wire cond_289 = exe_cmd != `CMD_int;
wire cond_290 = (exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_STEP_1) || (exe_cmd == `CMD_int    && exe_cmdex == `CMDEX_int_int_trap_gate_STEP_1);
wire cond_291 = glob_param_1[15:2] == 14'd0 || glob_descriptor[`DESC_BIT_SEG] == `FALSE ||  `DESC_IS_DATA(glob_descriptor) || glob_descriptor[`DESC_BITS_DPL] > cpl;
wire cond_292 = (exe_cmd == `CMD_CALL_2 && exe_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_2) || (exe_cmd == `CMD_int_2  && exe_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_2);
wire cond_293 = glob_param_5[0] || glob_param_1[`SELECTOR_BITS_RPL] != glob_descriptor_2[`DESC_BITS_DPL] ||  glob_descriptor[`DESC_BITS_DPL] != glob_descriptor_2[`DESC_BITS_DPL] || glob_descriptor[`DESC_BIT_SEG] == `FALSE || `DESC_IS_CODE(glob_descriptor) || `DESC_IS_DATA_RO(glob_descriptor);
wire cond_294 = glob_param_5[0] == 1'b0 && ~(exe_trigger_ts_fault) && ~(glob_descriptor[`DESC_BIT_P]);
wire cond_295 = exe_cmd == `CMD_CMPS;
wire cond_296 = exe_cmd == `CMD_ENTER && exe_cmdex == `CMDEX_ENTER_FIRST;
wire cond_297 = exe_cmd == `CMD_ENTER && exe_cmdex == `CMDEX_ENTER_LAST;
wire cond_298 = exe_cmd == `CMD_ENTER && (exe_cmdex == `CMDEX_ENTER_PUSH || exe_cmdex == `CMDEX_ENTER_LOOP);
wire cond_299 = exe_cmdex == `CMDEX_ENTER_PUSH;
//======================================================== saves
wire [31:0] exe_buffer_to_reg =
    (cond_1)? ( dst) :
    (cond_57 && cond_7)? ( src) :
    (cond_122)? ( src) :
    (cond_180)? ( dst) :
    (cond_186)? ( src) :
    (cond_245 && cond_7)? ( src) :
    (cond_249 && cond_7)? ( (exe_cmdex == `CMDEX_task_switch_3_STEP_15 && glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? 32'd0 : src) :
    (cond_265 && cond_7)? ( src) :
    (cond_296 && ~cond_66)? ( exe_enter_offset) :
    exe_buffer;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) exe_buffer <= 32'd0;
    else              exe_buffer <= exe_buffer_to_reg;
end
//======================================================== sets
assign offset_call =
    (cond_209)? (`TRUE) :
    (cond_210)? (`TRUE) :
    1'd0;
assign exe_result_signals =
    (cond_70)? ( { 4'd0, dst[1:0] < src[1:0] }) :
    (cond_76)? ( { 4'd0, e_cmpxchg_eq }) :
    (cond_81)? ( { e_shift_no_write, e_shift_oszapc_update, e_shift_cf_of_update, e_shift_oflag, e_shift_cflag }) :
    (cond_82)? ( { e_shift_no_write, e_shift_oszapc_update, e_shift_cf_of_update, e_shift_oflag, e_shift_cflag }) :
    (cond_95 && ~cond_62)? ( { 4'd0, exe_condition }) :
    (cond_116)? ( { 3'b0, exe_bcd_condition_af, exe_bcd_condition_cf }) :
    (cond_118 && ~cond_119)? ( { 4'd0, exe_jecxz_condition }) :
    (cond_144 && ~cond_145)? ( { 4'd0, exe_cmd_loop_condition }) :
    (cond_149)? ( { 4'd0, e_bit_selected }) :
    (cond_150)? ( { 4'd0, e_bit_scan_zero }) :
    (cond_191)? ( { e_shift_no_write, e_shift_oszapc_update, e_shift_cf_of_update, e_shift_oflag, e_shift_cflag }) :
    5'd0;
assign offset_leave =
    (cond_184)? (`TRUE) :
    1'd0;
assign offset_int_real_next =
    (cond_20)? (`TRUE) :
    (cond_21)? (`TRUE) :
    1'd0;
assign exe_glob_param_2_value =
    (cond_3)? ( (glob_descriptor[`DESC_BITS_TYPE] >= `DESC_INTERRUPT_GATE_386)? { glob_descriptor[63:48], glob_descriptor[15:0] } : { 16'd0, glob_descriptor[15:0] }) :
    (cond_153 && cond_154)? ( src) :
    (cond_153 && ~cond_154)? ( { 16'd0, src[15:0] }) :
    (cond_155 && cond_154)? ( exe_arith_add[31:0]) :
    (cond_155 && ~cond_154)? ( { 16'd0, exe_arith_add[15:0] }) :
    (cond_172)? ( { 26'd0, exe_cmd_verw_desc_invalid, exe_cmd_verr_desc_invalid, exe_cmd_lsl_desc_invalid, exe_cmd_lar_desc_invalid, glob_param_2[1:0] }) :
    (cond_197 && cond_154)? ( src) :
    (cond_197 && ~cond_154)? ( { 16'd0, src[15:0] }) :
    (cond_199 && cond_154)? ( exe_arith_add[31:0]) :
    (cond_199 && ~cond_154)? ( { 16'd0, exe_arith_add[15:0] }) :
    (cond_213)? ( (glob_descriptor[`DESC_BITS_TYPE] == `DESC_CALL_GATE_386)? { glob_descriptor[63:48], glob_descriptor[15:0] } : { 16'd0, glob_descriptor[15:0] }) :
    (cond_263)? ( exe_eip) :
    32'd0;
assign offset_pop =
    (cond_46)? (`TRUE) :
    (cond_48)? (`TRUE) :
    (cond_49)? (`TRUE) :
    (cond_71 && cond_72)? (`TRUE) :
    (cond_94)? (`TRUE) :
    (cond_107)? (`TRUE) :
    (cond_110)? ( exe_decoder[0] == 1'b1) :
    (cond_114 && cond_115)? ( exe_decoder[0] == 1'b1) :
    (cond_182)? (`TRUE) :
    (cond_185)? (`TRUE) :
    (cond_186)? (`TRUE) :
    (cond_187)? (`TRUE) :
    (cond_265)? (`TRUE) :
    1'd0;
assign exe_trigger_pf_fault =
    (cond_236 && cond_238)? (`TRUE) :
    (cond_239 && cond_238)? (`TRUE) :
    (cond_240 && cond_238)? (`TRUE) :
    (cond_241 && cond_238)? (`TRUE) :
    (cond_242 && cond_238)? (`TRUE) :
    (cond_243 && cond_238)? (`TRUE) :
    1'd0;
assign offset_int_real =
    (cond_18)? (`TRUE) :
    1'd0;
assign exe_glob_param_1_set =
    (cond_3)? (`TRUE) :
    (cond_4 && cond_7)? (`TRUE) :
    (cond_11 && cond_13)? (`TRUE) :
    (cond_43 && ~cond_9)? (`TRUE) :
    (cond_44)? (`TRUE) :
    (cond_97 && ~cond_98)? (`TRUE) :
    (cond_111 && ~cond_9)? (`TRUE) :
    (cond_112)? ( exe_ready) :
    (cond_158)? (`TRUE) :
    (cond_159 && cond_154)? (`TRUE) :
    (cond_159 && ~cond_154)? (`TRUE) :
    (cond_201)? (`TRUE) :
    (cond_202 && cond_154)? (`TRUE) :
    (cond_202 && ~cond_154)? (`TRUE) :
    (cond_213)? (`TRUE) :
    (cond_219 && cond_7)? (`TRUE) :
    (cond_228 && cond_7)? (`TRUE) :
    (cond_231 && ~cond_232)? (`TRUE) :
    (cond_266 && ~cond_98)? (`TRUE) :
    (cond_276 && ~cond_277)? (`TRUE) :
    (cond_283 && cond_284)? (`TRUE) :
    (cond_283 && cond_285)? (`TRUE) :
    (cond_286 && cond_284)? (`TRUE) :
    (cond_286 && cond_285)? (`TRUE) :
    (cond_286 && cond_288)? (`TRUE) :
    1'd0;
assign exe_eip_from_glob_param_2_16bit =
    (cond_58)? (`TRUE) :
    1'd0;
assign offset_call_keep =
    (cond_211)? (`TRUE) :
    (cond_216)? (`TRUE) :
    (cond_217)? (`TRUE) :
    1'd0;
assign tlbflushsingle_do =
    (cond_169)? (`TRUE) :
    1'd0;
assign dr6_bd_set =
    (cond_127 && cond_135)? ( `TRUE) :
    1'd0;
assign exe_trigger_nm_fault =
    (cond_173 && cond_174)? (`TRUE) :
    1'd0;
assign offset_ret_imm =
    (cond_113)? (             exe_decoder[0] == 1'b0) :
    1'd0;
assign offset_task =
    (cond_262)? (`TRUE) :
    1'd0;
assign exe_trigger_ss_fault =
    (cond_253 && cond_254 && cond_256)? (`TRUE) :
    (cond_292 && cond_294)? (`TRUE) :
    1'd0;
assign exe_result2 =
    (cond_0)? ( dst) :
    (cond_76)? ( dst) :
    (cond_78)? ( src) :
    (cond_94)? ( src) :
    (cond_99)? ( mult_result[63:32]) :
    (cond_121)? ( dst) :
    (cond_125)? ( dst) :
    (cond_126)? ( mult_result[63:32]) :
    (cond_127 && cond_128)? ( src) :
    (cond_136)? ( src) :
    (cond_141)? ( src) :
    (cond_148)? ( src) :
    (cond_192)? ( mult_result[63:32]) :
    (cond_193)? ( div_result_remainder) :
    (cond_230)? ( src) :
    (cond_231)? ( src) :
    (cond_246 && cond_247)? ( src) :
    (cond_246 && cond_248)? ( { 16'd0, e_seg_by_cmdex }) :
    (cond_250)? ( src) :
    (cond_268)? ( div_result_remainder) :
    32'd0;
assign exe_task_switch_finished =
    (cond_263)? (`TRUE) :
    1'd0;
assign tlbcheck_rw =
    (cond_236)? (       `FALSE) :
    (cond_239)? (       `FALSE) :
    (cond_240)? (       `TRUE) :
    (cond_241)? (       `TRUE) :
    (cond_242)? (       `TRUE) :
    (cond_243)? (       `TRUE) :
    1'd0;
assign offset_ret_far_se =
    (cond_114 && cond_115)? (`TRUE) :
    1'd0;
assign invddata_do =
    (cond_105)? ( ~(e_invd_data_done)) :
    1'd0;
assign offset_new_stack =
    (cond_8)? (`TRUE) :
    1'd0;
assign exe_glob_descriptor_set =
    (cond_11 && cond_13)? (`TRUE) :
    (cond_43 && ~cond_9)? (`TRUE) :
    (cond_44)? (`TRUE) :
    (cond_111 && ~cond_9)? (`TRUE) :
    (cond_112)? ( exe_ready) :
    (cond_209)? (`TRUE) :
    (cond_211 && ~cond_12)? (`TRUE) :
    (cond_228 && cond_7)? (`TRUE) :
    1'd0;
assign offset_call_int_same_next =
    (cond_32)? (`TRUE) :
    (cond_33)? (`TRUE) :
    (cond_34)? (`TRUE) :
    (cond_215)? (`TRUE) :
    1'd0;
assign exe_cmpxchg_switch_carry =
    (cond_76)? ( e_cmpxchg_sub[32]) :
    1'd0;
assign exe_glob_param_1_value =
    (cond_3)? ( { 11'd0, glob_descriptor[`DESC_BIT_TYPE_BIT_0], glob_descriptor[`DESC_BITS_TYPE] >= `DESC_INTERRUPT_GATE_386, `SEGMENT_CS, glob_descriptor[31:16] }) :
    (cond_4 && cond_7)? ( { 13'd0, `SEGMENT_SS, glob_param_3[15:0] }) :
    (cond_11 && cond_13)? ( glob_param_3) :
    (cond_43 && ~cond_9)? ( glob_param_3) :
    (cond_44)? ( glob_param_3) :
    (cond_97 && ~cond_98)? ( { 16'd0, edx[15:0] }) :
    (cond_111 && ~cond_9)? ( glob_param_3) :
    (cond_112)? ( glob_param_3) :
    (cond_158)? ( { 13'd0, `SEGMENT_CS, src[15:0] }) :
    (cond_159 && cond_154)? ( { 13'd0, `SEGMENT_CS, exe_extra[31:16] }) :
    (cond_159 && ~cond_154)? ( { 13'd0, `SEGMENT_CS, exe_extra[15:0] }) :
    (cond_201)? ( { 13'd0, `SEGMENT_CS, src[15:0] }) :
    (cond_202 && cond_154)? ( { 13'd0, `SEGMENT_CS, exe_extra[31:16] }) :
    (cond_202 && ~cond_154)? ( { 13'd0, `SEGMENT_CS, exe_extra[15:0] }) :
    (cond_213)? ( { 7'd0, glob_descriptor[36:32], glob_descriptor[`DESC_BITS_TYPE] == `DESC_CALL_GATE_386, `SEGMENT_CS, glob_descriptor[31:16] }) :
    (cond_219 && cond_7)? ( { 13'd0, `SEGMENT_SS, glob_param_3[15:0] }) :
    (cond_228 && cond_7)? ( glob_param_3) :
    (cond_231 && ~cond_232)? ( (exe_cmdex == `CMDEX_IN_dx)? { 16'd0, edx[15:0] } : { 24'd0, exe_decoder[15:8] }) :
    (cond_266 && ~cond_98)? ( { 16'd0, edx[15:0] }) :
    (cond_276 && ~cond_277)? ( (exe_cmdex == `CMDEX_OUT_dx)? { 16'd0, edx[15:0] } : { 24'd0, exe_decoder[15:8] }) :
    (cond_283 && cond_284)? ( { 14'd0, `TASK_SWITCH_FROM_CALL, glob_param_1[15:0] }) :
    (cond_283 && cond_285)? ( { 14'd0, `TASK_SWITCH_FROM_JUMP, glob_param_1[15:0] }) :
    (cond_286 && cond_284)? ( { 14'd0, `TASK_SWITCH_FROM_CALL, glob_param_1[15:0] }) :
    (cond_286 && cond_285)? ( { 14'd0, `TASK_SWITCH_FROM_JUMP, glob_param_1[15:0] }) :
    (cond_286 && cond_288)? ( { 14'd0, `TASK_SWITCH_FROM_INT,  glob_param_1[15:0] }) :
    32'd0;
assign exe_buffer_shift =
    (cond_57 && cond_7)? (`TRUE) :
    (cond_245 && cond_7)? (`TRUE) :
    (cond_249 && cond_7)? (       exe_cmdex <= `CMDEX_task_switch_3_STEP_8) :
    (cond_265 && cond_7)? (`TRUE) :
    1'd0;
assign offset_call_int_same_first =
    (cond_30)? (`TRUE) :
    (cond_214)? (`TRUE) :
    1'd0;
assign exe_result =
    (cond_0)? (  src) :
    (cond_1)? (  src) :
    (cond_2)? ( exe_buffer) :
    (cond_67)? ( exe_arith_sub[31:0]) :
    (cond_70)? ( { 16'd0, dst[15:2], src[1:0] }) :
    (cond_76)? (  e_cmpxchg_result) :
    (cond_79 && cond_80)? ( 32'd1) :
    (cond_81)? ( e_shift_result) :
    (cond_82)? ( e_shift_result) :
    (cond_83)? ( (exe_cmdex[0] == `FALSE)? exe_arith_add[31:0] : exe_arith_sub[31:0]) :
    (cond_85)? ( { 16'd0, e_seg_by_cmdex }) :
    (cond_90 && cond_91)? ( { 16'd0, gdtr_limit }) :
    (cond_90 && cond_92)? ( gdtr_base) :
    (cond_93 && cond_91)? ( { 16'd0, idtr_limit }) :
    (cond_93 && cond_92)? ( idtr_base) :
    (cond_99)? (  mult_result[31:0]) :
    (cond_101)? ( exe_address_effective) :
    (cond_102)? ( (exe_cmd == `CMD_MOVSX && exe_is_8bit)?     { {24{src[7]}},  src[7:0] } : (exe_cmd == `CMD_MOVSX)?                    { {16{src[15]}}, src[15:0] } : (exe_cmd == `CMD_MOVZX && exe_is_8bit)?     { 24'd0, src[7:0] } : { 16'd0, src[15:0] }) :
    (cond_116)? ( (exe_cmd == `CMD_AAA)?  { 16'd0, e_aaa_result } : (exe_cmd == `CMD_AAS)?  { 16'd0, e_aas_result } : (exe_cmd == `CMD_DAA)?  { 16'd0, dst[15:8], e_daa_result } : { 16'd0, dst[15:8], e_das_result }) :
    (cond_121)? (  src) :
    (cond_125)? (  src) :
    (cond_126)? (  mult_result[31:0]) :
    (cond_127 && cond_129)? ( dr0) :
    (cond_127 && cond_130)? ( dr1) :
    (cond_127 && cond_131)? ( dr2) :
    (cond_127 && cond_132)? ( dr3) :
    (cond_127 && cond_133)? ( { 16'hFFFF, dr6_bt, dr6_bs, dr6_bd, dr6_b12, 8'hFF, dr6_breakpoints }) :
    (cond_127 && cond_134)? ( dr7) :
    (cond_137 && cond_138)? ( e_cr0_reg) :
    (cond_137 && cond_139)? ( cr2) :
    (cond_137 && cond_140)? ( cr3) :
    (cond_143)? ( e_cr0_reg) :
    (cond_147)? ( exe_arith_not) :
    (cond_149)? ( e_bit_result) :
    (cond_150 && cond_151)? ( { 27'd0, e_bit_scan_forward }) :
    (cond_150 && cond_152)? ( { 27'd0, e_bit_scan_reverse }) :
    (cond_171)? ( exe_extra) :
    (cond_175)? ( ({ 1'b0, exe_cmd[2:0] } == `ARITH_ADD)?   exe_arith_add[31:0] : ({ 1'b0, exe_cmd[2:0] } == `ARITH_OR)?    exe_arith_or : ({ 1'b0, exe_cmd[2:0] } == `ARITH_ADC)?   exe_arith_adc[31:0] : ({ 1'b0, exe_cmd[2:0] } == `ARITH_SBB)?   exe_arith_sbb[31:0] : ({ 1'b0, exe_cmd[2:0] } == `ARITH_AND)?   exe_arith_and : ({ 1'b0, exe_cmd[2:0] } == `ARITH_XOR)?   exe_arith_xor : exe_arith_sub[31:0]) :
    (cond_180)? (  exe_arith_add[31:0]) :
    (cond_181)? ( exe_buffer) :
    (cond_183)? ( exe_arith_sub[31:0]) :
    (cond_185)? ( src) :
    (cond_187)? ( exe_buffer) :
    (cond_190)? ( exe_arith_and) :
    (cond_191)? ( e_shift_result) :
    (cond_192)? (  { 24'd0, e_aad_result }) :
    (cond_193)? (  { 16'd0, div_result_quotient[7:0], div_result_remainder[7:0] }) :
    (cond_267)? ( glob_param_2) :
    (cond_268)? ( (exe_is_8bit)?          { 16'd0, div_result_remainder[7:0], div_result_quotient[7:0] } : (exe_operand_16bit)?    { div_result_remainder[15:0], div_result_quotient[15:0] } : div_result_quotient) :
    (cond_275 && cond_154)? ( { dst[7:0], dst[15:8], dst[23:16], dst[31:24] }) :
    (cond_295)? ( exe_arith_sub[31:0]) :
    32'd0;
assign exe_arith_index =
    (cond_67)? ( (`ARITH_VALID | `ARITH_SUB)) :
    (cond_76)? ( (`ARITH_VALID | `ARITH_SUB)) :
    (cond_83)? ( (exe_cmdex[0] == `FALSE)? (`ARITH_VALID | `ARITH_ADD) : (`ARITH_VALID | `ARITH_SUB)) :
    (cond_175)? ( {`TRUE, exe_cmd[2:0]}) :
    (cond_180)? ( (`ARITH_VALID | `ARITH_ADD)) :
    (cond_183)? ( (`ARITH_VALID | `ARITH_SUB)) :
    (cond_190)? ( (`ARITH_VALID | `ARITH_AND)) :
    (cond_295)? ( (`ARITH_VALID | `ARITH_SUB)) :
    4'd0;
assign exe_is_8bit_clear =
    (cond_102)? ( exe_is_8bit) :
    1'd0;
assign exe_trigger_db_fault =
    (cond_127 && cond_135)? (`TRUE) :
    1'd0;
assign exe_error_code =
    (cond_4 && cond_5)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_25 && cond_26)? ( { 5'd0, exc_vector[7:0], 3'b010 }) :
    (cond_27 && cond_28)? ( { 5'd0, exc_vector[7:0], 3'b010 }) :
    (cond_27 && cond_29)? ( { 5'd0, exc_vector[7:0], 3'b010 }) :
    (cond_30 && cond_31)? ( (exe_int_2_int_trap_same_exception)? `SELECTOR_FOR_CODE(glob_param_1) : 16'd0) :
    (cond_52 && cond_53)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_54 && cond_55)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_54 && cond_56)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_59 && cond_60)? ( { glob_param_1[15:2], 2'd0 }) :
    (cond_164 && cond_165)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_164 && cond_29)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_233 && cond_234)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_233 && cond_235)? ( `SELECTOR_FOR_CODE(tr)) :
    (cond_251 && cond_252)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_253 && cond_254 && cond_255)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_253 && cond_254 && cond_256)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_257 && cond_254 && cond_258)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_257 && cond_254 && cond_259)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_260 && cond_254 && cond_261)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_260 && cond_254 && cond_259)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_269 && cond_270 && cond_271)? ( { glob_param_1[15:2], 2'd0 }) :
    (cond_272 && cond_273)? ( { glob_param_1[15:2], 2'd0 }) :
    (cond_280 && cond_281)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_280 && cond_282)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_286 && cond_287)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_286 && cond_29)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_290 && cond_291)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_290 && cond_29)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_292 && cond_293)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_292 && cond_294)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    16'd0;
assign offset_iret =
    (cond_40)? (`TRUE) :
    1'd0;
assign exe_trigger_gp_fault =
    (cond_4 && cond_5)? (`TRUE) :
    (cond_8 && cond_9)? (`TRUE) :
    (cond_16 && cond_17)? (`TRUE) :
    (cond_18 && cond_19)? (`TRUE) :
    (cond_22 && cond_23)? (`TRUE) :
    (cond_25 && cond_26)? (`TRUE) :
    (cond_27 && cond_28)? (`TRUE) :
    (cond_30 && cond_31)? (`TRUE) :
    (cond_40 && cond_41)? (`TRUE) :
    (cond_43 && cond_9)? (`TRUE) :
    (cond_46 && cond_47)? (`TRUE) :
    (cond_49 && cond_50)? (`TRUE) :
    (cond_59 && cond_60)? (`TRUE) :
    (cond_61 && ~cond_62 && cond_63)? (`TRUE) :
    (cond_71 && cond_23)? (`TRUE) :
    (cond_74 && cond_75)? (`TRUE) :
    (cond_86 && cond_87)? (`TRUE) :
    (cond_94 && ~cond_62 && cond_47)? (`TRUE) :
    (cond_95 && ~cond_62 && cond_96)? (`TRUE) :
    (cond_104 && cond_87)? (`TRUE) :
    (cond_108 && cond_109)? (`TRUE) :
    (cond_110 && cond_41)? (`TRUE) :
    (cond_111 && cond_9)? (`TRUE) :
    (cond_118 && ~cond_119 && cond_120)? (`TRUE) :
    (cond_127 && ~cond_135 && cond_87)? (`TRUE) :
    (cond_136 && cond_87)? (`TRUE) :
    (cond_137 && cond_87)? (`TRUE) :
    (cond_141 && cond_142)? (`TRUE) :
    (cond_144 && ~cond_145 && cond_146)? (`TRUE) :
    (cond_148 && cond_75)? (`TRUE) :
    (cond_157 && cond_23)? (`TRUE) :
    (cond_160 && cond_23)? (`TRUE) :
    (cond_162 && cond_41)? (`TRUE) :
    (cond_164 && cond_165)? (`TRUE) :
    (cond_166 && cond_41)? (`TRUE) :
    (cond_168 && cond_87)? (`TRUE) :
    (cond_177 && cond_87)? (`TRUE) :
    (cond_178 && ~cond_179 && cond_47)? (`TRUE) :
    (cond_188 && cond_189)? (`TRUE) :
    (cond_196 && cond_41)? (`TRUE) :
    (cond_200 && cond_23)? (`TRUE) :
    (cond_203 && cond_204)? (`TRUE) :
    (cond_206 && cond_207)? (`TRUE) :
    (cond_216 && cond_41)? (`TRUE) :
    (cond_227 && cond_9)? (`TRUE) :
    (cond_263 && cond_264)? (`TRUE) :
    (cond_269 && cond_270 && cond_271)? (`TRUE) :
    (cond_279 && cond_87)? (`TRUE) :
    (cond_280 && cond_281)? (`TRUE) :
    (cond_286 && cond_287)? (`TRUE) :
    (cond_290 && cond_291)? (`TRUE) :
    1'd0;
assign invdcode_do =
    (cond_88)? (   ~(e_wbinvd_code_done)) :
    (cond_105)? ( ~(e_invd_code_done)) :
    1'd0;
assign exe_glob_descriptor_2_set =
    (cond_4 && cond_7)? (`TRUE) :
    (cond_11 && cond_13)? (`TRUE) :
    (cond_43 && ~cond_9)? (`TRUE) :
    (cond_44)? (`TRUE) :
    (cond_111 && ~cond_9)? (`TRUE) :
    (cond_112)? ( exe_ready) :
    (cond_209)? (`TRUE) :
    (cond_219 && cond_7)? (`TRUE) :
    1'd0;
assign tlbcheck_address =
    (cond_236)? (   glob_desc_base) :
    (cond_239)? (   glob_desc_base + exe_new_tss_max) :
    (cond_240)? (   glob_desc_base) :
    (cond_241)? (   glob_desc_base + 32'd1) :
    (cond_242)? (   (tr_cache[`DESC_BITS_TYPE] <= 4'd3)? tr_base + 32'd14 : tr_base + 32'h20) :
    (cond_243)? (   (tr_cache[`DESC_BITS_TYPE] <= 4'd3)? tr_base + 32'd41 : tr_base + 32'h5D) :
    32'd0;
assign offset_ret =
    (cond_71 && cond_73)? (`TRUE) :
    (cond_110)? ( exe_decoder[0] == 1'b0) :
    (cond_114 && cond_115)? ( exe_decoder[0] == 1'b0) :
    1'd0;
assign offset_enter_last =
    (cond_297)? (`TRUE) :
    1'd0;
assign exe_waiting =
    (cond_4 && cond_5)? (`TRUE) :
    (cond_4 && cond_6)? (`TRUE) :
    (cond_8 && cond_9)? (`TRUE) :
    (cond_11 && cond_12)? (`TRUE) :
    (cond_15 && cond_12)? (`TRUE) :
    (cond_16 && cond_17)? (`TRUE) :
    (cond_18 && cond_19)? (`TRUE) :
    (cond_22 && cond_23)? (`TRUE) :
    (cond_25 && cond_26)? (`TRUE) :
    (cond_27 && cond_28)? (`TRUE) :
    (cond_27 && cond_29)? (`TRUE) :
    (cond_30 && cond_31)? (`TRUE) :
    (cond_40 && cond_41)? (`TRUE) :
    (cond_43 && cond_9)? (`TRUE) :
    (cond_46 && cond_47)? (`TRUE) :
    (cond_49 && cond_50)? (`TRUE) :
    (cond_52 && cond_53)? (`TRUE) :
    (cond_54 && cond_55)? (`TRUE) :
    (cond_54 && cond_56)? (`TRUE) :
    (cond_59 && cond_60)? (`TRUE) :
    (cond_61 && cond_62)? (`TRUE) :
    (cond_61 && ~cond_62 && cond_63)? (`TRUE) :
    (cond_64 && cond_66)? (`TRUE) :
    (cond_68 && cond_66)? (`TRUE) :
    (cond_71 && cond_23)? (`TRUE) :
    (cond_74 && cond_75)? (`TRUE) :
    (cond_76 && cond_77)? (`TRUE) :
    (cond_79 && cond_62)? (`TRUE) :
    (cond_81 && cond_62)? (`TRUE) :
    (cond_84 && cond_66)? (`TRUE) :
    (cond_86 && cond_87)? (`TRUE) :
    (cond_88 && cond_89)? (`TRUE) :
    (cond_94 && cond_62)? (`TRUE) :
    (cond_94 && ~cond_62 && cond_47)? (`TRUE) :
    (cond_95 && cond_62)? (`TRUE) :
    (cond_95 && ~cond_62 && cond_96)? (`TRUE) :
    (cond_97 && cond_98)? (`TRUE) :
    (cond_99 && cond_100)? (`TRUE) :
    (cond_104 && cond_87)? (`TRUE) :
    (cond_105 && cond_106)? (`TRUE) :
    (cond_108 && cond_109)? (`TRUE) :
    (cond_110 && cond_41)? (`TRUE) :
    (cond_111 && cond_9)? (`TRUE) :
    (cond_113 && cond_12)? (`TRUE) :
    (cond_116 && cond_62)? (`TRUE) :
    (cond_118 && cond_119)? (`TRUE) :
    (cond_118 && ~cond_119 && cond_120)? (`TRUE) :
    (cond_123 && cond_124)? (`TRUE) :
    (cond_126 && cond_100)? (`TRUE) :
    (cond_127 && cond_135)? (`TRUE) :
    (cond_127 && ~cond_135 && cond_87)? (`TRUE) :
    (cond_136 && cond_87)? (`TRUE) :
    (cond_137 && cond_87)? (`TRUE) :
    (cond_141 && cond_142)? (`TRUE) :
    (cond_144 && cond_145)? (`TRUE) :
    (cond_144 && ~cond_145 && cond_146)? (`TRUE) :
    (cond_148 && cond_75)? (`TRUE) :
    (cond_155 && cond_156)? (`TRUE) :
    (cond_157 && cond_23)? (`TRUE) :
    (cond_160 && cond_23)? (`TRUE) :
    (cond_162 && cond_41)? (`TRUE) :
    (cond_164 && cond_165)? (`TRUE) :
    (cond_164 && cond_29)? (`TRUE) :
    (cond_166 && cond_41)? (`TRUE) :
    (cond_168 && cond_87)? (`TRUE) :
    (cond_169 && cond_170)? (`TRUE) :
    (cond_173 && cond_174)? (`TRUE) :
    (cond_175 && cond_176)? (`TRUE) :
    (cond_177 && cond_87)? (`TRUE) :
    (cond_178 && cond_179)? (`TRUE) :
    (cond_178 && ~cond_179 && cond_47)? (`TRUE) :
    (cond_188 && cond_189)? (`TRUE) :
    (cond_192 && cond_100)? (`TRUE) :
    (cond_193 && cond_194)? (`TRUE) :
    (cond_196 && cond_41)? (`TRUE) :
    (cond_197 && cond_198 && cond_66)? (`TRUE) :
    (cond_199 && cond_66)? (`TRUE) :
    (cond_200 && cond_23)? (`TRUE) :
    (cond_203 && cond_204)? (`TRUE) :
    (cond_205 && cond_12)? (`TRUE) :
    (cond_206 && cond_207)? (`TRUE) :
    (cond_211 && cond_12)? (`TRUE) :
    (cond_216 && cond_41)? (`TRUE) :
    (cond_219 && cond_220)? (`TRUE) :
    (cond_227 && cond_9)? (`TRUE) :
    (cond_231 && cond_232)? (`TRUE) :
    (cond_233 && cond_234)? (`TRUE) :
    (cond_233 && cond_235)? (`TRUE) :
    (cond_236 && cond_237)? (`TRUE) :
    (cond_236 && cond_238)? (`TRUE) :
    (cond_239 && cond_237)? (`TRUE) :
    (cond_239 && cond_238)? (`TRUE) :
    (cond_240 && cond_237)? (`TRUE) :
    (cond_240 && cond_238)? (`TRUE) :
    (cond_241 && cond_237)? (`TRUE) :
    (cond_241 && cond_238)? (`TRUE) :
    (cond_242 && cond_237)? (`TRUE) :
    (cond_242 && cond_238)? (`TRUE) :
    (cond_243 && cond_237)? (`TRUE) :
    (cond_243 && cond_238)? (`TRUE) :
    (cond_251 && cond_252)? (`TRUE) :
    (cond_253 && cond_254 && cond_255)? (`TRUE) :
    (cond_253 && cond_254 && cond_256)? (`TRUE) :
    (cond_257 && cond_254 && cond_258)? (`TRUE) :
    (cond_257 && cond_254 && cond_259)? (`TRUE) :
    (cond_260 && cond_254 && cond_261)? (`TRUE) :
    (cond_260 && cond_254 && cond_259)? (`TRUE) :
    (cond_263 && cond_264)? (`TRUE) :
    (cond_266 && cond_98)? (`TRUE) :
    (cond_268 && cond_194)? (`TRUE) :
    (cond_269 && cond_270 && cond_271)? (`TRUE) :
    (cond_272 && cond_273 && cond_274)? (`TRUE) :
    (cond_276 && cond_277)? (`TRUE) :
    (cond_279 && cond_87)? (`TRUE) :
    (cond_280 && cond_281)? (`TRUE) :
    (cond_280 && cond_282)? (`TRUE) :
    (cond_286 && cond_287)? (`TRUE) :
    (cond_286 && cond_29)? (`TRUE) :
    (cond_290 && cond_291)? (`TRUE) :
    (cond_290 && cond_29)? (`TRUE) :
    (cond_292 && cond_293)? (`TRUE) :
    (cond_292 && cond_294)? (`TRUE) :
    (cond_296 && cond_66)? (`TRUE) :
    (cond_298 && cond_66)? (`TRUE) :
    1'd0;
assign exe_trigger_ts_fault =
    (cond_4 && cond_6)? (`TRUE) :
    (cond_52 && cond_53)? (`TRUE) :
    (cond_54 && cond_55)? (`TRUE) :
    (cond_219 && cond_220)? (`TRUE) :
    (cond_233 && cond_234)? (`TRUE) :
    (cond_233 && cond_235)? (`TRUE) :
    (cond_251 && cond_252)? (`TRUE) :
    (cond_253 && cond_254 && cond_255)? (`TRUE) :
    (cond_257 && cond_254 && cond_258)? (`TRUE) :
    (cond_260 && cond_254 && cond_261)? (`TRUE) :
    (cond_292 && cond_293)? (`TRUE) :
    1'd0;
assign exe_glob_param_3_value =
    (cond_4 && cond_7)? ( glob_param_1) :
    (cond_11 && cond_13)? ( glob_param_1) :
    (cond_43 && ~cond_9)? ( glob_param_1) :
    (cond_44)? ( glob_param_1) :
    (cond_111 && ~cond_9)? ( glob_param_1) :
    (cond_112)? ( glob_param_1) :
    (cond_219 && cond_7)? ( glob_param_1) :
    (cond_283)? ( { 10'd0, exe_consumed, 1'd0, 1'd0, 16'd0 }) :
    (cond_286 && cond_289)? ( { 10'd0, exe_consumed, 1'd0, 1'd0, 16'd0 }) :
    (cond_286 && cond_288)? ( { 10'd0, exe_consumed, 1'd0, exc_push_error, exc_error_code[15:0] }) :
    32'd0;
assign exe_glob_param_2_set =
    (cond_3)? (`TRUE) :
    (cond_153 && cond_154)? (`TRUE) :
    (cond_153 && ~cond_154)? (`TRUE) :
    (cond_155 && cond_154)? (`TRUE) :
    (cond_155 && ~cond_154)? (`TRUE) :
    (cond_172)? (`TRUE) :
    (cond_197 && cond_154)? (`TRUE) :
    (cond_197 && ~cond_154)? (`TRUE) :
    (cond_199 && cond_154)? (`TRUE) :
    (cond_199 && ~cond_154)? (`TRUE) :
    (cond_213)? (`TRUE) :
    (cond_263)? (`TRUE) :
    1'd0;
assign exe_trigger_np_fault =
    (cond_27 && cond_29)? (`TRUE) :
    (cond_54 && cond_56)? (`TRUE) :
    (cond_164 && cond_29)? (`TRUE) :
    (cond_257 && cond_254 && cond_259)? (`TRUE) :
    (cond_260 && cond_254 && cond_259)? (`TRUE) :
    (cond_280 && cond_282)? (`TRUE) :
    (cond_286 && cond_29)? (`TRUE) :
    (cond_290 && cond_29)? (`TRUE) :
    1'd0;
assign offset_iret_glob_param_4 =
    (cond_45)? (`TRUE) :
    (cond_113)? (   exe_decoder[0] == 1'b1) :
    1'd0;
assign tlbcheck_do =
    (cond_236)? (`TRUE) :
    (cond_239)? (`TRUE) :
    (cond_240)? (`TRUE) :
    (cond_241)? (`TRUE) :
    (cond_242)? (`TRUE) :
    (cond_243)? (`TRUE) :
    1'd0;
assign exe_buffer_shift_word =
    (cond_249 && cond_7)? (  exe_cmdex >  `CMDEX_task_switch_3_STEP_8) :
    1'd0;
assign offset_new_stack_minus =
    (cond_292 && cond_284)? (`TRUE) :
    1'd0;
assign wbinvddata_do =
    (cond_88)? ( ~(e_wbinvd_data_done)) :
    1'd0;
assign exe_cmpxchg_switch =
    (cond_76)? (`TRUE) :
    1'd0;
assign exe_branch =
    (cond_95 && ~cond_62)? (         exe_condition) :
    (cond_118 && ~cond_119)? (         exe_jecxz_condition) :
    (cond_144 && ~cond_145)? (         exe_cmd_loop_condition) :
    1'd0;
assign exe_result_push =
    (cond_18)? ( exe_push_eflags) :
    (cond_20)? ( { 16'd0, cs[15:0] }) :
    (cond_21)? ( exe_eip) :
    (cond_30)? ( exe_push_eflags) :
    (cond_32)? ( { 16'd0, cs[15:0] }) :
    (cond_33)? ( exe_eip) :
    (cond_34)? ( { 16'd0, exc_error_code[15:0] }) :
    (cond_35)? (    (exe_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_4)?  { 16'd0, gs } : (exe_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_5)?  { 16'd0, fs } : (exe_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_6)?  { 16'd0, ds } : (exe_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_7)?  { 16'd0, es } : (exe_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_8)?  { 16'd0, ss } : esp) :
    (cond_36)? ( exe_push_eflags) :
    (cond_37)? ( { 16'd0, cs[15:0] }) :
    (cond_38)? ( exe_eip) :
    (cond_39)? ( { 16'd0, exc_error_code[15:0] }) :
    (cond_64 && cond_65)? ( wr_esp_prev) :
    (cond_64 && ~cond_65)? ( src) :
    (cond_68 && cond_69)? ( { {24{src[7]}}, src[7:0] }) :
    (cond_68 && ~cond_69)? ( src) :
    (cond_84)? ( { 16'd0, e_seg_by_cmdex }) :
    (cond_97)? ( src) :
    (cond_103)? ( src) :
    (cond_117)? ( src) :
    (cond_178)? ( exe_pushf_eflags) :
    (cond_184)? ( src) :
    (cond_197 && cond_198)? ( exe_eip) :
    (cond_199)? ( exe_eip) :
    (cond_203)? ( { 16'd0, cs[15:0] }) :
    (cond_205)? ( exe_eip) :
    (cond_209)? ( { 16'd0, cs[15:0] }) :
    (cond_210)? ( exe_eip) :
    (cond_214)? ( { 16'd0, cs[15:0] }) :
    (cond_215)? ( exe_eip) :
    (cond_221 && cond_222)? ( esp) :
    (cond_221 && ~cond_222)? ( { 16'd0, esp[15:0] }) :
    (cond_223)? ( glob_param_5) :
    (cond_224)? ( { 16'd0, cs[15:0] }) :
    (cond_225 && cond_226)? ( exe_eip) :
    (cond_225 && ~cond_226)? ( { 16'd0, exe_eip[15:0] }) :
    (cond_244)? ( exe_push_eflags) :
    (cond_262)? ( { 16'd0, glob_param_3[15:0] }) :
    (cond_266)? ( src) :
    (cond_276)? ( src) :
    (cond_278)? ( src) :
    (cond_292 && cond_284)? ( { 16'd0, ss[15:0] }) :
    (cond_296)? ( ebp) :
    (cond_298 && cond_299)? ( exe_buffer) :
    (cond_298 && ~cond_299)? ( src) :
    32'd0;
assign offset_new_stack_continue =
    (cond_35)? (`TRUE) :
    (cond_36)? (`TRUE) :
    (cond_37)? (`TRUE) :
    (cond_38)? (`TRUE) :
    (cond_39)? (`TRUE) :
    (cond_221)? (`TRUE) :
    (cond_223)? (`TRUE) :
    (cond_224)? (`TRUE) :
    (cond_225)? (`TRUE) :
    1'd0;
assign exe_eip_from_glob_param_2 =
    (cond_10)? (`TRUE) :
    (cond_14)? (`TRUE) :
    (cond_24)? (`TRUE) :
    (cond_42)? (`TRUE) :
    (cond_45)? (`TRUE) :
    (cond_51)? (`TRUE) :
    (cond_71)? (`TRUE) :
    (cond_113)? (`TRUE) :
    (cond_114)? (`TRUE) :
    (cond_157)? (`TRUE) :
    (cond_161)? (`TRUE) :
    (cond_163)? (`TRUE) :
    (cond_167)? (`TRUE) :
    (cond_200)? (`TRUE) :
    (cond_208)? (`TRUE) :
    (cond_212)? (`TRUE) :
    (cond_218)? (`TRUE) :
    (cond_229)? (`TRUE) :
    (cond_263)? (`TRUE) :
    1'd0;
assign exe_glob_descriptor_2_value =
    (cond_4 && cond_7)? ( glob_descriptor) :
    (cond_11 && cond_13)? ( glob_descriptor) :
    (cond_43 && ~cond_9)? ( glob_descriptor) :
    (cond_44)? ( glob_descriptor) :
    (cond_111 && ~cond_9)? ( glob_descriptor) :
    (cond_112)? ( glob_descriptor) :
    (cond_209)? ( glob_descriptor) :
    (cond_219 && cond_7)? ( glob_descriptor) :
    64'd0;
assign exe_glob_param_3_set =
    (cond_4 && cond_7)? (`TRUE) :
    (cond_11 && cond_13)? (`TRUE) :
    (cond_43 && ~cond_9)? (`TRUE) :
    (cond_44)? (`TRUE) :
    (cond_111 && ~cond_9)? (`TRUE) :
    (cond_112)? ( exe_ready) :
    (cond_219 && cond_7)? (`TRUE) :
    (cond_283)? (`TRUE) :
    (cond_286 && cond_289)? (`TRUE) :
    (cond_286 && cond_288)? (`TRUE) :
    1'd0;
assign exe_glob_descriptor_value =
    (cond_11 && cond_13)? ( glob_descriptor_2) :
    (cond_43 && ~cond_9)? ( glob_descriptor_2) :
    (cond_44)? ( glob_descriptor_2) :
    (cond_111 && ~cond_9)? ( glob_descriptor_2) :
    (cond_112)? ( glob_descriptor_2) :
    (cond_209)? (  ss_cache) :
    (cond_211 && ~cond_12)? ( glob_descriptor_2) :
    (cond_228 && cond_7)? ( glob_descriptor_2) :
    64'd0;
assign tlbflushsingle_address =
    (cond_169)? ( exe_linear) :
    32'd0;
assign offset_esp =
    (cond_195)? (`TRUE) :
    1'd0;
