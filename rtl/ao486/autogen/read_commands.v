wire rd_imul_modregrm_mutex_busy;
assign rd_imul_modregrm_mutex_busy = (  rd_decoder[3]  && rd_mutex_busy_modregrm_reg) || (~(rd_decoder[3]) && rd_mutex_busy_eax);

wire rd_arith_modregrm_to_rm;
wire rd_arith_modregrm_to_reg;
assign rd_arith_modregrm_to_rm = ~(rd_decoder[1]);
assign rd_arith_modregrm_to_reg= rd_decoder[1];

wire rd_io_allow_1_fault;
wire rd_io_allow_2_fault;
assign rd_io_allow_1_fault = rd_cmd == `CMD_io_allow && rd_cmdex == `CMDEX_io_allow_1 && (   ~(tr_cache_valid) || (tr_cache[`DESC_BITS_TYPE] != `DESC_TSS_AVAIL_386 && tr_cache[`DESC_BITS_TYPE] != `DESC_TSS_BUSY_386) || tr_limit < 32'd103 );
assign rd_io_allow_2_fault = rd_cmd == `CMD_io_allow && rd_cmdex == `CMDEX_io_allow_2 && ({ 16'd0, rd_memory_last[15:0] } + { 16'd0, 3'd0, glob_param_1[15:3] }) >= tr_limit;
assign rd_io_allow_fault = rd_io_allow_1_fault || rd_io_allow_2_fault;

wire [4:0] rd_call_gate_param;
assign rd_call_gate_param = glob_param_3[24:20] - 5'd1;

wire rd_in_condition;
assign rd_in_condition = (rd_mutex_busy_active && (rd_cmdex == `CMDEX_IN_imm || rd_cmdex == `CMDEX_IN_dx) && ~(io_allow_check_needed)) || (rd_cmdex == `CMDEX_IN_dx && rd_mutex_busy_edx);

wire [31:0] rd_task_switch_linear_next;
reg [31:0] rd_task_switch_linear_reg;
assign rd_task_switch_linear_next = (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? rd_task_switch_linear_reg + 32'd2 : rd_task_switch_linear_reg + 32'd4;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0)                                                               rd_task_switch_linear_reg <= 32'd0; else if(rd_cmd == `CMD_task_switch && rd_cmdex == `CMDEX_task_switch_STEP_12)   rd_task_switch_linear_reg <= rd_system_linear; else if(rd_ready)                                                               rd_task_switch_linear_reg <= rd_task_switch_linear_next;
end

wire [31:0] rd_offset_for_esp_from_tss;
wire [31:0] rd_offset_for_ss_from_tss;
wire [31:0] r_limit_for_ss_esp_from_tss;
wire        rd_ss_esp_from_tss_386;
assign rd_ss_esp_from_tss_386 = tr_cache[`DESC_BITS_TYPE] == `DESC_TSS_AVAIL_386 || tr_cache[`DESC_BITS_TYPE] == `DESC_TSS_BUSY_386;
assign r_limit_for_ss_esp_from_tss = (rd_ss_esp_from_tss_386)?   { 27'd0, glob_descriptor[`DESC_BITS_DPL], 3'd0 } + 32'd11 : { 28'd0, glob_descriptor[`DESC_BITS_DPL], 2'd0 } + 32'd5;
assign rd_offset_for_ss_from_tss = (rd_ss_esp_from_tss_386)?   { 27'd0, glob_descriptor[`DESC_BITS_DPL], 3'd0 } + 32'd8 : { 28'd0, glob_descriptor[`DESC_BITS_DPL], 2'd0 } + 32'd4;
assign rd_offset_for_esp_from_tss = (rd_ss_esp_from_tss_386)?   { 27'd0, glob_descriptor[`DESC_BITS_DPL], 3'd0 } + 32'd4 : { 28'd0, glob_descriptor[`DESC_BITS_DPL], 2'd0 } + 32'd2;
assign rd_ss_esp_from_tss_fault = (   (rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_0) || (rd_cmd == `CMD_int_2  && rd_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_0) ) && r_limit_for_ss_esp_from_tss > tr_limit;

//======================================================== conditions
wire cond_0 = rd_cmd == `CMD_XCHG && rd_cmdex == `CMDEX_XCHG_implicit;
wire cond_1 = rd_mutex_busy_implicit_reg || rd_mutex_busy_eax;
wire cond_2 = rd_cmd == `CMD_XCHG && rd_cmdex == `CMDEX_XCHG_modregrm;
wire cond_3 = rd_modregrm_mod == 2'b11;
wire cond_4 = rd_mutex_busy_modregrm_reg || rd_mutex_busy_modregrm_rm;
wire cond_5 = rd_modregrm_mod != 2'b11;
wire cond_6 = rd_mutex_busy_modregrm_reg || rd_mutex_busy_memory;
wire cond_7 = ~(read_for_rd_ready);
wire cond_8 = rd_cmd == `CMD_XCHG && rd_cmdex == `CMDEX_XCHG_modregrm_LAST;
wire cond_9 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_task_gate_STEP_0;
wire cond_10 = rd_mutex_busy_active;
wire cond_11 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_task_gate_STEP_1;
wire cond_12 = glob_param_1[`SELECTOR_BIT_TI] == 1'b0;
wire cond_13 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_int_trap_gate_STEP_1;
wire cond_14 = glob_param_1[15:2] != 14'd0;
wire cond_15 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_real_STEP_3;
wire cond_16 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_real_STEP_4;
wire cond_17 = rd_cmd == `CMD_int && rd_cmdex == `CMDEX_int_protected_STEP_1;
wire cond_18 = rd_cmd == `CMD_IRET && rd_cmdex <= `CMDEX_IRET_real_v86_STEP_2;
wire cond_19 = rd_cmdex >`CMDEX_IRET_real_v86_STEP_0;
wire cond_20 = rd_cmdex == `CMDEX_IRET_real_v86_STEP_0;
wire cond_21 = rd_cmdex == `CMDEX_IRET_real_v86_STEP_1;
wire cond_22 = rd_cmdex == `CMDEX_IRET_real_v86_STEP_2;
wire cond_23 = rd_mutex_busy_memory || (rd_mutex_busy_eflags && v8086_mode);
wire cond_24 = ~(v8086_mode) || iopl == 2'd3;
wire cond_25 = rd_cmd == `CMD_IRET && rd_cmdex == `CMDEX_IRET_protected_STEP_0;
wire cond_26 = rd_mutex_busy_memory || rd_mutex_busy_eflags;
wire cond_27 = rd_cmd == `CMD_IRET && rd_cmdex == `CMDEX_IRET_task_switch_STEP_0;
wire cond_28 = rd_cmd == `CMD_IRET && rd_cmdex == `CMDEX_IRET_task_switch_STEP_1;
wire cond_29 = ~(rd_descriptor_not_in_limits);
wire cond_30 = rd_cmd == `CMD_IRET && rd_cmdex >= `CMDEX_IRET_protected_STEP_1 && rd_cmdex <= `CMDEX_IRET_protected_STEP_3;
wire cond_31 = rd_cmdex == `CMDEX_IRET_protected_STEP_1;
wire cond_32 = rd_cmdex == `CMDEX_IRET_protected_STEP_2;
wire cond_33 = rd_cmdex == `CMDEX_IRET_protected_STEP_3;
wire cond_34 = rd_cmd == `CMD_IRET && rd_cmdex >= `CMDEX_IRET_protected_to_v86_STEP_0;
wire cond_35 = rd_cmdex == `CMDEX_IRET_protected_to_v86_STEP_0;
wire cond_36 = rd_cmd == `CMD_IRET_2 && rd_cmdex == `CMDEX_IRET_2_protected_outer_STEP_0;
wire cond_37 = rd_cmd == `CMD_IRET_2 && rd_cmdex >= `CMDEX_IRET_2_protected_outer_STEP_1 && rd_cmdex <= `CMDEX_IRET_2_protected_outer_STEP_3;
wire cond_38 = rd_cmdex == `CMDEX_IRET_2_protected_outer_STEP_1;
wire cond_39 = rd_cmdex == `CMDEX_IRET_2_protected_outer_STEP_2;
wire cond_40 = rd_cmdex == `CMDEX_IRET_2_protected_outer_STEP_3;
wire cond_41 = rd_cmd == `CMD_IRET_2 && rd_cmdex >= `CMDEX_IRET_2_protected_outer_STEP_6;
wire cond_42 = rd_cmd == `CMD_CLI || rd_cmd == `CMD_STI;
wire cond_43 = rd_cmd == `CMD_PUSHA;
wire cond_44 = (rd_cmdex == `CMDEX_PUSHA_STEP_0 && rd_mutex_busy_eax) || (rd_cmdex == `CMDEX_PUSHA_STEP_1 && rd_mutex_busy_ecx) || (rd_cmdex == `CMDEX_PUSHA_STEP_2 && rd_mutex_busy_edx);
wire cond_45 = rd_cmd == `CMD_SCAS;
wire cond_46 = rd_mutex_busy_memory || (rd_mutex_busy_ecx && rd_prefix_group_1_rep != 2'd0);
wire cond_47 = ~(rd_string_ignore);
wire cond_48 = rd_cmd == `CMD_PUSH && (rd_cmdex == `CMDEX_PUSH_immediate || rd_cmdex == `CMDEX_PUSH_immediate_se);
wire cond_49 = rd_cmd == `CMD_PUSH && rd_cmdex == `CMDEX_PUSH_implicit;
wire cond_50 = rd_mutex_busy_implicit_reg;
wire cond_51 = rd_cmd == `CMD_PUSH && rd_cmdex == `CMDEX_PUSH_modregrm;
wire cond_52 = rd_mutex_busy_modregrm_rm;
wire cond_53 = rd_mutex_busy_memory;
wire cond_54 = rd_cmd == `CMD_ARPL;
wire cond_55 = rd_mutex_busy_modregrm_rm || rd_mutex_busy_modregrm_reg;
wire cond_56 = rd_mutex_busy_memory || rd_mutex_busy_modregrm_reg;
wire cond_57 = rd_cmd == `CMD_RET_near && rd_cmdex != `CMDEX_RET_near_LAST;
wire cond_58 = (rd_cmd == `CMD_MOV_to_seg || rd_cmd == `CMD_LLDT || rd_cmd == `CMD_LTR) && rd_cmdex == `CMDEX_MOV_to_seg_LLDT_LTR_STEP_1;
wire cond_59 = rd_cmd == `CMD_MOV_to_seg || cpl == 2'd0;
wire cond_60 = rd_cmd == `CMD_MOV_to_seg;
wire cond_61 = rd_cmd == `CMD_LLDT;
wire cond_62 = rd_cmd == `CMD_LTR;
wire cond_63 = rd_cmd == `CMD_CPUID;
wire cond_64 = rd_mutex_busy_eax;
wire cond_65 = rd_cmd == `CMD_CMPXCHG;
wire cond_66 = rd_cmd == `CMD_LODS;
wire cond_67 = rd_cmd == `CMD_SETcc;
wire cond_68 = ~(write_virtual_check_ready);
wire cond_69 = rd_cmd == `CMD_Shift && rd_cmdex != `CMDEX_Shift_implicit;
wire cond_70 = rd_cmd == `CMD_Shift && rd_cmdex == `CMDEX_Shift_implicit;
wire cond_71 = rd_mutex_busy_modregrm_rm || rd_mutex_busy_ecx;
wire cond_72 = rd_mutex_busy_memory || rd_mutex_busy_ecx;
wire cond_73 = rd_cmd == `CMD_INC_DEC && { rd_cmdex[3:1], 1'b0 } == `CMDEX_INC_DEC_modregrm;
wire cond_74 = rd_cmd == `CMD_INC_DEC && { rd_cmdex[3:1], 1'b0 } == `CMDEX_INC_DEC_implicit;
wire cond_75 = rd_cmd == `CMD_PUSH_MOV_SEG && { rd_cmdex[3], 3'b0 } == `CMDEX_PUSH_MOV_SEG_implicit;
wire cond_76 = rd_cmd == `CMD_PUSH_MOV_SEG && { rd_cmdex[3], 3'b0 } == `CMDEX_PUSH_MOV_SEG_modregrm;
wire cond_77 = (rd_cmd == `CMD_SGDT || rd_cmd == `CMD_SIDT);
wire cond_78 = rd_cmdex == `CMDEX_SGDT_SIDT_STEP_1;
wire cond_79 = rd_cmdex == `CMDEX_SGDT_SIDT_STEP_2;
wire cond_80 = rd_cmd == `CMD_POPF && rd_cmdex == `CMDEX_POPF_STEP_0;
wire cond_81 = rd_cmd == `CMD_INS && (rd_cmdex == `CMDEX_INS_real_1 || rd_cmdex == `CMDEX_INS_protected_1);
wire cond_82 = rd_mutex_busy_ecx && rd_prefix_group_1_rep != 2'd0;
wire cond_83 = ~(rd_string_ignore) && ~(io_allow_check_needed && rd_cmdex == `CMDEX_INS_real_1);
wire cond_84 = rd_cmd == `CMD_INS && (rd_cmdex == `CMDEX_INS_real_2 || rd_cmdex == `CMDEX_INS_protected_2);
wire cond_85 = rd_mutex_busy_edx || (rd_mutex_busy_ecx && rd_prefix_group_1_rep != 2'd0);
wire cond_86 = ~(rd_io_ready);
wire cond_87 = rd_cmd == `CMD_CLC || rd_cmd == `CMD_CMC || rd_cmd == `CMD_CLD || rd_cmd == `CMD_STC || rd_cmd == `CMD_STD || rd_cmd == `CMD_SAHF;
wire cond_88 = rd_cmd == `CMD_IMUL && rd_cmdex == `CMDEX_IMUL_modregrm_imm;
wire cond_89 = rd_decoder[1:0] == 2'b11;
wire cond_90 = rd_cmd == `CMD_IMUL && rd_cmdex == `CMDEX_IMUL_modregrm;
wire cond_91 = rd_imul_modregrm_mutex_busy || rd_mutex_busy_modregrm_rm;
wire cond_92 = rd_imul_modregrm_mutex_busy || rd_mutex_busy_memory;
wire cond_93 = rd_cmd == `CMD_LEA;
wire cond_94 = ~(rd_address_effective_ready);
wire cond_95 = rd_cmd == `CMD_MOVSX || rd_cmd == `CMD_MOVZX;
wire cond_96 = rd_cmd == `CMD_MOVS;
wire cond_97 = rd_cmd == `CMD_RET_far && rd_cmdex == `CMDEX_RET_far_outer_STEP_3;
wire cond_98 = rd_cmd == `CMD_RET_far && rd_cmdex == `CMDEX_RET_far_STEP_1;
wire cond_99 = real_mode || v8086_mode;
wire cond_100 = protected_mode;
wire cond_101 = rd_cmd == `CMD_RET_far && rd_cmdex == `CMDEX_RET_far_STEP_2;
wire cond_102 = rd_cmd == `CMD_RET_far && rd_cmdex == `CMDEX_RET_far_outer_STEP_4;
wire cond_103 = rd_cmd == `CMD_AAA || rd_cmd == `CMD_AAS || rd_cmd == `CMD_DAA || rd_cmd == `CMD_DAS;
wire cond_104 = rd_cmd == `CMD_STOS;
wire cond_105 = rd_mutex_busy_eax || (rd_mutex_busy_ecx && rd_prefix_group_1_rep != 2'd0);
wire cond_106 = rd_cmd == `CMD_XLAT;
wire cond_107 = rd_cmd == `CMD_BOUND && rd_cmdex == `CMDEX_BOUND_STEP_FIRST;
wire cond_108 = rd_cmd == `CMD_BOUND && rd_cmdex == `CMDEX_BOUND_STEP_LAST;
wire cond_109 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_memoffset;
wire cond_110 = ~(rd_decoder[1]);
wire cond_111 = rd_mutex_busy_eax || ~(write_virtual_check_ready);
wire cond_112 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_modregrm && rd_decoder[1];
wire cond_113 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_modregrm && ~(rd_decoder[1]);
wire cond_114 = rd_mutex_busy_modregrm_reg;
wire cond_115 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_modregrm_imm;
wire cond_116 = rd_cmd == `CMD_MOV && rd_cmdex == `CMDEX_MOV_immediate;
wire cond_117 = rd_cmd == `CMD_MUL;
wire cond_118 = rd_mutex_busy_eax || rd_mutex_busy_modregrm_rm;
wire cond_119 = rd_mutex_busy_eax || rd_mutex_busy_memory;
wire cond_120 = rd_cmd == `CMD_debug_reg && rd_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0;
wire cond_121 = rd_cmd == `CMD_debug_reg && rd_cmdex == `CMDEX_debug_reg_MOV_load_STEP_0;
wire cond_122 = rd_cmd == `CMD_control_reg && rd_cmdex == `CMDEX_control_reg_SMSW_STEP_0;
wire cond_123 = rd_cmd == `CMD_control_reg && rd_cmdex == `CMDEX_control_reg_LMSW_STEP_0;
wire cond_124 = cpl == 2'd0;
wire cond_125 = rd_cmd == `CMD_control_reg && rd_cmdex == `CMDEX_control_reg_MOV_load_STEP_0;
wire cond_126 = rd_cmd == `CMD_control_reg && rd_cmdex == `CMDEX_control_reg_MOV_store_STEP_0;
wire cond_127 = rd_cmd == `CMD_LOOP;
wire cond_128 = rd_cmd == `CMD_NOT;
wire cond_129 = (rd_cmd == `CMD_LGDT || rd_cmd == `CMD_LIDT) && (rd_cmdex == `CMDEX_LGDT_LIDT_STEP_1 || rd_cmdex == `CMDEX_LGDT_LIDT_STEP_2);
wire cond_130 = rd_cmdex == `CMDEX_LGDT_LIDT_STEP_1;
wire cond_131 = rd_cmdex == `CMDEX_LGDT_LIDT_STEP_2;
wire cond_132 = { rd_cmd[6:2], 2'd0 } == `CMD_BTx;
wire cond_133 = rd_mutex_busy_modregrm_rm || (rd_cmdex == `CMDEX_BTx_modregrm && rd_mutex_busy_modregrm_reg);
wire cond_134 = rd_mutex_busy_memory || (rd_cmdex == `CMDEX_BTx_modregrm && rd_mutex_busy_modregrm_reg);
wire cond_135 = rd_cmd == `CMD_SALC && rd_cmdex == `CMDEX_SALC_STEP_0;
wire cond_136 = rd_cmd == `CMD_LAHF || rd_cmd == `CMD_CBW || rd_cmd == `CMD_CWD;
wire cond_137 = { rd_cmd[6:1], 1'd0 } == `CMD_BSx;
wire cond_138 = rd_cmd == `CMD_JMP && rd_cmdex == `CMDEX_JMP_Jv_STEP_0;
wire cond_139 = rd_cmd == `CMD_JMP  && rd_cmdex == `CMDEX_JMP_Ap_STEP_1;
wire cond_140 = rd_cmd == `CMD_JMP_2 && rd_cmdex == `CMDEX_JMP_2_call_gate_STEP_0;
wire cond_141 = rd_cmd == `CMD_JMP_2 && rd_cmdex == `CMDEX_JMP_2_call_gate_STEP_1;
wire cond_142 = rd_cmd == `CMD_JMP  && rd_cmdex == `CMDEX_JMP_Ev_STEP_0;
wire cond_143 = rd_cmd == `CMD_JMP  && (rd_cmdex == `CMDEX_JMP_Ep_STEP_0  || rd_cmdex == `CMDEX_JMP_Ep_STEP_1);
wire cond_144 = rd_cmdex == `CMDEX_JMP_Ep_STEP_1;
wire cond_145 = rd_cmd == `CMD_JMP  && rd_cmdex == `CMDEX_JMP_Ap_STEP_0;
wire cond_146 = rd_cmd == `CMD_JMP && rd_cmdex == `CMDEX_JMP_protected_STEP_0;
wire cond_147 = rd_cmd == `CMD_JMP && rd_cmdex == `CMDEX_JMP_task_gate_STEP_0;
wire cond_148 = rd_cmd == `CMD_JMP && rd_cmdex == `CMDEX_JMP_task_gate_STEP_1;
wire cond_149 = rd_cmd == `CMD_INVLPG && rd_cmdex == `CMDEX_INVLPG_STEP_1;
wire cond_150 = (rd_cmd == `CMD_LAR || rd_cmd == `CMD_LSL || rd_cmd == `CMD_VERR || rd_cmd == `CMD_VERW) && rd_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_1;
wire cond_151 = (rd_cmd == `CMD_LAR || rd_cmd == `CMD_LSL || rd_cmd == `CMD_VERR || rd_cmd == `CMD_VERW) && rd_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_2;
wire cond_152 = ~(glob_param_1[15:2] == 14'd0) && ~(rd_descriptor_not_in_limits);
wire cond_153 = (rd_cmd == `CMD_LAR || rd_cmd == `CMD_LSL) && rd_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_LAST;
wire cond_154 = rd_cmd == `CMD_LAR;
wire cond_155 = exe_mutex[`MUTEX_ACTIVE_BIT];
wire cond_156 = glob_param_2[1:0] == 2'd0 && ((glob_param_2[2] == 1'd0 && rd_cmd == `CMD_LAR) || (glob_param_2[3] == 1'd0 && rd_cmd == `CMD_LSL));
wire cond_157 = (rd_cmd == `CMD_VERR || rd_cmd == `CMD_VERW) && rd_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_LAST;
wire cond_158 = glob_param_2[1:0] == 2'd0 && ((glob_param_2[4] == 1'd0 && rd_cmd == `CMD_VERR) || (glob_param_2[5] == 1'd0 && rd_cmd == `CMD_VERW));
wire cond_159 = { rd_cmd[6:3], 3'd0 } == `CMD_Arith && rd_cmdex == `CMDEX_Arith_modregrm;
wire cond_160 = rd_decoder[5:3] != 3'b111;
wire cond_161 = rd_decoder[5:3] != 3'b111 && rd_arith_modregrm_to_rm;
wire cond_162 = rd_decoder[5:3] != 3'b111 && rd_arith_modregrm_to_reg;
wire cond_163 = { rd_cmd[6:3], 3'd0 } == `CMD_Arith && rd_cmdex == `CMDEX_Arith_modregrm_imm;
wire cond_164 = rd_decoder[13:11] != 3'b111;
wire cond_165 = { rd_cmd[6:3], 3'd0 } == `CMD_Arith && rd_cmdex == `CMDEX_Arith_immediate;
wire cond_166 = rd_cmd == `CMD_PUSHF;
wire cond_167 = rd_cmd == `CMD_XADD && rd_cmdex == `CMDEX_XADD_FIRST;
wire cond_168 = rd_cmd == `CMD_XADD && rd_cmdex == `CMDEX_XADD_LAST;
wire cond_169 = rd_cmd == `CMD_POP_seg && rd_cmdex == `CMDEX_POP_seg_STEP_1;
wire cond_170 = rd_cmd == `CMD_NEG;
wire cond_171 = rd_cmd == `CMD_LEAVE;
wire cond_172 = rd_cmd == `CMD_POP && rd_cmdex == `CMDEX_POP_implicit;
wire cond_173 = rd_mutex_busy_memory || rd_mutex_busy_esp;
wire cond_174 = rd_cmd == `CMD_POP && rd_cmdex == `CMDEX_POP_modregrm_STEP_0;
wire cond_175 = rd_cmd == `CMD_POP && rd_cmdex == `CMDEX_POP_modregrm_STEP_1;
wire cond_176 = rd_cmd == `CMD_io_allow && rd_cmdex == `CMDEX_io_allow_1;
wire cond_177 = rd_io_allow_1_fault || rd_mutex_busy_active;
wire cond_178 = rd_cmd == `CMD_io_allow && rd_cmdex == `CMDEX_io_allow_2;
wire cond_179 = rd_io_allow_2_fault;
wire cond_180 = rd_cmd == `CMD_TEST && rd_cmdex == `CMDEX_TEST_modregrm;
wire cond_181 = rd_cmd == `CMD_TEST && rd_cmdex == `CMDEX_TEST_modregrm_imm;
wire cond_182 = rd_cmd == `CMD_TEST && rd_cmdex == `CMDEX_TEST_immediate;
wire cond_183 = { rd_cmd[6:1], 1'd0 } == `CMD_SHxD && rd_cmdex != `CMDEX_SHxD_implicit;
wire cond_184 = { rd_cmd[6:1], 1'd0 } == `CMD_SHxD && rd_cmdex == `CMDEX_SHxD_implicit;
wire cond_185 = rd_mutex_busy_modregrm_rm || rd_mutex_busy_ecx || rd_mutex_busy_modregrm_reg;
wire cond_186 = rd_mutex_busy_memory || rd_mutex_busy_ecx || rd_mutex_busy_modregrm_reg;
wire cond_187 = rd_cmd == `CMD_AAM || rd_cmd == `CMD_AAD;
wire cond_188 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_Ev_STEP_0;
wire cond_189 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_Jv_STEP_0;
wire cond_190 = rd_cmd == `CMD_CALL && (rd_cmdex == `CMDEX_CALL_Ep_STEP_0 || rd_cmdex == `CMDEX_CALL_Ep_STEP_1);
wire cond_191 = rd_cmdex == `CMDEX_CALL_Ep_STEP_1;
wire cond_192 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_Ap_STEP_0;
wire cond_193 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_Ap_STEP_1;
wire cond_194 = rd_cmd == `CMD_CALL && rd_cmdex == `CMDEX_CALL_protected_STEP_0;
wire cond_195 = rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_task_gate_STEP_0;
wire cond_196 = rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_task_gate_STEP_1;
wire cond_197 = rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_STEP_1;
wire cond_198 = rd_cmd == `CMD_CALL_3 && (rd_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_4 || rd_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_5);
wire cond_199 = ~(glob_param_3[19]);
wire cond_200 = glob_param_3[19];
wire cond_201 = rd_ready;
wire cond_202 = rd_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_4;
wire cond_203 = rd_cmd == `CMD_IN && rd_cmdex != `CMDEX_IN_idle;
wire cond_204 = rd_in_condition;
wire cond_205 = ~(io_allow_check_needed) || rd_cmdex == `CMDEX_IN_protected;
wire cond_206 = rd_cmd == `CMD_task_switch && rd_cmdex == `CMDEX_task_switch_STEP_6;
wire cond_207 = glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_JUMP || glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_IRET;
wire cond_208 = rd_cmd == `CMD_task_switch && rd_cmdex == `CMDEX_task_switch_STEP_9;
wire cond_209 = rd_cmd == `CMD_task_switch_2 && rd_cmdex <= `CMDEX_task_switch_2_STEP_7;
wire cond_210 = rd_cmd == `CMD_task_switch_2 && rd_cmdex == `CMDEX_task_switch_2_STEP_13;
wire cond_211 = rd_cmd == `CMD_task_switch && rd_cmdex >= `CMDEX_task_switch_STEP_12 && rd_cmdex <= `CMDEX_task_switch_STEP_14;
wire cond_212 = rd_cmdex == `CMDEX_task_switch_STEP_12 && glob_descriptor[`DESC_BITS_TYPE] <= 4'd3;
wire cond_213 = rd_cmdex == `CMDEX_task_switch_STEP_12 && glob_descriptor[`DESC_BITS_TYPE] >  4'd3;
wire cond_214 = rd_cmdex == `CMDEX_task_switch_STEP_13 || rd_cmdex == `CMDEX_task_switch_STEP_14;
wire cond_215 = rd_cmdex != `CMDEX_task_switch_STEP_12 || (glob_descriptor[`DESC_BITS_TYPE] > 4'd3 && cr0_pg);
wire cond_216 = rd_cmd == `CMD_task_switch_3;
wire cond_217 = rd_cmdex <= `CMDEX_task_switch_3_STEP_12 || glob_descriptor[`DESC_BITS_TYPE] > 4'd3;
wire cond_218 = rd_cmd == `CMD_task_switch_4 && rd_cmdex == `CMDEX_task_switch_4_STEP_0;
wire cond_219 = glob_param_1[`TASK_SWITCH_SOURCE_BITS] != `TASK_SWITCH_FROM_IRET;
wire cond_220 = rd_cmd == `CMD_task_switch_4 && rd_cmdex == `CMDEX_task_switch_4_STEP_2;
wire cond_221 = glob_param_1[`SELECTOR_BIT_TI] == 1'b0 && glob_param_1[15:2] != 14'd0 && ~(rd_descriptor_not_in_limits);
wire cond_222 = rd_cmd == `CMD_task_switch_4 && rd_cmdex >= `CMDEX_task_switch_4_STEP_3 && rd_cmdex <= `CMDEX_task_switch_4_STEP_8;
wire cond_223 = v8086_mode;
wire cond_224 = glob_param_1[15:2] != 14'd0 && ~(rd_descriptor_not_in_limits);
wire cond_225 = rd_cmd == `CMD_POPA;
wire cond_226 = rd_cmdex[2:0] > 3'd0;
wire cond_227 = rd_cmdex[2:0] == 3'd7;
wire cond_228 = rd_cmd == `CMD_OUTS;
wire cond_229 = ~(rd_string_ignore) && ~(io_allow_check_needed && rd_cmdex == `CMDEX_OUTS_first);
wire cond_230 = rd_cmd == `CMD_LxS && rd_cmdex == `CMDEX_LxS_STEP_1;
wire cond_231 = ~(rd_address_effective_ready) || rd_mutex_busy_memory;
wire cond_232 = rd_operand_16bit;
wire cond_233 = rd_cmd == `CMD_LxS && rd_cmdex == `CMDEX_LxS_STEP_2;
wire cond_234 = rd_operand_32bit;
wire cond_235 = rd_cmd == `CMD_LxS && rd_cmdex == `CMDEX_LxS_STEP_3;
wire cond_236 = rd_cmd == `CMD_LxS && rd_cmdex == `CMDEX_LxS_STEP_LAST;
wire cond_237 = rd_cmd == `CMD_IDIV || rd_cmd == `CMD_DIV;
wire cond_238 = rd_mutex_busy_eax || (rd_decoder[0] && rd_mutex_busy_edx) || rd_mutex_busy_modregrm_rm;
wire cond_239 = rd_mutex_busy_eax || (rd_decoder[0] && rd_mutex_busy_edx) || rd_mutex_busy_memory;
wire cond_240 = rd_cmd == `CMD_load_seg && rd_cmdex == `CMDEX_load_seg_STEP_1;
wire cond_241 = real_mode;
wire cond_242 = rd_cmd == `CMD_load_seg && rd_cmdex == `CMDEX_load_seg_STEP_2;
wire cond_243 = ~(protected_mode && glob_param_1[15:2] == 14'd0);
wire cond_244 = rd_cmd == `CMD_BSWAP;
wire cond_245 = rd_cmd == `CMD_OUT;
wire cond_246 = rd_cmd == `CMD_INT_INTO && rd_cmdex == `CMDEX_INT_INTO_INTO_STEP_0;
wire cond_247 = rd_mutex_busy_eflags;
wire cond_248 =  (rd_cmd == `CMD_int_2  && rd_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_0) || (rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_0) ;
wire cond_249 = rd_ss_esp_from_tss_fault;
wire cond_250 =  (rd_cmd == `CMD_int_2 && rd_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_1) || (rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_1) ;
wire cond_251 =  (rd_cmd == `CMD_int_2 && rd_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_2) || (rd_cmd == `CMD_CALL_2 && rd_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_2) ;
wire cond_252 = rd_cmd == `CMD_CMPS && rd_cmdex == `CMDEX_CMPS_FIRST;
wire cond_253 = rd_cmd == `CMD_CMPS && rd_cmdex == `CMDEX_CMPS_LAST;
wire cond_254 = rd_cmd == `CMD_ENTER && rd_cmdex == `CMDEX_ENTER_FIRST;
wire cond_255 = rd_mutex_busy_ebp;
wire cond_256 = rd_cmd == `CMD_ENTER && rd_cmdex == `CMDEX_ENTER_LAST;
wire cond_257 = rd_cmd == `CMD_ENTER && rd_cmdex == `CMDEX_ENTER_PUSH;
wire cond_258 = rd_cmd == `CMD_ENTER && rd_cmdex == `CMDEX_ENTER_LOOP;
//======================================================== saves
//======================================================== always
//======================================================== sets
assign rd_dst_is_implicit_reg =
    (cond_0)? (`TRUE) :
    (cond_74)? (`TRUE) :
    (cond_116)? (`TRUE) :
    (cond_172)? (`TRUE) :
    (cond_244)? (`TRUE) :
    1'd0;
assign rd_req_ebp =
    (cond_171 && ~cond_53)? (`TRUE) :
    (cond_256)? (`TRUE) :
    1'd0;
assign rd_req_rm =
    (cond_8 && cond_3)? (`TRUE) :
    (cond_54 && cond_3)? (`TRUE) :
    (cond_65 && cond_3 && ~cond_4)? (`TRUE) :
    (cond_67 && cond_3)? (`TRUE) :
    (cond_69 && cond_3)? (`TRUE) :
    (cond_70 && cond_3)? (`TRUE) :
    (cond_73 && cond_3 && ~cond_52)? (`TRUE) :
    (cond_76 && cond_3)? (`TRUE) :
    (cond_113 && cond_3)? (`TRUE) :
    (cond_115 && cond_3)? (`TRUE) :
    (cond_120)? (`TRUE) :
    (cond_122 && cond_3)? (`TRUE) :
    (cond_126)? (`TRUE) :
    (cond_128 && cond_3)? (`TRUE) :
    (cond_132 && cond_3)? ( rd_cmd[1:0] != 2'd0) :
    (cond_159 && cond_3 && cond_160)? (  rd_arith_modregrm_to_rm) :
    (cond_163 && cond_3 && cond_164)? (`TRUE) :
    (cond_168)? (      rd_modregrm_mod == 2'b11) :
    (cond_170 && cond_3)? (`TRUE) :
    (cond_175 && cond_3)? (`TRUE) :
    (cond_183 && cond_3)? (`TRUE) :
    (cond_184 && cond_3)? (`TRUE) :
    1'd0;
assign rd_glob_param_5_set =
    (cond_37 && cond_39)? (`TRUE) :
    (cond_198 && ~cond_10)? (`TRUE) :
    (cond_251 && ~cond_10 && cond_29)? (`TRUE) :
    (cond_251 && ~cond_10 && ~cond_29)? (`TRUE) :
    1'd0;
assign rd_glob_param_1_value =
    (cond_9 && ~cond_10)? ( { 16'd0, glob_descriptor[31:16] }) :
    (cond_16)? ( { 13'd0, `SEGMENT_CS, read_4[15:0] }) :
    (cond_18 && cond_21)? ( { 13'd0, `SEGMENT_CS, read_4[15:0] }) :
    (cond_27)? ( { 14'd0, `TASK_SWITCH_FROM_IRET, read_4[15:0] }) :
    (cond_30 && cond_32)? ( { `MC_PARAM_1_FLAG_NO_WRITE, `SEGMENT_CS, read_4[15:0] }) :
    (cond_36)? ( { `MC_PARAM_1_FLAG_NP_NOT_SS | `MC_PARAM_1_FLAG_CPL_FROM_PARAM_3, `SEGMENT_SS, read_4[15:0] }) :
    (cond_58 && cond_59 && cond_3 && cond_60)? ( { 13'd0, rd_decoder[13:11], dst_wire[15:0] }) :
    (cond_58 && cond_59 && cond_3 && cond_61)? ( { 13'd0, `SEGMENT_LDT, dst_wire[15:0] }) :
    (cond_58 && cond_59 && cond_3 && cond_62)? ( { 13'd0, `SEGMENT_TR, dst_wire[15:0] }) :
    (cond_58 && cond_59 && cond_5 && ~cond_53 && cond_60)? ( { 13'd0, rd_decoder[13:11], read_4[15:0] }) :
    (cond_58 && cond_59 && cond_5 && ~cond_53 && cond_61)? ( { 13'd0, `SEGMENT_LDT, read_4[15:0] }) :
    (cond_58 && cond_59 && cond_5 && ~cond_53 && cond_62)? ( { 13'd0, `SEGMENT_TR, read_4[15:0] }) :
    (cond_97)? ( { `MC_PARAM_1_FLAG_CPL_FROM_PARAM_3, `SEGMENT_SS, read_4[15:0] }) :
    (cond_98 && ~cond_53 && cond_100)? ( { `MC_PARAM_1_FLAG_NO_WRITE, `SEGMENT_CS, read_4[15:0] }) :
    (cond_101 && ~cond_53 && cond_99)? ( { `MC_PARAM_1_FLAG_NO_WRITE, `SEGMENT_CS, read_4[15:0] }) :
    (cond_140 && ~cond_10)? ( { 13'd0, `SEGMENT_CS, glob_descriptor[31:16] }) :
    (cond_147 && ~cond_10)? ( { 16'd0, glob_descriptor[31:16] }) :
    (cond_150 && cond_3 && ~cond_52)? ( { 16'd0, dst_wire[15:0] }) :
    (cond_150 && cond_5 && ~cond_53)? ( { 16'd0, read_4[15:0] }) :
    (cond_169)? ( { 13'd0, rd_decoder[5:3], read_4[15:0] }) :
    (cond_195 && ~cond_10)? ( { 16'd0, glob_descriptor[31:16] }) :
    (cond_233 && cond_234)? ( { 13'd0, rd_decoder[4] & rd_decoder[2], (rd_decoder[6] & rd_decoder[0]) | rd_decoder[1], rd_decoder[0], read_4[15:0] }) :
    (cond_235 && cond_232)? ( { 13'd0, rd_decoder[4] & rd_decoder[2], (rd_decoder[6] & rd_decoder[0]) | rd_decoder[1], rd_decoder[0], read_4[15:0] }) :
    32'd0;
assign rd_req_memory =
    (cond_8 && cond_5)? (`TRUE) :
    (cond_43)? (`TRUE) :
    (cond_48)? (`TRUE) :
    (cond_49)? (`TRUE) :
    (cond_51)? (`TRUE) :
    (cond_54 && cond_5)? (`TRUE) :
    (cond_65 && cond_5 && ~cond_6)? (`TRUE) :
    (cond_67 && cond_5)? (`TRUE) :
    (cond_69 && cond_5)? (`TRUE) :
    (cond_70 && cond_5)? (`TRUE) :
    (cond_73 && cond_5)? (`TRUE) :
    (cond_75)? (`TRUE) :
    (cond_76 && cond_5)? (`TRUE) :
    (cond_77)? (`TRUE) :
    (cond_84 && ~cond_85 && cond_83)? (`TRUE) :
    (cond_96 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_104 && ~cond_105 && cond_47)? (`TRUE) :
    (cond_109 && ~cond_110)? (`TRUE) :
    (cond_113 && cond_5)? (`TRUE) :
    (cond_115 && cond_5)? (`TRUE) :
    (cond_122 && cond_5)? (`TRUE) :
    (cond_128 && cond_5)? (`TRUE) :
    (cond_132 && cond_5)? ( rd_cmd[1:0] != 2'd0) :
    (cond_159 && cond_5 && cond_161)? (`TRUE) :
    (cond_163 && cond_5 && cond_164)? (`TRUE) :
    (cond_166)? (`TRUE) :
    (cond_168)? (  rd_modregrm_mod != 2'b11) :
    (cond_170 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_175 && cond_5)? (`TRUE) :
    (cond_183 && cond_5)? (`TRUE) :
    (cond_184 && cond_5)? (`TRUE) :
    (cond_206 && ~cond_10 && cond_207)? (`TRUE) :
    (cond_210)? (`TRUE) :
    (cond_254)? (`TRUE) :
    (cond_257)? (`TRUE) :
    (cond_258)? (`TRUE) :
    1'd0;
assign rd_req_ebx =
    (cond_63)? (`TRUE) :
    1'd0;
assign rd_req_esi =
    (cond_66 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_96 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_228 && ~cond_46 && cond_229 && ~cond_7)? (`TRUE) :
    (cond_252 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_253 && cond_47)? (`TRUE) :
    1'd0;
assign rd_glob_param_4_set =
    (cond_37 && cond_38)? (`TRUE) :
    (cond_102)? (`TRUE) :
    (cond_250)? (`TRUE) :
    1'd0;
assign rd_src_is_implicit_reg =
    (cond_49)? (`TRUE) :
    1'd0;
assign rd_system_linear =
    (cond_15)? ( idtr_base + { 22'd0, exc_vector[7:0], 2'b00 }) :
    (cond_16)? ( idtr_base + { 22'd0, exc_vector[7:0], 2'b10 }) :
    (cond_17)? ( idtr_base + { 21'd0, exc_vector[7:0], 3'b000 }) :
    (cond_27)? ( tr_base) :
    (cond_176)? ( tr_base + 32'd102) :
    (cond_178)? ( tr_base + { 16'd0, rd_memory_last[15:0] } + { 16'd0, 3'd0, glob_param_1[15:3] }) :
    (cond_206)? ( gdtr_base + { 16'd0, tr[15:3], 3'd0 } + 32'd4) :
    (cond_211 && cond_212)? ( glob_desc_base + 32'd12) :
    (cond_211 && cond_213)? ( glob_desc_base + 32'h1C) :
    (cond_211 && cond_214)? ( rd_task_switch_linear_next) :
    (cond_216)? ( rd_task_switch_linear_next) :
    (cond_218)? ( gdtr_base + { 16'd0, glob_param_1[15:3], 3'd0 } + 32'd4) :
    (cond_248)? ( tr_base + rd_offset_for_ss_from_tss) :
    (cond_250)? ( tr_base + rd_offset_for_esp_from_tss) :
    32'd0;
assign rd_req_esp =
    (cond_43)? (`TRUE) :
    (cond_48)? (`TRUE) :
    (cond_49)? (`TRUE) :
    (cond_51)? (`TRUE) :
    (cond_57)? (`TRUE) :
    (cond_75)? (`TRUE) :
    (cond_80)? (`TRUE) :
    (cond_166)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_171 && ~cond_53)? (`TRUE) :
    (cond_172)? (`TRUE) :
    (cond_174)? (`TRUE) :
    (cond_254)? (`TRUE) :
    (cond_256)? (`TRUE) :
    (cond_257)? (`TRUE) :
    (cond_258)? (`TRUE) :
    1'd0;
assign io_read_address =
    (cond_84)? ( edx[15:0]) :
    (cond_203)? ( (rd_cmdex == `CMDEX_IN_imm)? { 8'd0, rd_decoder[15:8] } : (rd_cmdex == `CMDEX_IN_protected)? glob_param_1[15:0] : edx[15:0]) :
    16'd0;
assign read_system_qword =
    (cond_17 && ~cond_10)? (`TRUE) :
    1'd0;
assign read_rmw_system_dword =
    (cond_206 && ~cond_10 && cond_207 && ~cond_53)? (`TRUE) :
    (cond_218 && ~cond_10 && cond_219)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_first =
    (cond_30 && cond_31)? (`TRUE) :
    1'd0;
assign address_memoffset =
    (cond_109)? (`TRUE) :
    1'd0;
assign rd_glob_descriptor_2_value =
    (cond_36)? ( glob_descriptor) :
    (cond_97)? ( glob_descriptor) :
    64'd0;
assign address_stack_for_ret_second =
    (cond_97)? (`TRUE) :
    1'd0;
assign rd_glob_param_4_value =
    (cond_37 && cond_38)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_102)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_250)? ( (rd_ss_esp_from_tss_386)? read_4 : { 16'd0, read_4[15:0] }) :
    32'd0;
assign rd_dst_is_eax =
    (cond_45 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_103)? (`TRUE) :
    (cond_106)? (`TRUE) :
    (cond_109 && cond_110)? (`TRUE) :
    (cond_165)? (`TRUE) :
    (cond_182)? (`TRUE) :
    (cond_187)? (`TRUE) :
    1'd0;
assign read_length_dword =
    (cond_77 && cond_79)? (`TRUE) :
    (cond_129 && cond_131)? (`TRUE) :
    (cond_198 && cond_200)? (`TRUE) :
    1'd0;
assign rd_req_edx_eax =
    (cond_90)? (      ~(rd_decoder[3]) && rd_decoder[0]) :
    (cond_117)? ( rd_decoder[0]) :
    (cond_237)? ( rd_decoder[0]) :
    1'd0;
assign rd_glob_param_2_value =
    (cond_15)? ( { 16'd0, read_4[15:0] }) :
    (cond_18 && cond_20)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_28 && ~cond_10 && cond_29)? ( 32'd0) :
    (cond_28 && ~cond_10 && ~cond_29)? ( { 30'd0, rd_descriptor_not_in_limits, glob_param_1[15:2] == 14'd0 }) :
    (cond_30 && cond_33)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_37 && cond_40)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_57)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_98 && ~cond_53 && cond_99)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_101 && ~cond_53 && cond_100)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_140 && ~cond_10)? ( (glob_descriptor[`DESC_BITS_TYPE] == `DESC_CALL_GATE_386)? { glob_descriptor[63:48], glob_descriptor[15:0] } : { 16'd0, glob_descriptor[15:0] }) :
    (cond_151 && cond_152 && ~cond_53)? ( 32'd0) :
    (cond_151 && ~cond_152)? ( { 30'd0, rd_descriptor_not_in_limits, glob_param_1[15:2] == 14'd0 }) :
    (cond_206 && ~cond_10 && cond_207)? ( read_4) :
    (cond_220 && ~cond_10 && cond_221)? ( 32'd0) :
    (cond_220 && ~cond_10 && ~cond_221)? ( { 29'd0, glob_param_1[`SELECTOR_BIT_TI], rd_descriptor_not_in_limits, glob_param_1[15:2] == 14'd0 }) :
    (cond_222 && ~cond_10 && cond_223)? ( 32'd0) :
    (cond_222 && ~cond_10 && ~cond_223 && cond_224)? ( 32'd0) :
    (cond_222 && ~cond_10 && ~cond_223 && ~cond_224)? ( { 30'd0, rd_descriptor_not_in_limits, glob_param_1[15:2] == 14'd0 }) :
    (cond_230 && ~cond_231 && cond_232)? ( read_4) :
    (cond_235 && ~cond_232)? ( read_4) :
    32'd0;
assign rd_src_is_reg =
    (cond_2)? (`TRUE) :
    (cond_54 && cond_3)? (`TRUE) :
    (cond_65)? (`TRUE) :
    (cond_113)? (`TRUE) :
    (cond_132)? (           rd_cmdex == `CMDEX_BTx_modregrm) :
    (cond_159)? (  rd_arith_modregrm_to_rm) :
    (cond_167)? (`TRUE) :
    (cond_180)? (`TRUE) :
    (cond_183)? (`TRUE) :
    (cond_184)? (`TRUE) :
    1'd0;
assign rd_req_reg =
    (cond_8)? (`TRUE) :
    (cond_88)? (`TRUE) :
    (cond_90)? (          rd_decoder[3]) :
    (cond_93)? (`TRUE) :
    (cond_112)? (`TRUE) :
    (cond_137)? (`TRUE) :
    (cond_153 && ~cond_155 && cond_156)? (`TRUE) :
    (cond_159 && cond_3 && cond_160)? ( rd_arith_modregrm_to_reg) :
    (cond_159 && cond_5 && cond_162)? (`TRUE) :
    (cond_168)? (`TRUE) :
    (cond_236)? (`TRUE) :
    1'd0;
assign rd_glob_descriptor_value =
    (cond_11 && cond_12)? ( read_8) :
    (cond_13 && ~cond_10 && cond_14)? ( read_8) :
    (cond_17)? ( read_8) :
    (cond_28 && ~cond_10 && cond_29)? ( read_8) :
    (cond_141 && cond_14)? ( read_8) :
    (cond_146 && ~cond_10 && cond_14)? ( read_8) :
    (cond_148 && cond_12)? ( read_8) :
    (cond_151 && cond_152 && ~cond_53)? ( read_8) :
    (cond_194 && ~cond_10 && cond_14)? ( read_8) :
    (cond_196 && cond_12)? ( read_8) :
    (cond_197 && ~cond_10 && cond_14)? ( read_8) :
    (cond_220 && ~cond_10 && cond_221)? ( read_8) :
    (cond_222 && ~cond_10 && cond_223)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0,glob_param_1[15:12], glob_param_1[11:0],4'd0, 16'hFFFF }) :
    (cond_222 && ~cond_10 && ~cond_223 && cond_224)? ( read_8) :
    (cond_240 && cond_223)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0, glob_param_1[15:12], glob_param_1[11:0], 4'd0, 16'hFFFF }) :
    (cond_240 && cond_241)? ( `DESC_MASK_P | `DESC_MASK_SEG | { 24'd0, 4'd0, glob_param_1[15:12], glob_param_1[11:0], 4'd0, 16'd0 }) :
    (cond_240 && cond_100)? ( `DESC_MASK_SEG | { 24'd0, 24'd0, 16'd0 }) :
    (cond_242 && cond_243)? ( read_8) :
    (cond_251 && ~cond_10 && cond_29)? ( read_8) :
    64'd0;
assign rd_dst_is_rm =
    (cond_2 && cond_3)? (`TRUE) :
    (cond_54 && cond_3)? (`TRUE) :
    (cond_58 && cond_59 && cond_3)? (`TRUE) :
    (cond_65 && cond_3 && ~cond_4)? (`TRUE) :
    (cond_67 && cond_3)? (`TRUE) :
    (cond_69 && cond_3)? (`TRUE) :
    (cond_70 && cond_3)? (`TRUE) :
    (cond_73 && cond_3 && ~cond_52)? (`TRUE) :
    (cond_76 && cond_3)? (`TRUE) :
    (cond_113 && cond_3)? (`TRUE) :
    (cond_115 && cond_3)? (`TRUE) :
    (cond_120)? (`TRUE) :
    (cond_122 && cond_3)? (`TRUE) :
    (cond_126)? (`TRUE) :
    (cond_128 && cond_3)? (`TRUE) :
    (cond_132 && cond_3)? (`TRUE) :
    (cond_150 && cond_3 && ~cond_52)? (`TRUE) :
    (cond_159 && cond_3)? (   rd_arith_modregrm_to_rm) :
    (cond_163 && cond_3)? (`TRUE) :
    (cond_167 && cond_3)? (`TRUE) :
    (cond_170 && cond_3)? (`TRUE) :
    (cond_175 && cond_3)? (`TRUE) :
    (cond_180 && cond_3)? (`TRUE) :
    (cond_181 && cond_3)? (`TRUE) :
    (cond_183 && cond_3)? (`TRUE) :
    (cond_184 && cond_3)? (`TRUE) :
    1'd0;
assign rd_req_ecx =
    (cond_63)? (`TRUE) :
    (cond_127)? (`TRUE) :
    1'd0;
assign rd_src_is_ecx =
    (cond_70)? (`TRUE) :
    1'd0;
assign rd_src_is_io =
    (cond_84 && ~cond_85 && cond_83)? (`TRUE) :
    (cond_203 && ~cond_204 && cond_205)? (`TRUE) :
    1'd0;
assign address_bits_transform =
    (cond_132)? ( rd_cmdex == `CMDEX_BTx_modregrm) :
    1'd0;
assign rd_dst_is_memory =
    (cond_2 && cond_5)? (`TRUE) :
    (cond_54 && cond_5)? (`TRUE) :
    (cond_65 && cond_5 && ~cond_6)? (`TRUE) :
    (cond_67 && cond_5)? (`TRUE) :
    (cond_69 && cond_5)? (`TRUE) :
    (cond_70 && cond_5)? (`TRUE) :
    (cond_73 && cond_5)? (`TRUE) :
    (cond_76 && cond_5)? (`TRUE) :
    (cond_109 && ~cond_110)? (`TRUE) :
    (cond_113 && cond_5)? (`TRUE) :
    (cond_115 && cond_5)? (`TRUE) :
    (cond_122 && cond_5)? (`TRUE) :
    (cond_128 && cond_5)? (`TRUE) :
    (cond_132 && cond_5)? (`TRUE) :
    (cond_159 && cond_5)? (   rd_arith_modregrm_to_rm) :
    (cond_163 && cond_5)? (`TRUE) :
    (cond_167 && cond_5)? (`TRUE) :
    (cond_170 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_175 && cond_5)? (`TRUE) :
    (cond_180 && cond_5)? (`TRUE) :
    (cond_181 && cond_5)? (`TRUE) :
    (cond_183 && cond_5)? (`TRUE) :
    (cond_184 && cond_5)? (`TRUE) :
    1'd0;
assign rd_dst_is_eip =
    (cond_138)? (`TRUE) :
    (cond_189)? (`TRUE) :
    1'd0;
assign rd_dst_is_0 =
    (cond_170)? (`TRUE) :
    1'd0;
assign rd_glob_param_5_value =
    (cond_37 && cond_39)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_198 && ~cond_10)? ( read_4) :
    (cond_251 && ~cond_10 && cond_29)? ( 32'd0) :
    (cond_251 && ~cond_10 && ~cond_29)? ( { 31'd0, rd_descriptor_not_in_limits }) :
    32'd0;
assign rd_extra_wire =
    (cond_139)? ( rd_decoder[55:24]) :
    (cond_153 && cond_154)? ( { 8'd0, glob_descriptor[55:40], 8'd0 }) :
    (cond_153 && ~cond_154)? ( glob_desc_limit) :
    (cond_193)? ( rd_decoder[55:24]) :
    32'd0;
assign address_edi =
    (cond_45)? (`TRUE) :
    (cond_81)? (`TRUE) :
    (cond_253)? (`TRUE) :
    1'd0;
assign rd_src_is_1 =
    (cond_69)? (            rd_cmdex == `CMDEX_Shift_modregrm) :
    (cond_73)? (`TRUE) :
    (cond_74)? (`TRUE) :
    1'd0;
assign address_stack_pop_next =
    (cond_30)? (`TRUE) :
    (cond_34)? (`TRUE) :
    (cond_36)? (`TRUE) :
    (cond_37)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_98)? (  protected_mode) :
    (cond_101)? (     protected_mode) :
    (cond_102)? (`TRUE) :
    (cond_198)? (`TRUE) :
    1'd0;
assign rd_src_is_modregrm_imm =
    (cond_69)? ( rd_cmdex == `CMDEX_Shift_modregrm_imm) :
    (cond_115)? (`TRUE) :
    (cond_132)? (  rd_cmdex == `CMDEX_BTx_modregrm_imm) :
    (cond_163 && cond_3 && ~cond_89)? (`TRUE) :
    (cond_163 && cond_5 && ~cond_89)? (`TRUE) :
    (cond_181)? (`TRUE) :
    1'd0;
assign rd_req_all =
    (cond_225 && cond_227)? (`TRUE) :
    1'd0;
assign rd_req_edi =
    (cond_45 && ~cond_46 && cond_47 && ~cond_7)? (`TRUE) :
    (cond_84 && ~cond_85 && cond_83)? (`TRUE) :
    (cond_96 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_104 && ~cond_105 && cond_47)? (`TRUE) :
    (cond_252 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_253 && cond_47)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_second =
    (cond_36)? (`TRUE) :
    1'd0;
assign rd_dst_is_edx_eax =
    (cond_90)? (    ~(rd_decoder[3])) :
    (cond_117)? (`TRUE) :
    (cond_237)? (`TRUE) :
    1'd0;
assign address_stack_for_ret_first =
    (cond_98)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_to_v86 =
    (cond_34 && cond_35)? (`TRUE) :
    1'd0;
assign rd_glob_descriptor_2_set =
    (cond_36)? (`TRUE) :
    (cond_97)? (`TRUE) :
    1'd0;
assign rd_src_is_memory =
    (cond_34)? (`TRUE) :
    (cond_45 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_51 && cond_5)? (`TRUE) :
    (cond_66 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_80)? (`TRUE) :
    (cond_88 && cond_5)? (`TRUE) :
    (cond_90 && cond_5 && ~cond_92)? (`TRUE) :
    (cond_95 && cond_5)? (`TRUE) :
    (cond_96 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_106)? (`TRUE) :
    (cond_107)? (`TRUE) :
    (cond_108)? (`TRUE) :
    (cond_109 && cond_110)? (`TRUE) :
    (cond_112 && cond_5)? (`TRUE) :
    (cond_117 && cond_5)? (`TRUE) :
    (cond_123 && cond_124 && cond_5)? (`TRUE) :
    (cond_129 && cond_124)? (`TRUE) :
    (cond_137 && cond_5)? (`TRUE) :
    (cond_142 && cond_5)? (`TRUE) :
    (cond_143)? (`TRUE) :
    (cond_159 && cond_5)? (   rd_arith_modregrm_to_reg) :
    (cond_170 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_171 && ~cond_53)? (`TRUE) :
    (cond_172)? (`TRUE) :
    (cond_174)? (`TRUE) :
    (cond_178 && ~cond_179)? (`TRUE) :
    (cond_188 && cond_5)? (`TRUE) :
    (cond_190)? (`TRUE) :
    (cond_211 && cond_215 && ~cond_53)? (`TRUE) :
    (cond_216 && cond_217)? (`TRUE) :
    (cond_218 && ~cond_10 && cond_219)? (`TRUE) :
    (cond_225 && ~cond_173)? (`TRUE) :
    (cond_228 && ~cond_46 && cond_229)? (`TRUE) :
    (cond_237 && cond_5 && ~cond_239)? (`TRUE) :
    (cond_252 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_253 && cond_47)? (`TRUE) :
    (cond_258)? (`TRUE) :
    1'd0;
assign read_system_descriptor =
    (cond_11 && cond_12)? (`TRUE) :
    (cond_13 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_28 && ~cond_10 && cond_29)? (`TRUE) :
    (cond_141 && cond_14)? (`TRUE) :
    (cond_146 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_148 && cond_12)? (`TRUE) :
    (cond_151 && cond_152 && ~cond_53)? (`TRUE) :
    (cond_194 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_196 && cond_12)? (`TRUE) :
    (cond_197 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_220 && ~cond_10 && cond_221)? (`TRUE) :
    (cond_222 && ~cond_10 && ~cond_223 && cond_224)? (`TRUE) :
    (cond_242 && cond_243 && ~cond_10)? (`TRUE) :
    (cond_251 && ~cond_10 && cond_29)? (`TRUE) :
    1'd0;
assign address_stack_save =
    (cond_30 && cond_31)? (`TRUE) :
    (cond_34 && cond_35)? (`TRUE) :
    (cond_37 && cond_38)? (`TRUE) :
    (cond_98)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_198 && cond_202)? (`TRUE) :
    1'd0;
assign address_enter_last =
    (cond_256)? (`TRUE) :
    1'd0;
assign rd_glob_descriptor_set =
    (cond_11 && cond_12)? (`TRUE) :
    (cond_13 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_17)? (`TRUE) :
    (cond_28 && ~cond_10 && cond_29)? (`TRUE) :
    (cond_141 && cond_14)? (`TRUE) :
    (cond_146 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_148 && cond_12)? (`TRUE) :
    (cond_151 && cond_152 && ~cond_53)? (`TRUE) :
    (cond_194 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_196 && cond_12)? (`TRUE) :
    (cond_197 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_220 && ~cond_10 && cond_221)? (`TRUE) :
    (cond_222 && ~cond_10 && cond_223)? (`TRUE) :
    (cond_222 && ~cond_10 && ~cond_223 && cond_224)? (`TRUE) :
    (cond_240 && cond_223)? (`TRUE) :
    (cond_240 && cond_241)? (`TRUE) :
    (cond_240 && cond_100)? (`TRUE) :
    (cond_242 && cond_243)? (`TRUE) :
    (cond_251 && ~cond_10 && cond_29)? (`TRUE) :
    1'd0;
assign rd_glob_param_3_value =
    (cond_18 && cond_22)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_28)? ( { 10'd0, rd_consumed, 18'd0 }) :
    (cond_30 && cond_31)? ( (rd_operand_16bit)? { 16'd0, read_4[15:0] } : read_4) :
    (cond_36)? ( glob_param_1) :
    (cond_97)? ( glob_param_1) :
    (cond_146 && ~cond_10 && cond_14)? ( 32'd0) :
    (cond_194 && ~cond_10 && cond_14)? ( 32'd0) :
    (cond_198 && cond_201)? ( { 7'd0, rd_call_gate_param, glob_param_3[19:0] }) :
    (cond_248 && ~cond_249)? ( { 16'd0, read_4[15:0] }) :
    32'd0;
assign address_stack_add_4_to_saved =
    (cond_34)? (`TRUE) :
    1'd0;
assign read_length_word =
    (cond_36)? (`TRUE) :
    (cond_54 && cond_5)? (`TRUE) :
    (cond_58 && cond_59 && cond_5)? (`TRUE) :
    (cond_77 && cond_78)? (`TRUE) :
    (cond_95 && cond_5)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_123 && cond_124 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_129 && cond_130)? (`TRUE) :
    (cond_143 && cond_144)? (`TRUE) :
    (cond_150 && cond_5)? (`TRUE) :
    (cond_151 && cond_152)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_190 && cond_191)? (`TRUE) :
    (cond_198 && cond_199)? (`TRUE) :
    (cond_233 && cond_234)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_last =
    (cond_37 && cond_40)? (`TRUE) :
    1'd0;
assign io_read =
    (cond_84 && ~cond_85 && cond_83)? (`TRUE) :
    (cond_203 && ~cond_204 && cond_205)? (`TRUE) :
    1'd0;
assign rd_waiting =
    (cond_0 && cond_1)? (`TRUE) :
    (cond_2 && cond_3 && cond_4)? (`TRUE) :
    (cond_2 && cond_5 && cond_6)? (`TRUE) :
    (cond_2 && cond_5 && ~cond_6 && cond_7)? (`TRUE) :
    (cond_9 && cond_10)? (`TRUE) :
    (cond_11 && cond_12 && cond_7)? (`TRUE) :
    (cond_13 && cond_10)? (`TRUE) :
    (cond_13 && ~cond_10 && cond_14 && cond_7)? (`TRUE) :
    (cond_15 && cond_10)? (`TRUE) :
    (cond_15 && ~cond_10 && cond_7)? (`TRUE) :
    (cond_16 && cond_10)? (`TRUE) :
    (cond_16 && ~cond_10 && cond_7)? (`TRUE) :
    (cond_17 && cond_10)? (`TRUE) :
    (cond_17 && ~cond_10 && cond_7)? (`TRUE) :
    (cond_18 && cond_23)? (`TRUE) :
    (cond_18 && ~cond_23 && cond_24 && cond_7)? (`TRUE) :
    (cond_25 && cond_26)? (`TRUE) :
    (cond_27 && cond_7)? (`TRUE) :
    (cond_28 && cond_10)? (`TRUE) :
    (cond_28 && ~cond_10 && cond_29 && cond_7)? (`TRUE) :
    (cond_30 && cond_7)? (`TRUE) :
    (cond_34 && cond_7)? (`TRUE) :
    (cond_36 && cond_7)? (`TRUE) :
    (cond_37 && cond_7)? (`TRUE) :
    (cond_41 && cond_10)? (`TRUE) :
    (cond_43 && cond_44)? (`TRUE) :
    (cond_45 && cond_46)? (`TRUE) :
    (cond_45 && ~cond_46 && cond_47 && cond_7)? (`TRUE) :
    (cond_49 && cond_50)? (`TRUE) :
    (cond_51 && cond_3 && cond_52)? (`TRUE) :
    (cond_51 && cond_5 && cond_53)? (`TRUE) :
    (cond_51 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_54 && cond_3 && cond_55)? (`TRUE) :
    (cond_54 && cond_5 && cond_56)? (`TRUE) :
    (cond_54 && cond_5 && ~cond_56 && cond_7)? (`TRUE) :
    (cond_57 && cond_53)? (`TRUE) :
    (cond_57 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_58 && cond_59 && cond_3 && cond_52)? (`TRUE) :
    (cond_58 && cond_59 && cond_5 && cond_53)? (`TRUE) :
    (cond_58 && cond_59 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_63 && cond_64)? (`TRUE) :
    (cond_65 && cond_3 && cond_4)? (`TRUE) :
    (cond_65 && cond_5 && cond_6)? (`TRUE) :
    (cond_65 && cond_5 && ~cond_6 && cond_7)? (`TRUE) :
    (cond_66 && cond_46)? (`TRUE) :
    (cond_66 && ~cond_46 && cond_47 && cond_7)? (`TRUE) :
    (cond_67 && cond_5 && cond_68)? (`TRUE) :
    (cond_69 && cond_3 && cond_52)? (`TRUE) :
    (cond_69 && cond_5 && cond_53)? (`TRUE) :
    (cond_69 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_70 && cond_3 && cond_71)? (`TRUE) :
    (cond_70 && cond_5 && cond_72)? (`TRUE) :
    (cond_70 && cond_5 && ~cond_72 && cond_7)? (`TRUE) :
    (cond_73 && cond_3 && cond_52)? (`TRUE) :
    (cond_73 && cond_5 && cond_53)? (`TRUE) :
    (cond_73 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_74 && cond_50)? (`TRUE) :
    (cond_76 && cond_5 && cond_53)? (`TRUE) :
    (cond_76 && cond_5 && ~cond_53 && cond_68)? (`TRUE) :
    (cond_77 && cond_68)? (`TRUE) :
    (cond_80 && cond_53)? (`TRUE) :
    (cond_80 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_81 && cond_82)? (`TRUE) :
    (cond_81 && ~cond_82 && cond_83 && cond_7)? (`TRUE) :
    (cond_84 && cond_85)? (`TRUE) :
    (cond_84 && ~cond_85 && cond_83 && cond_86)? (`TRUE) :
    (cond_88 && cond_3 && cond_52)? (`TRUE) :
    (cond_88 && cond_5 && cond_53)? (`TRUE) :
    (cond_88 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_90 && cond_3 && cond_91)? (`TRUE) :
    (cond_90 && cond_5 && cond_92)? (`TRUE) :
    (cond_90 && cond_5 && ~cond_92 && cond_7)? (`TRUE) :
    (cond_93 && cond_94)? (`TRUE) :
    (cond_95 && cond_3 && cond_52)? (`TRUE) :
    (cond_95 && cond_5 && cond_53)? (`TRUE) :
    (cond_95 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_96 && cond_46)? (`TRUE) :
    (cond_96 && ~cond_46 && cond_47 && cond_7)? (`TRUE) :
    (cond_97 && cond_7)? (`TRUE) :
    (cond_98 && cond_53)? (`TRUE) :
    (cond_98 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_101 && cond_53)? (`TRUE) :
    (cond_101 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_102 && cond_7)? (`TRUE) :
    (cond_103 && cond_64)? (`TRUE) :
    (cond_104 && cond_105)? (`TRUE) :
    (cond_106 && cond_53)? (`TRUE) :
    (cond_106 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_107 && cond_53)? (`TRUE) :
    (cond_107 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_108 && cond_53)? (`TRUE) :
    (cond_108 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_109 && cond_110 && cond_53)? (`TRUE) :
    (cond_109 && cond_110 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_109 && ~cond_110 && cond_111)? (`TRUE) :
    (cond_112 && cond_3 && cond_52)? (`TRUE) :
    (cond_112 && cond_5 && cond_53)? (`TRUE) :
    (cond_112 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_113 && cond_3 && cond_114)? (`TRUE) :
    (cond_113 && cond_5 && cond_114)? (`TRUE) :
    (cond_113 && cond_5 && ~cond_114 && cond_68)? (`TRUE) :
    (cond_115 && cond_3 && cond_114)? (`TRUE) :
    (cond_115 && cond_5 && cond_114)? (`TRUE) :
    (cond_115 && cond_5 && ~cond_114 && cond_68)? (`TRUE) :
    (cond_117 && cond_3 && cond_118)? (`TRUE) :
    (cond_117 && cond_5 && cond_119)? (`TRUE) :
    (cond_117 && cond_5 && ~cond_119 && cond_7)? (`TRUE) :
    (cond_120 && cond_10)? (`TRUE) :
    (cond_121 && cond_10)? (`TRUE) :
    (cond_122 && cond_5 && cond_68)? (`TRUE) :
    (cond_123 && cond_124 && cond_3 && cond_52)? (`TRUE) :
    (cond_123 && cond_124 && cond_5 && cond_53)? (`TRUE) :
    (cond_123 && cond_124 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_125 && cond_52)? (`TRUE) :
    (cond_128 && cond_3 && cond_52)? (`TRUE) :
    (cond_128 && cond_5 && cond_53)? (`TRUE) :
    (cond_128 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_129 && cond_124 && cond_53)? (`TRUE) :
    (cond_129 && cond_124 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_132 && cond_3 && cond_133)? (`TRUE) :
    (cond_132 && cond_5 && cond_134)? (`TRUE) :
    (cond_132 && cond_5 && ~cond_134 && cond_7)? (`TRUE) :
    (cond_137 && cond_3 && cond_52)? (`TRUE) :
    (cond_137 && cond_5 && cond_53)? (`TRUE) :
    (cond_137 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_140 && cond_10)? (`TRUE) :
    (cond_141 && cond_14 && cond_7)? (`TRUE) :
    (cond_142 && cond_3 && cond_52)? (`TRUE) :
    (cond_142 && cond_5 && cond_53)? (`TRUE) :
    (cond_142 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_143 && cond_53)? (`TRUE) :
    (cond_143 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_146 && cond_10)? (`TRUE) :
    (cond_146 && ~cond_10 && cond_14 && cond_7)? (`TRUE) :
    (cond_147 && cond_10)? (`TRUE) :
    (cond_148 && cond_12 && cond_7)? (`TRUE) :
    (cond_149 && cond_94)? (`TRUE) :
    (cond_150 && cond_3 && cond_52)? (`TRUE) :
    (cond_150 && cond_5 && cond_53)? (`TRUE) :
    (cond_150 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_151 && cond_152 && cond_53)? (`TRUE) :
    (cond_151 && cond_152 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_153 && cond_155)? (`TRUE) :
    (cond_157 && cond_155)? (`TRUE) :
    (cond_159 && cond_3 && cond_4)? (`TRUE) :
    (cond_159 && cond_5 && cond_56)? (`TRUE) :
    (cond_159 && cond_5 && ~cond_56 && cond_7)? (`TRUE) :
    (cond_163 && cond_3 && cond_52)? (`TRUE) :
    (cond_163 && cond_5 && cond_53)? (`TRUE) :
    (cond_163 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_165 && cond_64)? (`TRUE) :
    (cond_167 && cond_3 && cond_4)? (`TRUE) :
    (cond_167 && cond_5 && cond_6)? (`TRUE) :
    (cond_167 && cond_5 && ~cond_6 && cond_7)? (`TRUE) :
    (cond_169 && cond_53)? (`TRUE) :
    (cond_169 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_170 && cond_3 && cond_52)? (`TRUE) :
    (cond_170 && cond_5 && cond_53)? (`TRUE) :
    (cond_170 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_171 && cond_53)? (`TRUE) :
    (cond_171 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_172 && cond_173)? (`TRUE) :
    (cond_172 && ~cond_173 && cond_7)? (`TRUE) :
    (cond_174 && cond_173)? (`TRUE) :
    (cond_174 && ~cond_173 && cond_7)? (`TRUE) :
    (cond_175 && cond_5 && cond_68)? (`TRUE) :
    (cond_176 && cond_177)? (`TRUE) :
    (cond_176 && ~cond_177 && cond_7)? (`TRUE) :
    (cond_178 && cond_179)? (`TRUE) :
    (cond_178 && ~cond_179 && cond_7)? (`TRUE) :
    (cond_180 && cond_3 && cond_4)? (`TRUE) :
    (cond_180 && cond_5 && cond_56)? (`TRUE) :
    (cond_180 && cond_5 && ~cond_56 && cond_7)? (`TRUE) :
    (cond_181 && cond_3 && cond_52)? (`TRUE) :
    (cond_181 && cond_5 && cond_53)? (`TRUE) :
    (cond_181 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_182 && cond_64)? (`TRUE) :
    (cond_183 && cond_3 && cond_55)? (`TRUE) :
    (cond_183 && cond_5 && cond_56)? (`TRUE) :
    (cond_183 && cond_5 && ~cond_56 && cond_7)? (`TRUE) :
    (cond_184 && cond_3 && cond_185)? (`TRUE) :
    (cond_184 && cond_5 && cond_186)? (`TRUE) :
    (cond_184 && cond_5 && ~cond_186 && cond_7)? (`TRUE) :
    (cond_187 && cond_64)? (`TRUE) :
    (cond_188 && cond_3 && cond_52)? (`TRUE) :
    (cond_188 && cond_5 && cond_53)? (`TRUE) :
    (cond_188 && cond_5 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_190 && cond_53)? (`TRUE) :
    (cond_190 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_194 && cond_10)? (`TRUE) :
    (cond_194 && ~cond_10 && cond_14 && cond_7)? (`TRUE) :
    (cond_195 && cond_10)? (`TRUE) :
    (cond_196 && cond_12 && cond_7)? (`TRUE) :
    (cond_197 && cond_10)? (`TRUE) :
    (cond_197 && ~cond_10 && cond_14 && cond_7)? (`TRUE) :
    (cond_198 && cond_10)? (`TRUE) :
    (cond_198 && ~cond_10 && cond_7)? (`TRUE) :
    (cond_203 && cond_204)? (`TRUE) :
    (cond_203 && ~cond_204 && cond_205 && cond_86)? (`TRUE) :
    (cond_206 && cond_10)? (`TRUE) :
    (cond_206 && ~cond_10 && cond_207 && cond_53)? (`TRUE) :
    (cond_206 && ~cond_10 && cond_207 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_208 && cond_53)? (`TRUE) :
    (cond_211 && cond_215 && cond_53)? (`TRUE) :
    (cond_211 && cond_215 && ~cond_53 && cond_7)? (`TRUE) :
    (cond_216 && cond_217 && cond_7)? (`TRUE) :
    (cond_218 && cond_10)? (`TRUE) :
    (cond_218 && ~cond_10 && cond_219 && cond_7)? (`TRUE) :
    (cond_220 && cond_10)? (`TRUE) :
    (cond_220 && ~cond_10 && cond_221 && cond_7)? (`TRUE) :
    (cond_222 && cond_10)? (`TRUE) :
    (cond_222 && ~cond_10 && ~cond_223 && cond_224 && cond_7)? (`TRUE) :
    (cond_225 && cond_173)? (`TRUE) :
    (cond_225 && ~cond_173 && cond_7)? (`TRUE) :
    (cond_228 && cond_46)? (`TRUE) :
    (cond_228 && ~cond_46 && cond_229 && cond_7)? (`TRUE) :
    (cond_230 && cond_231)? (`TRUE) :
    (cond_230 && ~cond_231 && cond_232 && cond_7)? (`TRUE) :
    (cond_233 && cond_234 && cond_7)? (`TRUE) :
    (cond_235 && cond_7)? (`TRUE) :
    (cond_237 && cond_3 && cond_238)? (`TRUE) :
    (cond_237 && cond_5 && cond_239)? (`TRUE) :
    (cond_237 && cond_5 && ~cond_239 && cond_7)? (`TRUE) :
    (cond_242 && cond_243 && cond_10)? (`TRUE) :
    (cond_242 && cond_243 && ~cond_10 && cond_7)? (`TRUE) :
    (cond_244 && cond_50)? (`TRUE) :
    (cond_245 && cond_64)? (`TRUE) :
    (cond_246 && cond_247)? (`TRUE) :
    (cond_248 && cond_249)? (`TRUE) :
    (cond_248 && ~cond_249 && cond_7)? (`TRUE) :
    (cond_250 && cond_7)? (`TRUE) :
    (cond_251 && cond_10)? (`TRUE) :
    (cond_251 && ~cond_10 && cond_29 && cond_7)? (`TRUE) :
    (cond_252 && cond_46)? (`TRUE) :
    (cond_252 && ~cond_46 && cond_47 && cond_7)? (`TRUE) :
    (cond_253 && cond_47 && cond_7)? (`TRUE) :
    (cond_254 && cond_255)? (`TRUE) :
    (cond_256 && cond_7)? (`TRUE) :
    (cond_258 && cond_7)? (`TRUE) :
    1'd0;
assign read_system_dword =
    (cond_211 && cond_215 && ~cond_53)? ( glob_descriptor[`DESC_BITS_TYPE] >  4'd3) :
    (cond_216 && cond_217)? ( glob_descriptor[`DESC_BITS_TYPE] >  4'd3 && rd_cmdex <= `CMDEX_task_switch_3_STEP_7) :
    (cond_250)? ( rd_ss_esp_from_tss_386) :
    1'd0;
assign address_ea_buffer_plus_2 =
    (cond_77)? (`TRUE) :
    (cond_129)? (`TRUE) :
    1'd0;
assign address_leave =
    (cond_171)? (`TRUE) :
    1'd0;
assign rd_dst_is_memory_last =
    (cond_253 && cond_47)? (`TRUE) :
    1'd0;
assign address_enter =
    (cond_258)? (`TRUE) :
    1'd0;
assign address_stack_pop_speedup =
    (cond_18 && cond_19)? (`TRUE) :
    (cond_101)? (  real_mode || v8086_mode) :
    (cond_225 && cond_226)? (`TRUE) :
    1'd0;
assign rd_req_edx =
    (cond_63)? (`TRUE) :
    (cond_136)? ( rd_cmd == `CMD_CWD) :
    1'd0;
assign address_enter_init =
    (cond_254)? (`TRUE) :
    1'd0;
assign read_rmw_virtual =
    (cond_2 && cond_5 && ~cond_6)? (`TRUE) :
    (cond_54 && cond_5 && ~cond_56)? (`TRUE) :
    (cond_65 && cond_5 && ~cond_6)? (`TRUE) :
    (cond_69 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_70 && cond_5 && ~cond_72)? (`TRUE) :
    (cond_73 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_81 && ~cond_82 && cond_83)? (`TRUE) :
    (cond_128 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_132 && cond_5 && ~cond_134)? (    rd_cmd[1:0] != 2'd0) :
    (cond_159 && cond_5 && ~cond_56 && cond_161)? (`TRUE) :
    (cond_163 && cond_5 && ~cond_53 && cond_164)? (`TRUE) :
    (cond_167 && cond_5 && ~cond_6)? (`TRUE) :
    (cond_170 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_183 && cond_5 && ~cond_56)? (`TRUE) :
    (cond_184 && cond_5 && ~cond_186)? (`TRUE) :
    (cond_256)? (`TRUE) :
    1'd0;
assign rd_src_is_rm =
    (cond_51 && cond_3)? (`TRUE) :
    (cond_88 && cond_3)? (`TRUE) :
    (cond_90 && cond_3)? (`TRUE) :
    (cond_95 && cond_3)? (`TRUE) :
    (cond_112 && cond_3)? (`TRUE) :
    (cond_117 && cond_3)? (`TRUE) :
    (cond_121)? (`TRUE) :
    (cond_123 && cond_124 && cond_3)? (`TRUE) :
    (cond_125)? (`TRUE) :
    (cond_137 && cond_3)? (`TRUE) :
    (cond_142 && cond_3)? (`TRUE) :
    (cond_159 && cond_3)? (   rd_arith_modregrm_to_reg) :
    (cond_170 && cond_3)? (`TRUE) :
    (cond_188 && cond_3)? (`TRUE) :
    (cond_237 && cond_3)? (`TRUE) :
    1'd0;
assign rd_src_is_modregrm_imm_se =
    (cond_163 && cond_3 && cond_89)? (`TRUE) :
    (cond_163 && cond_5 && cond_89)? (`TRUE) :
    1'd0;
assign address_ea_buffer =
    (cond_77 && cond_79)? (`TRUE) :
    (cond_108)? (`TRUE) :
    (cond_129 && cond_131)? (`TRUE) :
    (cond_143 && cond_144)? (`TRUE) :
    (cond_190 && cond_191)? (`TRUE) :
    (cond_233)? (`TRUE) :
    (cond_235 && cond_232)? (`TRUE) :
    1'd0;
assign rd_dst_is_modregrm_imm_se =
    (cond_88 && cond_89)? (`TRUE) :
    1'd0;
assign rd_dst_is_reg =
    (cond_8)? (`TRUE) :
    (cond_88)? (`TRUE) :
    (cond_90)? (          rd_decoder[3]) :
    (cond_93)? (`TRUE) :
    (cond_95)? (`TRUE) :
    (cond_108)? (`TRUE) :
    (cond_112)? (`TRUE) :
    (cond_137)? (`TRUE) :
    (cond_153 && ~cond_155 && cond_156)? (`TRUE) :
    (cond_157 && ~cond_155 && cond_158)? (`TRUE) :
    (cond_159)? (  rd_arith_modregrm_to_reg) :
    (cond_168)? (`TRUE) :
    (cond_236)? (`TRUE) :
    1'd0;
assign rd_src_is_imm =
    (cond_48)? (`TRUE) :
    (cond_116)? (`TRUE) :
    (cond_145)? (`TRUE) :
    (cond_165)? (`TRUE) :
    (cond_182)? (`TRUE) :
    (cond_187)? (`TRUE) :
    (cond_189)? (`TRUE) :
    (cond_192)? (`TRUE) :
    1'd0;
assign address_stack_for_call_param_first =
    (cond_198 && cond_202)? (`TRUE) :
    1'd0;
assign read_system_word =
    (cond_15 && ~cond_10)? (`TRUE) :
    (cond_16 && ~cond_10)? (`TRUE) :
    (cond_27)? (`TRUE) :
    (cond_176 && ~cond_177)? (`TRUE) :
    (cond_178 && ~cond_179)? (`TRUE) :
    (cond_211 && cond_215 && ~cond_53)? (  glob_descriptor[`DESC_BITS_TYPE] <= 4'd3) :
    (cond_216 && cond_217)? (  glob_descriptor[`DESC_BITS_TYPE] <= 4'd3 || rd_cmdex > `CMDEX_task_switch_3_STEP_7) :
    (cond_248 && ~cond_249)? (`TRUE) :
    (cond_250)? (  ~(rd_ss_esp_from_tss_386)) :
    1'd0;
assign read_virtual =
    (cond_18 && ~cond_23 && cond_24)? (`TRUE) :
    (cond_30)? (`TRUE) :
    (cond_34)? (`TRUE) :
    (cond_36)? (`TRUE) :
    (cond_37)? (`TRUE) :
    (cond_45 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_51 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_57 && ~cond_53)? (`TRUE) :
    (cond_58 && cond_59 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_66 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_80 && ~cond_53)? (`TRUE) :
    (cond_88 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_90 && cond_5 && ~cond_92)? (`TRUE) :
    (cond_95 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_96 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_98 && ~cond_53)? (`TRUE) :
    (cond_101 && ~cond_53)? (`TRUE) :
    (cond_102)? (`TRUE) :
    (cond_106 && ~cond_53)? (`TRUE) :
    (cond_107 && ~cond_53)? (`TRUE) :
    (cond_108 && ~cond_53)? (`TRUE) :
    (cond_109 && cond_110 && ~cond_53)? (`TRUE) :
    (cond_112 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_117 && cond_5 && ~cond_119)? (`TRUE) :
    (cond_123 && cond_124 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_129 && cond_124 && ~cond_53)? (`TRUE) :
    (cond_132 && cond_5 && ~cond_134)? (        rd_cmd[1:0] == 2'd0) :
    (cond_137 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_142 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_143 && ~cond_53)? (`TRUE) :
    (cond_150 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_159 && cond_5 && ~cond_56 && ~cond_161)? (`TRUE) :
    (cond_163 && cond_5 && ~cond_53 && ~cond_164)? (`TRUE) :
    (cond_169 && ~cond_53)? (`TRUE) :
    (cond_171 && ~cond_53)? (`TRUE) :
    (cond_172 && ~cond_173)? (`TRUE) :
    (cond_174 && ~cond_173)? (`TRUE) :
    (cond_180 && cond_5 && ~cond_56)? (`TRUE) :
    (cond_181 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_188 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_190 && ~cond_53)? (`TRUE) :
    (cond_198 && ~cond_10)? (`TRUE) :
    (cond_225 && ~cond_173)? (`TRUE) :
    (cond_228 && ~cond_46 && cond_229)? (`TRUE) :
    (cond_230 && ~cond_231 && cond_232)? (`TRUE) :
    (cond_233 && cond_234)? (`TRUE) :
    (cond_235)? (`TRUE) :
    (cond_237 && cond_5 && ~cond_239)? (`TRUE) :
    (cond_252 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_253 && cond_47)? (`TRUE) :
    (cond_258)? (`TRUE) :
    1'd0;
assign write_virtual_check =
    (cond_67 && cond_5)? (`TRUE) :
    (cond_76 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_77)? (`TRUE) :
    (cond_109 && ~cond_110)? (`TRUE) :
    (cond_113 && cond_5 && ~cond_114)? (`TRUE) :
    (cond_115 && cond_5 && ~cond_114)? (`TRUE) :
    (cond_122 && cond_5)? (`TRUE) :
    (cond_175 && cond_5)? (`TRUE) :
    1'd0;
assign address_esi =
    (cond_66)? (`TRUE) :
    (cond_96)? (`TRUE) :
    (cond_228)? (`TRUE) :
    (cond_252)? (`TRUE) :
    1'd0;
assign rd_glob_param_1_set =
    (cond_9 && ~cond_10)? (`TRUE) :
    (cond_16)? (`TRUE) :
    (cond_18 && cond_21)? (`TRUE) :
    (cond_27)? (`TRUE) :
    (cond_30 && cond_32)? (`TRUE) :
    (cond_36)? ( rd_ready) :
    (cond_58 && cond_59 && cond_3 && cond_60)? (`TRUE) :
    (cond_58 && cond_59 && cond_3 && cond_61)? (`TRUE) :
    (cond_58 && cond_59 && cond_3 && cond_62)? (`TRUE) :
    (cond_58 && cond_59 && cond_5 && ~cond_53 && cond_60)? (`TRUE) :
    (cond_58 && cond_59 && cond_5 && ~cond_53 && cond_61)? (`TRUE) :
    (cond_58 && cond_59 && cond_5 && ~cond_53 && cond_62)? (`TRUE) :
    (cond_97)? ( rd_ready) :
    (cond_98 && ~cond_53 && cond_100)? (`TRUE) :
    (cond_101 && ~cond_53 && cond_99)? (`TRUE) :
    (cond_140 && ~cond_10)? (`TRUE) :
    (cond_147 && ~cond_10)? (`TRUE) :
    (cond_150 && cond_3 && ~cond_52)? (`TRUE) :
    (cond_150 && cond_5 && ~cond_53)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_195 && ~cond_10)? (`TRUE) :
    (cond_233 && cond_234)? (`TRUE) :
    (cond_235 && cond_232)? (`TRUE) :
    1'd0;
assign address_stack_pop =
    (cond_18)? (`TRUE) :
    (cond_57)? (`TRUE) :
    (cond_80)? (`TRUE) :
    (cond_98)? (       real_mode || v8086_mode) :
    (cond_101)? (          real_mode || v8086_mode) :
    (cond_169)? (`TRUE) :
    (cond_172)? (`TRUE) :
    (cond_174)? (`TRUE) :
    (cond_225)? (`TRUE) :
    1'd0;
assign address_stack_pop_for_call =
    (cond_198)? (`TRUE) :
    1'd0;
assign address_stack_for_iret_third =
    (cond_37 && cond_38)? (`TRUE) :
    1'd0;
assign rd_req_implicit_reg =
    (cond_0)? (`TRUE) :
    (cond_74)? (`TRUE) :
    (cond_116)? (`TRUE) :
    (cond_172)? (`TRUE) :
    (cond_244)? (`TRUE) :
    1'd0;
assign rd_src_is_eax =
    (cond_0)? (`TRUE) :
    (cond_104 && ~cond_105 && cond_47)? (`TRUE) :
    (cond_109 && ~cond_110)? (`TRUE) :
    (cond_245)? (`TRUE) :
    1'd0;
assign rd_req_eax =
    (cond_0)? (`TRUE) :
    (cond_63)? (`TRUE) :
    (cond_65)? (`TRUE) :
    (cond_66 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_90)? (          ~(rd_decoder[3])) :
    (cond_103)? (`TRUE) :
    (cond_106)? (`TRUE) :
    (cond_109 && cond_110)? (`TRUE) :
    (cond_117)? (`TRUE) :
    (cond_135)? (`TRUE) :
    (cond_136)? ( rd_cmd != `CMD_CWD) :
    (cond_165 && cond_160)? (`TRUE) :
    (cond_187)? (`TRUE) :
    (cond_237)? (`TRUE) :
    1'd0;
assign rd_error_code =
    (cond_11 && cond_12)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_13 && ~cond_10 && cond_14)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_141 && cond_14)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_146 && ~cond_10 && cond_14)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_148 && cond_12)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_194 && ~cond_10 && cond_14)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_196 && cond_12)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_197 && ~cond_10 && cond_14)? ( `SELECTOR_FOR_CODE(glob_param_1)) :
    (cond_242 && cond_243)? ( { glob_param_1[15:2], 2'd0 }) :
    (cond_248)? ( `SELECTOR_FOR_CODE(tr)) :
    16'd0;
assign rd_glob_param_2_set =
    (cond_15)? (`TRUE) :
    (cond_18 && cond_20)? (`TRUE) :
    (cond_28 && ~cond_10 && cond_29)? (`TRUE) :
    (cond_28 && ~cond_10 && ~cond_29)? (`TRUE) :
    (cond_30 && cond_33)? (`TRUE) :
    (cond_37 && cond_40)? (`TRUE) :
    (cond_57)? (`TRUE) :
    (cond_98 && ~cond_53 && cond_99)? (`TRUE) :
    (cond_101 && ~cond_53 && cond_100)? (`TRUE) :
    (cond_140 && ~cond_10)? (`TRUE) :
    (cond_151 && cond_152 && ~cond_53)? (`TRUE) :
    (cond_151 && ~cond_152)? (`TRUE) :
    (cond_206 && ~cond_10 && cond_207)? (`TRUE) :
    (cond_220 && ~cond_10 && cond_221)? (`TRUE) :
    (cond_220 && ~cond_10 && ~cond_221)? (`TRUE) :
    (cond_222 && ~cond_10 && cond_223)? (`TRUE) :
    (cond_222 && ~cond_10 && ~cond_223 && cond_224)? (`TRUE) :
    (cond_222 && ~cond_10 && ~cond_223 && ~cond_224)? (`TRUE) :
    (cond_230 && ~cond_231 && cond_232)? (`TRUE) :
    (cond_235 && ~cond_232)? (`TRUE) :
    1'd0;
assign rd_req_reg_not_8bit =
    (cond_95)? (`TRUE) :
    1'd0;
assign rd_src_is_cmdex =
    (cond_43)? (`TRUE) :
    (cond_209)? (`TRUE) :
    (cond_254)? (`TRUE) :
    1'd0;
assign rd_dst_is_modregrm_imm =
    (cond_88 && ~cond_89)? (`TRUE) :
    1'd0;
assign rd_glob_param_3_set =
    (cond_18 && cond_22)? (`TRUE) :
    (cond_28)? (`TRUE) :
    (cond_30 && cond_31)? (`TRUE) :
    (cond_36)? (`TRUE) :
    (cond_97)? (`TRUE) :
    (cond_146 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_194 && ~cond_10 && cond_14)? (`TRUE) :
    (cond_198 && cond_201)? (`TRUE) :
    (cond_248 && ~cond_249)? (`TRUE) :
    1'd0;
assign address_stack_pop_esp_prev =
    (cond_97)? (`TRUE) :
    1'd0;
assign rd_req_eflags =
    (cond_42)? (`TRUE) :
    (cond_45 && ~cond_46 && cond_47 && ~cond_7)? (`TRUE) :
    (cond_54 && cond_3)? (`TRUE) :
    (cond_65)? (`TRUE) :
    (cond_69)? (`TRUE) :
    (cond_70)? (`TRUE) :
    (cond_73)? (`TRUE) :
    (cond_74)? (`TRUE) :
    (cond_80)? (`TRUE) :
    (cond_87)? (`TRUE) :
    (cond_88)? (`TRUE) :
    (cond_90)? (`TRUE) :
    (cond_103)? (`TRUE) :
    (cond_117)? (`TRUE) :
    (cond_132)? (`TRUE) :
    (cond_137)? (`TRUE) :
    (cond_153)? (`TRUE) :
    (cond_157)? (`TRUE) :
    (cond_159)? (`TRUE) :
    (cond_163)? (`TRUE) :
    (cond_165)? (`TRUE) :
    (cond_168)? (`TRUE) :
    (cond_170)? (`TRUE) :
    (cond_180)? (`TRUE) :
    (cond_181)? (`TRUE) :
    (cond_182)? (`TRUE) :
    (cond_183)? (`TRUE) :
    (cond_184)? (`TRUE) :
    (cond_187)? (`TRUE) :
    (cond_252 && ~cond_46 && cond_47)? (`TRUE) :
    (cond_253 && cond_47)? (`TRUE) :
    1'd0;
assign address_xlat_transform =
    (cond_106)? (`TRUE) :
    1'd0;
assign rd_src_is_imm_se =
    (cond_138)? (`TRUE) :
    1'd0;
