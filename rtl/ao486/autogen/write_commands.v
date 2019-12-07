wire [15:0] wr_IRET_to_v86_es;
wire [15:0] wr_IRET_to_v86_cs;
wire [15:0] wr_IRET_to_v86_ss;
wire [15:0] wr_IRET_to_v86_ds;
wire [15:0] wr_IRET_to_v86_fs;
wire [15:0] wr_IRET_to_v86_gs;
assign wr_IRET_to_v86_es = exe_buffer_shifted[79:64];
assign wr_IRET_to_v86_cs = glob_param_1[15:0];
assign wr_IRET_to_v86_ss = exe_buffer_shifted[111:96];
assign wr_IRET_to_v86_ds = exe_buffer_shifted[47:32];
assign wr_IRET_to_v86_fs = exe_buffer_shifted[15:0];
assign wr_IRET_to_v86_gs = exe_buffer[15:0];

wire [31:0] wr_ecx_minus_1;
assign wr_ecx_minus_1 = ecx - 32'd1;

wire [31:0] wr_task_switch_linear;
wire [31:0] wr_task_switch_linear_next;
reg  [31:0] wr_task_switch_linear_reg;
assign wr_task_switch_linear = (wr_cmd == `CMD_task_switch && wr_cmdex == `CMDEX_task_switch_STEP_9 && tr_cache[`DESC_BITS_TYPE] <= 4'd3)?     tr_base + 32'd14 : (wr_cmd == `CMD_task_switch && wr_cmdex == `CMDEX_task_switch_STEP_9 && tr_cache[`DESC_BITS_TYPE] > 4'd3)?      tr_base + 32'h20 : wr_task_switch_linear_next;
assign wr_task_switch_linear_next = (tr_cache[`DESC_BITS_TYPE] <= 4'd3)?    wr_task_switch_linear_reg + 32'd2 : wr_task_switch_linear_reg + 32'd4;
always @(posedge clk or negedge rst_n) begin if(rst_n == 1'b0)                                                               wr_task_switch_linear_reg <= 32'd0; else if(wr_cmd == `CMD_task_switch && wr_cmdex == `CMDEX_task_switch_STEP_9)    wr_task_switch_linear_reg <= wr_task_switch_linear; else if(wr_ready)                                                               wr_task_switch_linear_reg <= wr_task_switch_linear_next;
end

//======================================================== conditions
wire cond_0 = wr_cmd == `CMD_XCHG && wr_cmdex == `CMDEX_XCHG_implicit;
wire cond_1 = wr_cmd == `CMD_XCHG && wr_cmdex == `CMDEX_XCHG_modregrm;
wire cond_2 = wr_dst_is_memory && ~(write_for_wr_ready);
wire cond_3 = wr_cmd == `CMD_XCHG && wr_cmdex == `CMDEX_XCHG_modregrm_LAST;
wire cond_4 = wr_cmd == `CMD_int_2  && wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_2;
wire cond_5 = wr_cmd == `CMD_int_2  && wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_3;
wire cond_6 = wr_cmd == `CMD_int_2 && ( wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_4 || wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_5 || wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_6 || wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_7 || wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_8 || wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_9);
wire cond_7 = ~(write_for_wr_ready);
wire cond_8 = ~(wr_new_push_ss_fault);
wire cond_9 = wr_cmd == `CMD_int_3 && ( wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_0 || wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_1 || wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_2 || wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_3);
wire cond_10 = (wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_2 && ~(exc_push_error)) || wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_3;
wire cond_11 = wr_cmd == `CMD_int && wr_cmdex == `CMDEX_int_STEP_0;
wire cond_12 = wr_cmd == `CMD_int && wr_cmdex == `CMDEX_int_STEP_1;
wire cond_13 = wr_cmd == `CMD_int && (wr_cmdex == `CMDEX_int_real_STEP_3 || wr_cmdex == `CMDEX_int_real_STEP_4);
wire cond_14 = wr_cmd == `CMD_int && wr_cmdex == `CMDEX_int_real_STEP_5;
wire cond_15 = wr_cmd == `CMD_int && (wr_cmdex == `CMDEX_int_protected_STEP_0 || wr_cmdex == `CMDEX_int_protected_STEP_1 || wr_cmdex == `CMDEX_int_protected_STEP_2);
wire cond_16 = wr_cmd == `CMD_int_2 && wr_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_5;
wire cond_17 = wr_cmd == `CMD_int_3 && wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_6;
wire cond_18 = v8086_mode;
wire cond_19 = wr_cmd == `CMD_int && (wr_cmdex == `CMDEX_int_real_STEP_0 || wr_cmdex == `CMDEX_int_real_STEP_1 || wr_cmdex == `CMDEX_int_real_STEP_2);
wire cond_20 = ~(wr_push_ss_fault);
wire cond_21 = wr_cmd == `CMD_IRET && wr_cmdex <= `CMDEX_IRET_real_v86_STEP_2;
wire cond_22 = wr_cmdex == `CMDEX_IRET_real_v86_STEP_0;
wire cond_23 = wr_cmd == `CMD_IRET && wr_cmdex == `CMDEX_IRET_real_v86_STEP_3;
wire cond_24 = real_mode;
wire cond_25 = wr_operand_32bit;
wire cond_26 = wr_cmd == `CMD_IRET && (wr_cmdex == `CMDEX_IRET_protected_STEP_0 || wr_cmdex == `CMDEX_IRET_task_switch_STEP_0 || wr_cmdex == `CMDEX_IRET_task_switch_STEP_1);
wire cond_27 = wr_cmd == `CMD_IRET && wr_cmdex >= `CMDEX_IRET_protected_STEP_1 && wr_cmdex <= `CMDEX_IRET_protected_STEP_3;
wire cond_28 = wr_cmd == `CMD_IRET && wr_cmdex >= `CMDEX_IRET_protected_to_v86_STEP_0 && wr_cmdex <= `CMDEX_IRET_protected_to_v86_STEP_4;
wire cond_29 = wr_cmd == `CMD_IRET && wr_cmdex == `CMDEX_IRET_protected_to_v86_STEP_5;
wire cond_30 = wr_cmd == `CMD_IRET_2 && wr_cmdex == `CMDEX_IRET_2_protected_to_v86_STEP_6;
wire cond_31 = wr_cmd == `CMD_IRET_2 && wr_cmdex == `CMDEX_IRET_2_protected_same_STEP_1;
wire cond_32 = cpl <= iopl;
wire cond_33 = cpl == 2'd0;
wire cond_34 = wr_cmd == `CMD_IRET_2 && wr_cmdex >= `CMDEX_IRET_2_protected_outer_STEP_0 && wr_cmdex <= `CMDEX_IRET_2_protected_outer_STEP_2;
wire cond_35 = wr_cmd == `CMD_IRET_2 && wr_cmdex == `CMDEX_IRET_2_protected_outer_STEP_4;
wire cond_36 = wr_task_rpl <= iopl;
wire cond_37 = wr_task_rpl == 2'd0;
wire cond_38 = wr_cmd == `CMD_CLI;
wire cond_39 = wr_cmd == `CMD_STI;
wire cond_40 = iflag == `FALSE;
wire cond_41 = wr_cmd == `CMD_PUSHA;
wire cond_42 = wr_cmdex[2:0] == 3'd0;
wire cond_43 = wr_cmdex[2:0] < 3'd7;
wire cond_44 = wr_cmdex[2:0] == 3'd7 && write_for_wr_ready && ~(wr_push_ss_fault);
wire cond_45 = wr_cmd == `CMD_SCAS;
wire cond_46 = ~(wr_string_ignore);
wire cond_47 = wr_prefix_group_1_rep != 2'd0;
wire cond_48 = wr_string_ignore || wr_string_zf_finish;
wire cond_49 = ~(wr_string_ignore) && ~(wr_string_zf_finish) && wr_prefix_group_1_rep != 2'd0;
wire cond_50 = wr_cmd == `CMD_PUSH;
wire cond_51 = write_for_wr_ready && ~(wr_push_ss_fault);
wire cond_52 = wr_cmd == `CMD_ARPL;
wire cond_53 = result_signals[0];
wire cond_54 = wr_cmd == `CMD_RET_near && wr_cmdex != `CMDEX_RET_near_LAST;
wire cond_55 = (wr_cmd == `CMD_MOV_to_seg || wr_cmd == `CMD_LLDT || wr_cmd == `CMD_LTR) && wr_cmdex == `CMDEX_MOV_to_seg_LLDT_LTR_STEP_1;
wire cond_56 = (wr_cmd == `CMD_MOV_to_seg || wr_cmd == `CMD_LLDT || wr_cmd == `CMD_LTR) && wr_cmdex == `CMDEX_MOV_to_seg_LLDT_LTR_STEP_LAST;
wire cond_57 = wr_cmd == `CMD_MOV_to_seg && wr_decoder[13:11] == `SEGMENT_SS;
wire cond_58 = wr_cmd == `CMD_CPUID;
wire cond_59 = eax == 32'd0;
wire cond_60 = eax != 32'd0;
wire cond_61 = wr_cmd == `CMD_CMPXCHG;
wire cond_62 = wr_cmd == `CMD_LODS;
wire cond_63 = wr_string_ignore || wr_string_finish;
wire cond_64 = ~(wr_string_ignore) && ~(wr_string_finish) && wr_prefix_group_1_rep != 2'd0;
wire cond_65 = wr_cmd == `CMD_SETcc;
wire cond_66 = wr_cmd == `CMD_Shift;
wire cond_67 = ~(result_signals[4]);
wire cond_68 = result_signals[3];
wire cond_69 = result_signals[2];
wire cond_70 = wr_cmd == `CMD_INC_DEC;
wire cond_71 = wr_cmd == `CMD_PUSH_MOV_SEG && { wr_cmdex[3], 3'b0 } == `CMDEX_PUSH_MOV_SEG_implicit;
wire cond_72 = wr_cmd == `CMD_PUSH_MOV_SEG && { wr_cmdex[3], 3'b0 } == `CMDEX_PUSH_MOV_SEG_modregrm;
wire cond_73 = wr_cmd == `CMD_WBINVD && wr_cmdex == `CMDEX_WBINVD_STEP_0;
wire cond_74 = wr_cmd == `CMD_WBINVD && wr_cmdex == `CMDEX_WBINVD_STEP_1;
wire cond_75 = (wr_cmd == `CMD_SGDT || wr_cmd == `CMD_SIDT);
wire cond_76 = wr_cmdex == `CMDEX_SGDT_SIDT_STEP_1;
wire cond_77 = wr_cmdex == `CMDEX_SGDT_SIDT_STEP_2;
wire cond_78 = wr_cmd == `CMD_POPF && wr_cmdex == `CMDEX_POPF_STEP_0;
wire cond_79 = (protected_mode && cpl == 2'd0) || real_mode;
wire cond_80 = (protected_mode && cpl <= iopl) || v8086_mode || real_mode;
wire cond_81 = wr_cmd == `CMD_Jcc;
wire cond_82 = wr_cmd == `CMD_INS;
wire cond_83 = wr_cmdex == `CMDEX_INS_real_1 || wr_cmdex == `CMDEX_INS_protected_1;
wire cond_84 = wr_string_finish || wr_prefix_group_1_rep == 2'd0;
wire cond_85 = wr_string_ignore;
wire cond_86 = wr_cmd == `CMD_CLC;
wire cond_87 = wr_cmd == `CMD_CMC;
wire cond_88 = wr_cmd == `CMD_CLD;
wire cond_89 = wr_cmd == `CMD_STC;
wire cond_90 = wr_cmd == `CMD_STD;
wire cond_91 = wr_cmd == `CMD_SAHF;
wire cond_92 = wr_cmd == `CMD_IMUL;
wire cond_93 = wr_dst_is_edx_eax;
wire cond_94 = ~(wr_is_8bit);
wire cond_95 = wr_cmd == `CMD_LEA;
wire cond_96 = wr_cmd == `CMD_MOVSX || wr_cmd == `CMD_MOVZX;
wire cond_97 = wr_cmd == `CMD_MOVS;
wire cond_98 = ~(wr_string_es_fault);
wire cond_99 = wr_string_finish;
wire cond_100 = wr_cmd == `CMD_INVD && wr_cmdex == `CMDEX_INVD_STEP_0;
wire cond_101 = wr_cmd == `CMD_INVD && wr_cmdex == `CMDEX_INVD_STEP_1;
wire cond_102 = wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_STEP_1;
wire cond_103 = wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_STEP_2;
wire cond_104 = wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_real_STEP_3;
wire cond_105 = wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_outer_STEP_3;
wire cond_106 = wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_outer_STEP_4;
wire cond_107 = wr_cmd == `CMD_AAA || wr_cmd == `CMD_AAS;
wire cond_108 = wr_cmd == `CMD_DAA || wr_cmd == `CMD_DAS;
wire cond_109 = wr_cmd == `CMD_STOS;
wire cond_110 = wr_cmd == `CMD_JCXZ;
wire cond_111 = wr_cmd == `CMD_XLAT;
wire cond_112 = wr_cmd == `CMD_BOUND && wr_cmdex == `CMDEX_BOUND_STEP_FIRST;
wire cond_113 = wr_cmd == `CMD_MOV;
wire cond_114 = wr_cmd == `CMD_MUL;
wire cond_115 = wr_cmd == `CMD_debug_reg && wr_cmdex == `CMDEX_debug_reg_MOV_store_STEP_0;
wire cond_116 = wr_cmd == `CMD_debug_reg && wr_cmdex == `CMDEX_debug_reg_MOV_load_STEP_0;
wire cond_117 = wr_decoder[13:11] == 3'd0;
wire cond_118 = wr_decoder[13:11] == 3'd1;
wire cond_119 = wr_decoder[13:11] == 3'd2;
wire cond_120 = wr_decoder[13:11] == 3'd3;
wire cond_121 = (wr_decoder[13:11] == 3'd4 || wr_decoder[13:11] == 3'd6);
wire cond_122 = (wr_decoder[13:11] == 3'd5 || wr_decoder[13:11] == 3'd7);
wire cond_123 = wr_cmd == `CMD_debug_reg && wr_cmdex == `CMDEX_debug_reg_MOV_load_STEP_1;
wire cond_124 = wr_cmd == `CMD_control_reg && wr_cmdex == `CMDEX_control_reg_SMSW_STEP_0;
wire cond_125 = wr_cmd == `CMD_control_reg && wr_cmdex == `CMDEX_control_reg_LMSW_STEP_0;
wire cond_126 = cr0_pe ^ result2[0];
wire cond_127 = wr_cmd == `CMD_control_reg && wr_cmdex == `CMDEX_control_reg_MOV_store_STEP_0;
wire cond_128 = wr_cmd == `CMD_control_reg && wr_cmdex == `CMDEX_control_reg_MOV_load_STEP_0;
wire cond_129 = (cr0_pe ^ result2[0]) || (cr0_wp ^ result2[16]) || (cr0_pg ^ result[31]);
wire cond_130 = cr0_pe && result2[0] == 1'b0;
wire cond_131 = wr_cmd == `CMD_LOOP;
wire cond_132 = wr_address_16bit;
wire cond_133 = wr_cmd == `CMD_NOT;
wire cond_134 = (wr_cmd == `CMD_LGDT || wr_cmd == `CMD_LIDT);
wire cond_135 = wr_cmdex == `CMDEX_LGDT_LIDT_STEP_1;
wire cond_136 = wr_cmd == `CMD_LGDT;
wire cond_137 = wr_cmd == `CMD_LIDT;
wire cond_138 = wr_cmdex == `CMDEX_LGDT_LIDT_STEP_2;
wire cond_139 = { wr_cmd[6:2], 2'd0 } == `CMD_BTx;
wire cond_140 = wr_cmd[1:0] != 2'd0;
wire cond_141 = wr_cmd == `CMD_SALC && wr_cmdex == `CMDEX_SALC_STEP_0;
wire cond_142 = cflag;
wire cond_143 = wr_cmd == `CMD_LAHF;
wire cond_144 = wr_cmd == `CMD_CBW;
wire cond_145 = wr_cmd == `CMD_CWD;
wire cond_146 = { wr_cmd[6:1], 1'd0 } == `CMD_BSx;
wire cond_147 = wr_cmd == `CMD_JMP && (wr_cmdex == `CMDEX_JMP_Jv_STEP_0 || wr_cmdex == `CMDEX_JMP_Ev_STEP_0);
wire cond_148 = wr_cmd == `CMD_JMP && (wr_cmdex == `CMDEX_JMP_Ev_Jv_STEP_1 || wr_cmdex == `CMDEX_JMP_real_v8086_STEP_1);
wire cond_149 = wr_cmd == `CMD_JMP && (wr_cmdex == `CMDEX_JMP_Ep_STEP_0 || wr_cmdex == `CMDEX_JMP_Ap_STEP_0 ||  +  wr_cmdex == `CMDEX_JMP_Ep_STEP_1 || wr_cmdex == `CMDEX_JMP_Ap_STEP_1);
wire cond_150 = wr_cmd == `CMD_JMP && wr_cmdex == `CMDEX_JMP_real_v8086_STEP_0;
wire cond_151 = wr_cmd == `CMD_JMP && wr_cmdex == `CMDEX_JMP_task_switch_STEP_0;
wire cond_152 = wr_cmd == `CMD_JMP_2 && wr_cmdex == `CMDEX_JMP_2_call_gate_STEP_0;
wire cond_153 = wr_cmd == `CMD_JMP_2 && wr_cmdex == `CMDEX_JMP_2_call_gate_STEP_1;
wire cond_154 = wr_cmd == `CMD_INVLPG && wr_cmdex == `CMDEX_INVLPG_STEP_0;
wire cond_155 = wr_cmd == `CMD_INVLPG && wr_cmdex == `CMDEX_INVLPG_STEP_1;
wire cond_156 = (wr_cmd == `CMD_LAR || wr_cmd == `CMD_LSL || wr_cmd == `CMD_VERR || wr_cmd == `CMD_VERW) && (wr_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_1 || wr_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_2);
wire cond_157 = (wr_cmd == `CMD_LAR || wr_cmd == `CMD_LSL) && wr_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_LAST;
wire cond_158 = wr_dst_is_reg;
wire cond_159 = (wr_cmd == `CMD_VERR || wr_cmd == `CMD_VERW) && wr_cmdex == `CMDEX_LAR_LSL_VERR_VERW_STEP_LAST;
wire cond_160 = { wr_cmd[6:3], 3'd0 } == `CMD_Arith;
wire cond_161 = wr_cmd[2:0] != 3'b111 && wr_dst_is_memory && ~(write_for_wr_ready);
wire cond_162 = wr_cmd[2:0] != 3'b111;
wire cond_163 = wr_cmd == `CMD_CLTS;
wire cond_164 = wr_cmd == `CMD_PUSHF;
wire cond_165 = wr_cmd == `CMD_XADD && wr_cmdex == `CMDEX_XADD_FIRST;
wire cond_166 = wr_cmd == `CMD_XADD && wr_cmdex == `CMDEX_XADD_LAST;
wire cond_167 = wr_modregrm_mod != 2'b11 || wr_modregrm_reg != wr_modregrm_rm;
wire cond_168 = wr_cmd == `CMD_POP_seg && wr_cmdex == `CMDEX_POP_seg_STEP_1;
wire cond_169 = wr_cmd == `CMD_POP_seg && wr_cmdex == `CMDEX_POP_seg_STEP_LAST;
wire cond_170 = wr_decoder[5:3] == `SEGMENT_SS;
wire cond_171 = wr_cmd == `CMD_NEG;
wire cond_172 = wr_cmd == `CMD_LEAVE;
wire cond_173 = wr_cmd == `CMD_POP && wr_cmdex == `CMDEX_POP_implicit;
wire cond_174 = wr_cmd == `CMD_POP && wr_cmdex == `CMDEX_POP_modregrm_STEP_0;
wire cond_175 = wr_cmd == `CMD_POP && wr_cmdex == `CMDEX_POP_modregrm_STEP_1;
wire cond_176 = ~(wr_dst_is_memory) || write_for_wr_ready;
wire cond_177 = wr_cmd == `CMD_io_allow && (wr_cmdex == `CMDEX_io_allow_1 || wr_cmdex == `CMDEX_io_allow_2);
wire cond_178 = wr_cmd == `CMD_TEST;
wire cond_179 = { wr_cmd[6:1], 1'd0 } == `CMD_SHxD;
wire cond_180 = wr_cmd == `CMD_AAM || wr_cmd == `CMD_AAD;
wire cond_181 = wr_cmd == `CMD_CALL && (wr_cmdex == `CMDEX_CALL_Ep_STEP_0 || wr_cmdex == `CMDEX_CALL_Ap_STEP_0);
wire cond_182 = wr_cmd == `CMD_CALL && (wr_cmdex == `CMDEX_CALL_Ep_STEP_1 || wr_cmdex == `CMDEX_CALL_Ap_STEP_1);
wire cond_183 = wr_cmd == `CMD_CALL && (wr_cmdex == `CMDEX_CALL_real_v8086_STEP_0 || wr_cmdex == `CMDEX_CALL_real_v8086_STEP_1);
wire cond_184 = wr_cmd == `CMD_CALL && (wr_cmdex == `CMDEX_CALL_Ev_STEP_0 || wr_cmdex == `CMDEX_CALL_Jv_STEP_0);
wire cond_185 = wr_cmd == `CMD_CALL && (wr_cmdex == `CMDEX_CALL_Ev_Jv_STEP_1 || wr_cmdex == `CMDEX_CALL_real_v8086_STEP_3);
wire cond_186 = wr_cmd == `CMD_CALL && wr_cmdex == `CMDEX_CALL_real_v8086_STEP_2;
wire cond_187 = wr_cmd == `CMD_CALL && (wr_cmdex == `CMDEX_CALL_protected_seg_STEP_0 || wr_cmdex == `CMDEX_CALL_protected_seg_STEP_1);
wire cond_188 = wr_cmd == `CMD_CALL && wr_cmdex == `CMDEX_CALL_protected_seg_STEP_2;
wire cond_189 = wr_cmd == `CMD_CALL_2 && wr_cmdex == `CMDEX_CALL_2_task_switch_STEP_0;
wire cond_190 = wr_cmd == `CMD_CALL_2 && (wr_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_2 || wr_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_3);
wire cond_191 = wr_cmd == `CMD_CALL_3 && ( wr_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_4 || wr_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_5 || wr_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_6 || wr_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_7);
wire cond_192 = wr_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_7;
wire cond_193 = wr_cmd == `CMD_IN;
wire cond_194 = ~(io_allow_check_needed) || wr_cmdex == `CMDEX_IN_protected;
wire cond_195 = wr_cmd == `CMD_task_switch && wr_cmdex == `CMDEX_task_switch_STEP_1;
wire cond_196 = wr_cmd == `CMD_task_switch && (wr_cmdex == `CMDEX_task_switch_STEP_2 || wr_cmdex == `CMDEX_task_switch_STEP_3 || wr_cmdex == `CMDEX_task_switch_STEP_4 || wr_cmdex == `CMDEX_task_switch_STEP_5);
wire cond_197 = wr_cmd == `CMD_task_switch && wr_cmdex == `CMDEX_task_switch_STEP_6;
wire cond_198 = glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_JUMP || glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_IRET;
wire cond_199 = wr_cmd == `CMD_task_switch && (wr_cmdex == `CMDEX_task_switch_STEP_7 || wr_cmdex == `CMDEX_task_switch_STEP_8);
wire cond_200 = wr_cmd == `CMD_task_switch && wr_cmdex == `CMDEX_task_switch_STEP_9;
wire cond_201 = wr_cmd == `CMD_task_switch && wr_cmdex == `CMDEX_task_switch_STEP_10;
wire cond_202 = wr_cmd == `CMD_task_switch_2 && wr_cmdex <= `CMDEX_task_switch_2_STEP_13;
wire cond_203 = tr_cache[`DESC_BITS_TYPE] > 4'd3 || wr_cmdex <= `CMDEX_task_switch_2_STEP_11;
wire cond_204 = wr_cmd == `CMD_task_switch && wr_cmdex == `CMDEX_task_switch_STEP_11;
wire cond_205 = glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_CALL || glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_INT;
wire cond_206 = wr_cmd == `CMD_task_switch && wr_cmdex >= `CMDEX_task_switch_STEP_12 && wr_cmdex <= `CMDEX_task_switch_STEP_14;
wire cond_207 = wr_cmd == `CMD_task_switch_3;
wire cond_208 = wr_cmd == `CMD_task_switch_4 && wr_cmdex == `CMDEX_task_switch_4_STEP_0;
wire cond_209 = glob_param_1[`TASK_SWITCH_SOURCE_BITS] != `TASK_SWITCH_FROM_IRET;
wire cond_210 = wr_cmd == `CMD_task_switch_4 && wr_cmdex == `CMDEX_task_switch_4_STEP_1;
wire cond_211 = glob_descriptor[`DESC_BITS_TYPE] >= 4'd9 && cr0_pg && cr3 != exe_buffer_shifted[463:432];
wire cond_212 = wr_cmd == `CMD_task_switch_4 && wr_cmdex == `CMDEX_task_switch_4_STEP_2;
wire cond_213 = glob_param_2[2:0] == 3'b000;
wire cond_214 = wr_cmd == `CMD_task_switch_4 && wr_cmdex >= `CMDEX_task_switch_4_STEP_3 && wr_cmdex <= `CMDEX_task_switch_4_STEP_8;
wire cond_215 = wr_cmdex == `CMDEX_task_switch_4_STEP_3;
wire cond_216 = glob_param_2[1:0] == 2'b00 && ~(v8086_mode) && `DESC_IS_NOT_ACCESSED(glob_descriptor);
wire cond_217 = wr_cmdex == `CMDEX_task_switch_4_STEP_4;
wire cond_218 = wr_cmdex == `CMDEX_task_switch_4_STEP_5;
wire cond_219 = wr_cmdex == `CMDEX_task_switch_4_STEP_6;
wire cond_220 = wr_cmdex == `CMDEX_task_switch_4_STEP_7;
wire cond_221 = glob_param_2[1:0] == 2'b00 && `DESC_IS_ACCESSED(glob_descriptor);
wire cond_222 = glob_param_2[1:0] != 2'b00;
wire cond_223 = wr_cmd == `CMD_task_switch_4 && wr_cmdex == `CMDEX_task_switch_4_STEP_9;
wire cond_224 = glob_param_3[16];
wire cond_225 = wr_cmd == `CMD_task_switch_4 && wr_cmdex == `CMDEX_task_switch_4_STEP_10;
wire cond_226 = glob_param_3[17] && task_trap[0];
wire cond_227 = wr_cmd == `CMD_POPA;
wire cond_228 = wr_cmdex[2:0] == 3'd7;
wire cond_229 = wr_cmd == `CMD_OUTS;
wire cond_230 = io_allow_check_needed && wr_cmdex == `CMDEX_OUTS_first;
wire cond_231 = ~(write_io_for_wr_ready);
wire cond_232 = wr_cmd == `CMD_LxS && wr_cmdex != `CMDEX_LxS_STEP_LAST;
wire cond_233 = wr_cmd == `CMD_LxS && wr_cmdex == `CMDEX_LxS_STEP_LAST;
wire cond_234 = wr_cmd == `CMD_IDIV || wr_cmd == `CMD_DIV;
wire cond_235 = wr_cmd == `CMD_load_seg && wr_cmdex == `CMDEX_load_seg_STEP_1;
wire cond_236 = protected_mode && glob_param_1[15:2] == 14'd0;
wire cond_237 = wr_cmd == `CMD_load_seg && wr_cmdex == `CMDEX_load_seg_STEP_2;
wire cond_238 = ~(protected_mode && (glob_param_1[15:2] == 14'd0 || glob_param_1[`MC_PARAM_1_FLAG_NO_WRITE_BIT]));
wire cond_239 = glob_param_1[18:16] == `SEGMENT_TR || (glob_param_1[18:16] < `SEGMENT_LDT && `DESC_IS_NOT_ACCESSED(glob_descriptor));
wire cond_240 = glob_param_1[18:16] == `SEGMENT_TR;
wire cond_241 = glob_param_1[18:16] == `SEGMENT_LDT || (glob_param_1[18:16] < `SEGMENT_LDT && `DESC_IS_ACCESSED(glob_descriptor));
wire cond_242 = wr_cmd == `CMD_BSWAP;
wire cond_243 = wr_cmd == `CMD_OUT;
wire cond_244 = ~(io_allow_check_needed) || wr_cmdex == `CMDEX_OUT_protected;
wire cond_245 = wr_cmd == `CMD_HLT && wr_cmdex == `CMDEX_HLT_STEP_0;
wire cond_246 = wr_cmd == `CMD_INT_INTO && wr_cmdex == `CMDEX_INT_INTO_INT_STEP_0;
wire cond_247 = wr_cmd == `CMD_INT_INTO && wr_cmdex == `CMDEX_INT_INTO_INT3_STEP_0;
wire cond_248 = wr_cmd == `CMD_INT_INTO && wr_cmdex == `CMDEX_INT_INTO_INT1_STEP_0;
wire cond_249 = wr_cmd == `CMD_INT_INTO && wr_cmdex == `CMDEX_INT_INTO_INTO_STEP_0;
wire cond_250 = oflag;
wire cond_251 = (wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_same_STEP_3) || (wr_cmd == `CMD_IRET_2  && wr_cmdex == `CMDEX_IRET_2_protected_same_STEP_0) || (wr_cmd == `CMD_CALL_2  && wr_cmdex == `CMDEX_CALL_2_protected_seg_STEP_3) || (wr_cmd == `CMD_CALL_2  && wr_cmdex == `CMDEX_CALL_2_call_gate_same_STEP_2) || (wr_cmd == `CMD_JMP     && wr_cmdex == `CMDEX_JMP_protected_seg_STEP_0) || (wr_cmd == `CMD_JMP_2   && wr_cmdex == `CMDEX_JMP_2_call_gate_STEP_2) || (wr_cmd == `CMD_int_2   && wr_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_4);
wire cond_252 = `DESC_IS_NOT_ACCESSED(glob_descriptor);
wire cond_253 = wr_cmd != `CMD_JMP && wr_cmd != `CMD_JMP_2 && wr_cmd != `CMD_int_2;
wire cond_254 = (wr_cmd == `CMD_CALL_3 && wr_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_9) || (wr_cmd == `CMD_int_3  && wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_4);
wire cond_255 = (wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_same_STEP_4) || (wr_cmd == `CMD_CALL_2  && wr_cmdex == `CMDEX_CALL_2_protected_seg_STEP_4) || (wr_cmd == `CMD_CALL_2  && wr_cmdex == `CMDEX_CALL_2_call_gate_same_STEP_3) || (wr_cmd == `CMD_CALL_3  && wr_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_10) || (wr_cmd == `CMD_JMP     && wr_cmdex == `CMDEX_JMP_protected_seg_STEP_1) || (wr_cmd == `CMD_JMP_2   && wr_cmdex == `CMDEX_JMP_2_call_gate_STEP_3);
wire cond_256 = (wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_outer_STEP_5) || (wr_cmd == `CMD_IRET_2  && wr_cmdex == `CMDEX_IRET_2_protected_outer_STEP_3);
wire cond_257 = (wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_outer_STEP_6) || (wr_cmd == `CMD_IRET_2  && wr_cmdex == `CMDEX_IRET_2_protected_outer_STEP_5) || (wr_cmd == `CMD_CALL_3  && wr_cmdex == `CMDEX_CALL_3_call_gate_more_STEP_8) || (wr_cmd == `CMD_int_3   && wr_cmdex == `CMDEX_int_3_int_trap_gate_more_STEP_5);
wire cond_258 = `DESC_IS_NOT_ACCESSED(glob_descriptor) && glob_param_1[15:2] != 14'd0;
wire cond_259 = (wr_cmd == `CMD_RET_far && wr_cmdex == `CMDEX_RET_far_outer_STEP_7) ||  + (wr_cmd == `CMD_IRET_2 && wr_cmdex == `CMDEX_IRET_2_protected_outer_STEP_6);
wire cond_260 = (wr_cmd == `CMD_CALL && (wr_cmdex == `CMDEX_CALL_protected_STEP_0 || wr_cmdex == `CMDEX_CALL_protected_STEP_1)) || (wr_cmd == `CMD_JMP  && (wr_cmdex == `CMDEX_JMP_protected_STEP_0  || wr_cmdex == `CMDEX_JMP_protected_STEP_1));
wire cond_261 = (wr_cmd == `CMD_CALL_2 && wr_cmdex == `CMDEX_CALL_2_task_gate_STEP_0) || (wr_cmd == `CMD_JMP    && wr_cmdex == `CMDEX_JMP_task_gate_STEP_0) || (wr_cmd == `CMD_int    && wr_cmdex == `CMDEX_int_task_gate_STEP_0);
wire cond_262 = (wr_cmd == `CMD_CALL_2 && wr_cmdex == `CMDEX_CALL_2_task_gate_STEP_1) || (wr_cmd == `CMD_JMP    && wr_cmdex == `CMDEX_JMP_task_gate_STEP_1) || (wr_cmd == `CMD_int    && wr_cmdex == `CMDEX_int_task_gate_STEP_1);
wire cond_263 = (wr_cmd == `CMD_CALL_2 && wr_cmdex == `CMDEX_CALL_2_call_gate_STEP_0) || (wr_cmd == `CMD_int    && wr_cmdex == `CMDEX_int_int_trap_gate_STEP_0);
wire cond_264 = (wr_cmd == `CMD_CALL_2 && wr_cmdex == `CMDEX_CALL_2_call_gate_STEP_1) || (wr_cmd == `CMD_int    && wr_cmdex == `CMDEX_int_int_trap_gate_STEP_1);
wire cond_265 = (wr_cmd == `CMD_CALL_2 && wr_cmdex == `CMDEX_CALL_2_call_gate_STEP_2) || (wr_cmd == `CMD_int    && wr_cmdex == `CMDEX_int_int_trap_gate_STEP_2);
wire cond_266 = (wr_cmd == `CMD_CALL_2 && (wr_cmdex == `CMDEX_CALL_2_call_gate_same_STEP_0 || wr_cmdex == `CMDEX_CALL_2_call_gate_same_STEP_1)) || (wr_cmd == `CMD_int_2 && (wr_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_0 || wr_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_1 || wr_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_2 || wr_cmdex == `CMDEX_int_2_int_trap_gate_same_STEP_3));
wire cond_267 = (wr_cmd == `CMD_CALL_2 && wr_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_0) || (wr_cmd == `CMD_int_2  && wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_0);
wire cond_268 = (wr_cmd == `CMD_CALL_2 && wr_cmdex == `CMDEX_CALL_2_call_gate_more_STEP_1) || (wr_cmd == `CMD_int_2  && wr_cmdex == `CMDEX_int_2_int_trap_gate_more_STEP_1);
wire cond_269 = wr_cmd == `CMD_CMPS && wr_cmdex == `CMDEX_CMPS_FIRST;
wire cond_270 = wr_cmd == `CMD_CMPS && wr_cmdex == `CMDEX_CMPS_LAST;
wire cond_271 = wr_string_ignore || wr_string_zf_finish || wr_prefix_group_1_rep == 2'd0;
wire cond_272 = wr_cmd == `CMD_ENTER && wr_cmdex == `CMDEX_ENTER_FIRST;
wire cond_273 = wr_cmd == `CMD_ENTER && wr_cmdex == `CMDEX_ENTER_LAST;
wire cond_274 = wr_cmd == `CMD_ENTER && (wr_cmdex == `CMDEX_ENTER_PUSH || wr_cmdex == `CMDEX_ENTER_LOOP);
//======================================================== saves
assign zflag_to_reg =
    (cond_23)? (  glob_param_3[6]) :
    (cond_29)? (  glob_param_3[6]) :
    (cond_31)? (  glob_param_3[6]) :
    (cond_35)? (  glob_param_5[6]) :
    (cond_45 && cond_46)? ( zflag_result) :
    (cond_52 && cond_53)? ( `TRUE) :
    (cond_52 && ~cond_53)? ( `FALSE) :
    (cond_61 && cond_53)? ( `TRUE) :
    (cond_61 && ~cond_53)? ( zflag_result) :
    (cond_66 && cond_68)? ( zflag_result) :
    (cond_70)? ( zflag_result) :
    (cond_78)? (  result2[6]) :
    (cond_91)? ( eax[14]) :
    (cond_92)? ( zflag_result) :
    (cond_107)? ( zflag_result) :
    (cond_108)? ( zflag_result) :
    (cond_114)? ( zflag_result) :
    (cond_146 && cond_53)? ( `TRUE) :
    (cond_146 && ~cond_53)? ( `FALSE) :
    (cond_157 && cond_158)? ( `TRUE) :
    (cond_157 && ~cond_158)? ( `FALSE) :
    (cond_159)? ( wr_dst_is_reg) :
    (cond_160)? ( zflag_result) :
    (cond_165)? ( zflag_result) :
    (cond_171)? ( zflag_result) :
    (cond_178)? ( zflag_result) :
    (cond_179 && cond_68)? ( zflag_result) :
    (cond_180)? ( zflag_result) :
    (cond_210)? (  task_eflags[6]) :
    (cond_270 && cond_46)? ( zflag_result) :
    zflag;
assign gdtr_limit_to_reg =
    (cond_134 && cond_136 && cond_135)? ( result2[15:0]) :
    gdtr_limit;
assign esp_to_reg =
    (cond_9 && cond_8 && cond_10)? ( wr_new_stack_esp) :
    (cond_19 && cond_20)? ( wr_stack_esp) :
    (cond_21)? ( wr_stack_esp) :
    (cond_29)? ( exe_buffer_shifted[159:128]) :
    (cond_41 && cond_20)? ( wr_stack_esp) :
    (cond_50 && cond_51)? ( wr_stack_esp) :
    (cond_54)? ( wr_stack_esp) :
    (cond_71 && cond_51)? ( wr_stack_esp) :
    (cond_78)? ( wr_stack_esp) :
    (cond_102)? ( wr_stack_esp) :
    (cond_104)? ( wr_stack_esp) :
    (cond_164 && cond_51)? ( wr_stack_esp) :
    (cond_168)? ( wr_stack_esp) :
    (cond_172)? ( wr_stack_esp) :
    (cond_173)? ( wr_stack_esp) :
    (cond_174)? ( wr_stack_esp) :
    (cond_183 && cond_20)? ( wr_stack_esp) :
    (cond_184 && cond_20)? ( wr_stack_esp) :
    (cond_187 && cond_8)? ( wr_new_stack_esp) :
    (cond_191 && cond_8 && cond_192)? ( wr_new_stack_esp) :
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'hFFFF, exe_buffer_shifted[223:208] } : exe_buffer_shifted[239:208]) :
    (cond_223 && cond_224 && cond_20)? ( wr_stack_esp) :
    (cond_227)? ( wr_stack_esp) :
    (cond_251 && cond_252 && ~cond_7 && cond_253)? ( wr_stack_esp) :
    (cond_251 && ~cond_252 && cond_253)? ( wr_stack_esp) :
    (cond_259)? ( wr_stack_esp) :
    (cond_266 && cond_20)? ( wr_stack_esp) :
    (cond_272)? ( wr_stack_esp) :
    (cond_273)? ( wr_stack_esp) :
    (cond_274 && cond_20)? ( wr_stack_esp) :
    esp;
assign pflag_to_reg =
    (cond_23)? (  glob_param_3[2]) :
    (cond_29)? (  glob_param_3[2]) :
    (cond_31)? (  glob_param_3[2]) :
    (cond_35)? (  glob_param_5[2]) :
    (cond_45 && cond_46)? ( pflag_result) :
    (cond_61 && cond_53)? ( `TRUE) :
    (cond_61 && ~cond_53)? ( pflag_result) :
    (cond_66 && cond_68)? ( pflag_result) :
    (cond_70)? ( pflag_result) :
    (cond_78)? (  result2[2]) :
    (cond_91)? ( eax[10]) :
    (cond_92)? ( pflag_result) :
    (cond_107)? ( pflag_result) :
    (cond_108)? ( pflag_result) :
    (cond_114)? ( pflag_result) :
    (cond_146 && ~cond_53)? ( pflag_result) :
    (cond_160)? ( pflag_result) :
    (cond_165)? ( pflag_result) :
    (cond_171)? ( pflag_result) :
    (cond_178)? ( pflag_result) :
    (cond_179 && cond_68)? ( pflag_result) :
    (cond_180)? ( pflag_result) :
    (cond_210)? (  task_eflags[2]) :
    (cond_270 && cond_46)? ( pflag_result) :
    pflag;
assign es_rpl_to_reg =
    (cond_29)? ( 2'd3) :
    (cond_210)? (            task_es[1:0]) :
    es_rpl;
assign dr6_breakpoints_to_reg =
    (cond_116 && cond_121)? ( result2[3:0]) :
    dr6_breakpoints;
assign dr6_bt_to_reg =
    (cond_116 && cond_121)? (     result2[15]) :
    dr6_bt;
assign dr6_bs_to_reg =
    (cond_116 && cond_121)? (     result2[14]) :
    dr6_bs;
assign ds_to_reg =
    (cond_17 && cond_18)? (             16'd0) :
    (cond_29)? ( wr_IRET_to_v86_ds) :
    (cond_210)? (                task_ds) :
    ds;
assign cr0_ts_to_reg =
    (cond_125)? ( result2[3]) :
    (cond_128 && cond_117)? ( result2[3]) :
    (cond_163)? ( `FALSE) :
    (cond_210)? ( `TRUE) :
    cr0_ts;
assign iopl_to_reg =
    (cond_23 && cond_24)? (  glob_param_3[13:12]) :
    (cond_29)? (   glob_param_3[13:12]) :
    (cond_31 && cond_33)? (  glob_param_3[13:12]) :
    (cond_35 && cond_37)? (  glob_param_5[13:12]) :
    (cond_78 && cond_79)? (  result2[13:12]) :
    (cond_210)? (   task_eflags[13:12]) :
    iopl;
assign oflag_to_reg =
    (cond_23)? (  glob_param_3[11]) :
    (cond_29)? (  glob_param_3[11]) :
    (cond_31)? (  glob_param_3[11]) :
    (cond_35)? (  glob_param_5[11]) :
    (cond_45 && cond_46)? ( oflag_arith) :
    (cond_61 && cond_53)? ( `FALSE) :
    (cond_61 && ~cond_53)? ( oflag_arith) :
    (cond_66 && cond_69)? ( result_signals[1]) :
    (cond_70)? ( oflag_arith) :
    (cond_78)? (  result2[11]) :
    (cond_92)? ( wr_mult_overflow) :
    (cond_107)? ( oflag_arith) :
    (cond_108)? ( oflag_arith) :
    (cond_114)? ( wr_mult_overflow) :
    (cond_146 && ~cond_53)? ( oflag_arith) :
    (cond_160)? ( oflag_arith) :
    (cond_165)? ( oflag_arith) :
    (cond_171)? ( oflag_arith) :
    (cond_178)? ( oflag_arith) :
    (cond_179 && cond_69)? ( result_signals[1]) :
    (cond_180)? ( oflag_arith) :
    (cond_210)? (  task_eflags[11]) :
    (cond_270 && cond_46)? ( oflag_arith) :
    oflag;
assign ds_rpl_to_reg =
    (cond_29)? ( 2'd3) :
    (cond_210)? (            task_ds[1:0]) :
    ds_rpl;
assign cr0_pg_to_reg =
    (cond_128 && cond_117)? ( result2[31]) :
    cr0_pg;
assign ecx_to_reg =
    (cond_45 && cond_46 && cond_47)? ( wr_ecx_final) :
    (cond_58 && cond_59)? ( "684O") :
    (cond_58 && cond_60)? ( 32'd0) :
    (cond_62 && cond_46 && cond_47)? ( wr_ecx_final) :
    (cond_82 && ~cond_83 && cond_46 && ~cond_7 && cond_47)? ( wr_ecx_final) :
    (cond_97 && cond_46 && ~cond_7 && cond_47)? ( wr_ecx_final) :
    (cond_109 && cond_46 && ~cond_7 && cond_47)? ( wr_ecx_final) :
    (cond_131 && cond_132)? ( { ecx[31:16], wr_ecx_minus_1[15:0] }) :
    (cond_131 && ~cond_132)? ( wr_ecx_minus_1) :
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'hFFFF, exe_buffer_shifted[319:304] } : exe_buffer_shifted[335:304]) :
    (cond_227 && cond_228)? ( { wr_operand_16bit? ecx[31:16] : exe_buffer_shifted[31:16],   exe_buffer_shifted[15:0] }) :
    (cond_229 && ~cond_230 && cond_46 && ~cond_231 && cond_47)? ( wr_ecx_final) :
    (cond_270 && cond_46 && cond_47)? ( wr_ecx_final) :
    ecx;
assign ss_cache_valid_to_reg =
    (cond_29)? ( `TRUE) :
    (cond_210)? (    `FALSE) :
    ss_cache_valid;
assign cr0_pe_to_reg =
    (cond_125)? ( cr0_pe | result2[0]) :
    (cond_128 && cond_117)? ( result2[0]) :
    cr0_pe;
assign iflag_to_reg =
    (cond_14)? (  `FALSE) :
    (cond_16)? (  (glob_param_1[20] == 1'b0)? `FALSE : iflag) :
    (cond_17)? (  (glob_param_3[20] == 1'b0)? `FALSE : iflag) :
    (cond_23)? (  glob_param_3[9]) :
    (cond_29)? (  glob_param_3[9]) :
    (cond_31 && cond_32)? (  glob_param_3[9]) :
    (cond_35 && cond_36)? (  glob_param_5[9]) :
    (cond_38)? ( `FALSE) :
    (cond_39)? ( `TRUE) :
    (cond_78 && cond_80)? ( result2[9]) :
    (cond_210)? (  task_eflags[9]) :
    iflag;
assign cr2_to_reg =
    (cond_128 && cond_119)? ( result2) :
    cr2;
assign cr3_to_reg =
    (cond_128 && cond_120)? ( result2) :
    (cond_210 && cond_211)? ( exe_buffer_shifted[463:432]) :
    cr3;
assign acflag_to_reg =
    (cond_14)? ( `FALSE) :
    (cond_23 && cond_25)? ( glob_param_3[18]) :
    (cond_29)? ( glob_param_3[18]) :
    (cond_31 && cond_25)? ( glob_param_3[18]) :
    (cond_35 && cond_25)? ( glob_param_5[18]) :
    (cond_78 && cond_25)? ( result2[18]) :
    (cond_210)? ( task_eflags[18]) :
    acflag;
assign rflag_to_reg =
    (cond_14)? (  `FALSE) :
    (cond_16)? (  `FALSE) :
    (cond_17)? (  `FALSE) :
    (cond_23 && cond_25)? (  glob_param_3[16]) :
    (cond_29)? (  glob_param_3[16]) :
    (cond_31 && cond_25)? (  glob_param_3[16]) :
    (cond_35 && cond_25)? (  glob_param_5[16]) :
    (cond_78 && cond_25)? (  result2[16]) :
    (cond_210)? (  task_eflags[16]) :
    rflag;
assign vmflag_to_reg =
    (cond_16)? ( `FALSE) :
    (cond_17)? ( `FALSE) :
    (cond_29)? ( glob_param_3[`EFLAGS_BIT_VM]) :
    (cond_210)? ( task_eflags[17]) :
    vmflag;
assign edi_to_reg =
    (cond_45 && cond_46)? ( wr_edi_final) :
    (cond_82 && ~cond_83 && cond_46 && ~cond_7)? ( wr_edi_final) :
    (cond_97 && cond_46 && ~cond_7)? ( wr_edi_final) :
    (cond_109 && cond_46 && ~cond_7)? ( wr_edi_final) :
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'hFFFF, exe_buffer_shifted[127:112] } : exe_buffer_shifted[143:112]) :
    (cond_227 && cond_228)? ( { wr_operand_16bit? edi[31:16] : exe_buffer_shifted[223:208], exe_buffer_shifted[207:192] }) :
    (cond_270 && cond_46)? ( wr_edi_final) :
    edi;
assign gs_cache_to_reg =
    (cond_29)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0,wr_IRET_to_v86_gs[15:12], wr_IRET_to_v86_gs[11:0],4'd0, 16'hFFFF }) :
    gs_cache;
assign es_to_reg =
    (cond_17 && cond_18)? (             16'd0) :
    (cond_29)? ( wr_IRET_to_v86_es) :
    (cond_210)? (                task_es) :
    es;
assign ss_rpl_to_reg =
    (cond_29)? ( 2'd3) :
    (cond_210)? (            task_ss[1:0]) :
    ss_rpl;
assign es_cache_to_reg =
    (cond_29)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0,wr_IRET_to_v86_es[15:12], wr_IRET_to_v86_es[11:0],4'd0, 16'hFFFF }) :
    es_cache;
assign dr6_b12_to_reg =
    (cond_116 && cond_121)? (    result2[12]) :
    dr6_b12;
assign ss_cache_to_reg =
    (cond_29)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0,wr_IRET_to_v86_ss[15:12], wr_IRET_to_v86_ss[11:0],4'd0, 16'hFFFF }) :
    ss_cache;
assign gdtr_base_to_reg =
    (cond_134 && cond_136 && ~cond_135)? ( wr_operand_32bit? result2 : { 8'd0, result2[23:0] }) :
    gdtr_base;
assign edx_to_reg =
    (cond_58 && cond_59)? ( "Aenu") :
    (cond_58 && cond_60)? ( 32'd0) :
    (cond_92 && cond_93 && cond_94)? ( (wr_operand_16bit)? { edx[31:16], result[31:16] } : result2) :
    (cond_114 && cond_93 && cond_94)? ( (wr_operand_16bit)? { edx[31:16], result[31:16] } : result2) :
    (cond_145 && cond_25)? ( {32{eax[31]}}) :
    (cond_145 && ~cond_25)? ( { edx[31:16], {16{eax[15]}} }) :
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'hFFFF, exe_buffer_shifted[287:272] } : exe_buffer_shifted[303:272]) :
    (cond_227 && cond_228)? ( { wr_operand_16bit? edx[31:16] : exe_buffer_shifted[63:48],   exe_buffer_shifted[47:32] }) :
    (cond_234 && cond_94)? ( (wr_operand_16bit)? { edx[31:16], result[31:16] } : result2) :
    edx;
assign idtr_base_to_reg =
    (cond_134 && cond_137 && ~cond_135)? ( wr_operand_32bit? result2 : { 8'd0, result2[23:0] }) :
    idtr_base;
assign ldtr_to_reg =
    (cond_210)? (              task_ldtr) :
    ldtr;
assign cr0_am_to_reg =
    (cond_128 && cond_117)? ( result2[18]) :
    cr0_am;
assign tr_rpl_to_reg =
    (cond_210)? (     glob_param_1[1:0]) :
    tr_rpl;
assign tr_cache_to_reg =
    (cond_210)? (   glob_descriptor | 64'h0000020000000000) :
    tr_cache;
assign aflag_to_reg =
    (cond_23)? (  glob_param_3[4]) :
    (cond_29)? (  glob_param_3[4]) :
    (cond_31)? (  glob_param_3[4]) :
    (cond_35)? (  glob_param_5[4]) :
    (cond_45 && cond_46)? ( aflag_arith) :
    (cond_61 && cond_53)? ( `FALSE) :
    (cond_61 && ~cond_53)? ( aflag_arith) :
    (cond_66 && cond_68)? ( aflag_arith) :
    (cond_70)? ( aflag_arith) :
    (cond_78)? (  result2[4]) :
    (cond_91)? ( eax[12]) :
    (cond_92)? ( 1'b0) :
    (cond_107)? ( result_signals[1]) :
    (cond_108)? ( result_signals[1]) :
    (cond_114)? ( 1'b0) :
    (cond_146 && ~cond_53)? ( aflag_arith) :
    (cond_160)? ( aflag_arith) :
    (cond_165)? ( aflag_arith) :
    (cond_171)? ( aflag_arith) :
    (cond_178)? ( aflag_arith) :
    (cond_179 && cond_68)? ( aflag_arith) :
    (cond_180)? ( aflag_arith) :
    (cond_210)? (  task_eflags[4]) :
    (cond_270 && cond_46)? ( aflag_arith) :
    aflag;
assign cr0_em_to_reg =
    (cond_125)? ( result2[2]) :
    (cond_128 && cond_117)? ( result2[2]) :
    cr0_em;
assign cr0_mp_to_reg =
    (cond_125)? ( result2[1]) :
    (cond_128 && cond_117)? ( result2[1]) :
    cr0_mp;
assign fs_to_reg =
    (cond_17 && cond_18)? (             16'd0) :
    (cond_29)? ( wr_IRET_to_v86_fs) :
    (cond_210)? (                task_fs) :
    fs;
assign cs_cache_to_reg =
    (cond_29)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0,wr_IRET_to_v86_cs[15:12], wr_IRET_to_v86_cs[11:0],4'd0, 16'hFFFF }) :
    (cond_128 && cond_117 && cond_130)? ( { cs_cache[63:48], 1'b1, cs_cache[46:45], 1'b1, 4'b0011, cs_cache[39:0] }) :
    cs_cache;
assign ds_cache_to_reg =
    (cond_29)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0,wr_IRET_to_v86_ds[15:12], wr_IRET_to_v86_ds[11:0],4'd0, 16'hFFFF }) :
    ds_cache;
assign cs_cache_valid_to_reg =
    (cond_29)? ( `TRUE) :
    (cond_210)? ( `FALSE) :
    cs_cache_valid;
assign cr0_ne_to_reg =
    (cond_128 && cond_117)? ( result2[5]) :
    cr0_ne;
assign idflag_to_reg =
    (cond_23 && cond_25)? ( glob_param_3[21]) :
    (cond_29)? ( glob_param_3[21]) :
    (cond_31 && cond_25)? ( glob_param_3[21]) :
    (cond_35 && cond_25)? ( glob_param_5[21]) :
    (cond_78 && cond_25)? ( result2[21]) :
    (cond_210)? ( task_eflags[21]) :
    idflag;
assign sflag_to_reg =
    (cond_23)? (  glob_param_3[7]) :
    (cond_29)? (  glob_param_3[7]) :
    (cond_31)? (  glob_param_3[7]) :
    (cond_35)? (  glob_param_5[7]) :
    (cond_45 && cond_46)? ( sflag_result) :
    (cond_61 && cond_53)? ( `FALSE) :
    (cond_61 && ~cond_53)? ( sflag_result) :
    (cond_66 && cond_68)? ( sflag_result) :
    (cond_70)? ( sflag_result) :
    (cond_78)? (  result2[7]) :
    (cond_91)? ( eax[15]) :
    (cond_92)? ( sflag_result) :
    (cond_107)? ( sflag_result) :
    (cond_108)? ( sflag_result) :
    (cond_114)? ( sflag_result) :
    (cond_146 && ~cond_53)? ( sflag_result) :
    (cond_160)? ( sflag_result) :
    (cond_165)? ( sflag_result) :
    (cond_171)? ( sflag_result) :
    (cond_178)? ( sflag_result) :
    (cond_179 && cond_68)? ( sflag_result) :
    (cond_180)? ( sflag_result) :
    (cond_210)? (  task_eflags[7]) :
    (cond_270 && cond_46)? ( sflag_result) :
    sflag;
assign eax_to_reg =
    (cond_0)? ( (wr_operand_16bit)? { eax[31:16], result2[15:0] } : result2) :
    (cond_58 && cond_59)? ( 32'd1) :
    (cond_58 && cond_60)? ( `CPUID_MODEL_FAMILY_STEPPING) :
    (cond_61 && ~cond_53)? ( (wr_is_8bit)? { eax[31:8], result2[7:0] } : (wr_operand_16bit)? { eax[31:16], result2[15:0] } : result2) :
    (cond_62 && cond_46)? ( (wr_is_8bit)? { eax[31:8], result2[7:0] } : (wr_operand_16bit)? { eax[31:16], result2[15:0] } : result2) :
    (cond_92 && cond_93)? ( (wr_is_8bit || wr_operand_16bit)? { eax[31:16], result[15:0] } : result) :
    (cond_107)? ( { eax[31:16], result[15:0] }) :
    (cond_108)? ( { eax[31:16], result[15:0] }) :
    (cond_114 && cond_93)? ( (wr_is_8bit || wr_operand_16bit)? { eax[31:16], result[15:0] } : result) :
    (cond_141 && cond_142)? ( { eax[31:8], 8'hFF }) :
    (cond_141 && ~cond_142)? ( { eax[31:8], 8'h00 }) :
    (cond_143)? ( { eax[31:16], sflag, zflag, 1'b0, aflag, 1'b0, pflag, 1'b1, cflag, eax[7:0] }) :
    (cond_144 && cond_25)? ( { {16{eax[15]}}, eax[15:0] }) :
    (cond_144 && ~cond_25)? ( { eax[31:16], {8{eax[7]}}, eax[7:0] }) :
    (cond_180)? ( { eax[31:16], result[15:0] }) :
    (cond_193 && cond_194)? ( (wr_is_8bit)? { eax[31:8], result2[7:0] } : (wr_operand_16bit)? { eax[31:16], result2[15:0] } : result2) :
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'hFFFF, exe_buffer_shifted[351:336] } : exe_buffer_shifted[367:336]) :
    (cond_227 && cond_228)? ( { wr_operand_16bit? eax[31:16] : exe_buffer[31:16],           exe_buffer[15:0] }) :
    (cond_234)? ( (wr_is_8bit || wr_operand_16bit)? { eax[31:16], result[15:0] } : result) :
    eax;
assign gs_rpl_to_reg =
    (cond_29)? ( 2'd3) :
    (cond_210)? (            task_gs[1:0]) :
    gs_rpl;
assign ss_to_reg =
    (cond_29)? ( wr_IRET_to_v86_ss) :
    (cond_210)? (                task_ss) :
    ss;
assign dflag_to_reg =
    (cond_23)? (  glob_param_3[10]) :
    (cond_29)? (  glob_param_3[10]) :
    (cond_31)? (  glob_param_3[10]) :
    (cond_35)? (  glob_param_5[10]) :
    (cond_78)? (  result2[10]) :
    (cond_88)? ( `FALSE) :
    (cond_90)? ( `TRUE) :
    (cond_210)? (  task_eflags[10]) :
    dflag;
assign dr1_to_reg =
    (cond_116 && cond_118)? ( result2) :
    dr1;
assign dr0_to_reg =
    (cond_116 && cond_117)? ( result2) :
    dr0;
wire [1:0] wr_task_rpl_to_reg =
    (cond_210)? ( task_cs[1:0]) :
    (cond_256)? ( cpl) :
    wr_task_rpl;
assign dr3_to_reg =
    (cond_116 && cond_120)? ( result2) :
    dr3;
assign dr2_to_reg =
    (cond_116 && cond_119)? ( result2) :
    dr2;
assign dr7_to_reg =
    (cond_116 && cond_122)? (    result2 | 32'h00000400) :
    (cond_210)? ( dr7 & 32'hFFFFFEAA) :
    dr7;
assign cr0_nw_to_reg =
    (cond_128 && cond_117)? ( result2[29]) :
    cr0_nw;
assign gs_to_reg =
    (cond_17 && cond_18)? (             16'd0) :
    (cond_29)? ( wr_IRET_to_v86_gs) :
    (cond_210)? (                task_gs) :
    gs;
assign cflag_to_reg =
    (cond_23)? (  glob_param_3[0]) :
    (cond_29)? (  glob_param_3[0]) :
    (cond_31)? (  glob_param_3[0]) :
    (cond_35)? (  glob_param_5[0]) :
    (cond_45 && cond_46)? ( cflag_arith) :
    (cond_61 && cond_53)? ( `FALSE) :
    (cond_61 && ~cond_53)? ( cflag_arith) :
    (cond_66 && cond_69)? ( result_signals[0]) :
    (cond_78)? (  result2[0]) :
    (cond_86)? ( `FALSE) :
    (cond_87)? ( ~cflag) :
    (cond_89)? ( `TRUE) :
    (cond_91)? ( eax[8]) :
    (cond_92)? ( wr_mult_overflow) :
    (cond_107)? ( result_signals[1]) :
    (cond_108)? ( result_signals[0]) :
    (cond_114)? ( wr_mult_overflow) :
    (cond_139)? ( result_signals[0]) :
    (cond_146 && ~cond_53)? ( cflag_arith) :
    (cond_160)? ( cflag_arith) :
    (cond_165)? ( cflag_arith) :
    (cond_171)? ( cflag_arith) :
    (cond_178)? ( cflag_arith) :
    (cond_179 && cond_69)? ( result_signals[0]) :
    (cond_180)? ( cflag_arith) :
    (cond_210)? (  task_eflags[0]) :
    (cond_270 && cond_46)? ( cflag_arith) :
    cflag;
assign cs_rpl_to_reg =
    (cond_29)? ( 2'd3) :
    (cond_210)? (         2'd3) :
    (cond_214 && cond_215)? ( wr_task_rpl) :
    cs_rpl;
assign ldtr_cache_valid_to_reg =
    (cond_210)? (  `FALSE) :
    (cond_212 && cond_213)? (   `TRUE) :
    ldtr_cache_valid;
assign ds_cache_valid_to_reg =
    (cond_17 && cond_18)? ( `FALSE) :
    (cond_29)? ( `TRUE) :
    (cond_210)? (    `FALSE) :
    ds_cache_valid;
assign cs_to_reg =
    (cond_29)? ( wr_IRET_to_v86_cs) :
    (cond_210)? (             task_cs) :
    cs;
assign fs_cache_to_reg =
    (cond_29)? ( `DESC_MASK_P | `DESC_MASK_DPL | `DESC_MASK_SEG | `DESC_MASK_DATA_RWA | { 24'd0, 4'd0,wr_IRET_to_v86_fs[15:12], wr_IRET_to_v86_fs[11:0],4'd0, 16'hFFFF }) :
    fs_cache;
assign tflag_to_reg =
    (cond_14)? (  `FALSE) :
    (cond_16)? (  `FALSE) :
    (cond_17)? (  `FALSE) :
    (cond_23)? (  glob_param_3[8]) :
    (cond_29)? (  glob_param_3[8]) :
    (cond_31)? (  glob_param_3[8]) :
    (cond_35)? (  glob_param_5[8]) :
    (cond_78)? (  result2[8]) :
    (cond_210)? (  task_eflags[8]) :
    tflag;
assign cr0_cd_to_reg =
    (cond_128 && cond_117)? ( result2[30]) :
    cr0_cd;
assign ebp_to_reg =
    (cond_172)? ( { wr_operand_16bit? ebp[31:16] : result_push[31:16], result_push[15:0] }) :
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'hFFFF, exe_buffer_shifted[191:176] } : exe_buffer_shifted[207:176]) :
    (cond_227 && cond_228)? ( { wr_operand_16bit? ebp[31:16] : exe_buffer_shifted[159:144], exe_buffer_shifted[143:128] }) :
    (cond_273)? ( { wr_operand_16bit? ebp[31:16] : exe_buffer[31:16], exe_buffer[15:0] }) :
    ebp;
assign es_cache_valid_to_reg =
    (cond_17 && cond_18)? ( `FALSE) :
    (cond_29)? ( `TRUE) :
    (cond_210)? (    `FALSE) :
    es_cache_valid;
assign fs_rpl_to_reg =
    (cond_29)? ( 2'd3) :
    (cond_210)? (            task_fs[1:0]) :
    fs_rpl;
assign gs_cache_valid_to_reg =
    (cond_17 && cond_18)? ( `FALSE) :
    (cond_29)? ( `TRUE) :
    (cond_210)? (    `FALSE) :
    gs_cache_valid;
assign ntflag_to_reg =
    (cond_16)? ( `FALSE) :
    (cond_17)? ( `FALSE) :
    (cond_23)? ( glob_param_3[14]) :
    (cond_29)? ( glob_param_3[14]) :
    (cond_31)? ( glob_param_3[14]) :
    (cond_35)? ( glob_param_5[14]) :
    (cond_78)? ( result2[14]) :
    (cond_210)? ( task_eflags[14] |  + (glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_CALL || glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_INT)) :
    ntflag;
assign fs_cache_valid_to_reg =
    (cond_17 && cond_18)? ( `FALSE) :
    (cond_29)? ( `TRUE) :
    (cond_210)? (    `FALSE) :
    fs_cache_valid;
assign ldtr_rpl_to_reg =
    (cond_210)? (          task_ldtr[1:0]) :
    ldtr_rpl;
assign ebx_to_reg =
    (cond_58 && cond_59)? ( "ineG") :
    (cond_58 && cond_60)? ( 32'h00010000) :
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'hFFFF, exe_buffer_shifted[255:240] } : exe_buffer_shifted[271:240]) :
    (cond_227 && cond_228)? ( { wr_operand_16bit? ebx[31:16] : exe_buffer_shifted[95:80],   exe_buffer_shifted[79:64] }) :
    ebx;
assign esi_to_reg =
    (cond_62 && cond_46)? ( wr_esi_final) :
    (cond_97 && cond_46 && ~cond_7)? ( wr_esi_final) :
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 16'hFFFF, exe_buffer_shifted[159:144] } : exe_buffer_shifted[175:144]) :
    (cond_227 && cond_228)? ( { wr_operand_16bit? esi[31:16] : exe_buffer_shifted[191:176], exe_buffer_shifted[175:160] }) :
    (cond_229 && ~cond_230 && cond_46 && ~cond_231)? ( wr_esi_final) :
    (cond_270 && cond_46)? ( wr_esi_final) :
    esi;
assign cr0_wp_to_reg =
    (cond_128 && cond_117)? ( result2[16]) :
    cr0_wp;
assign ldtr_cache_to_reg =
    (cond_212 && cond_213)? (         glob_descriptor) :
    ldtr_cache;
assign dr6_bd_to_reg =
    (cond_116 && cond_121)? (     result2[13]) :
    dr6_bd;
assign idtr_limit_to_reg =
    (cond_134 && cond_137 && cond_135)? ( result2[15:0]) :
    idtr_limit;
assign tr_to_reg =
    (cond_210)? (         glob_param_1[15:0]) :
    tr;
//======================================================== always
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) wr_task_rpl <= 2'd0;
    else              wr_task_rpl <= wr_task_rpl_to_reg;
end
//======================================================== sets
assign wr_exception_finished =
    (cond_14)? (`TRUE) :
    (cond_16)? (`TRUE) :
    (cond_17)? (`TRUE) :
    (cond_225)? (`TRUE) :
    1'd0;
assign wr_int_soft_int_ib =
    (cond_246)? (`TRUE) :
    1'd0;
assign wr_one_cycle_wait =
    (cond_6)? (`TRUE) :
    (cond_9)? (`TRUE) :
    (cond_19)? (`TRUE) :
    (cond_41)? (`TRUE) :
    (cond_50)? (`TRUE) :
    (cond_71)? (`TRUE) :
    (cond_97 && cond_46)? (`TRUE) :
    (cond_109 && cond_46)? (`TRUE) :
    (cond_164)? (`TRUE) :
    (cond_183)? (`TRUE) :
    (cond_184)? (`TRUE) :
    (cond_187)? (`TRUE) :
    (cond_190)? (`TRUE) :
    (cond_191)? (`TRUE) :
    (cond_223 && cond_224)? (`TRUE) :
    (cond_266)? (`TRUE) :
    (cond_272)? (`TRUE) :
    (cond_274)? (`TRUE) :
    1'd0;
assign wr_int =
    (cond_246)? (`TRUE) :
    (cond_247)? (`TRUE) :
    (cond_248)? (`TRUE) :
    (cond_249 && cond_250)? (`TRUE) :
    1'd0;
assign wr_glob_param_4_value =
    (cond_210)? ( { task_fs, task_gs }) :
    32'd0;
assign wr_int_vector =
    (cond_246)? ( wr_decoder[15:8]) :
    (cond_247)? ( `EXCEPTION_BP) :
    (cond_248)? ( `EXCEPTION_DB) :
    (cond_249 && cond_250)? ( `EXCEPTION_OF) :
    8'd0;
assign wr_make_esp_commit =
    (cond_14)? (`TRUE) :
    (cond_16)? (`TRUE) :
    (cond_17)? (`TRUE) :
    (cond_23)? (`TRUE) :
    (cond_41 && cond_44)? (`TRUE) :
    (cond_104)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_175 && cond_176)? (`TRUE) :
    (cond_185)? (`TRUE) :
    (cond_210)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_227 && cond_228)? (`TRUE) :
    (cond_251 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_251 && ~cond_252)? (`TRUE) :
    (cond_259)? (`TRUE) :
    (cond_273)? (`TRUE) :
    1'd0;
assign wr_seg_cache_valid =
    (cond_214 && cond_216 && ~cond_7)? (  `TRUE) :
    (cond_214 && cond_221)? (  `TRUE) :
    (cond_235 && cond_18)? (  `TRUE) :
    (cond_235 && cond_24)? (  `TRUE) :
    (cond_237 && cond_238)? (  `TRUE) :
    (cond_251)? (  `TRUE) :
    (cond_254)? (  `TRUE) :
    (cond_256)? (  `TRUE) :
    (cond_257)? (  `TRUE) :
    1'd0;
assign wr_push_ss_fault_check =
    (cond_19)? (`TRUE) :
    (cond_41)? (`TRUE) :
    (cond_50)? (`TRUE) :
    (cond_71)? (`TRUE) :
    (cond_164)? (`TRUE) :
    (cond_183)? (`TRUE) :
    (cond_184)? (`TRUE) :
    (cond_223 && cond_224)? (`TRUE) :
    (cond_266)? (`TRUE) :
    (cond_272)? (`TRUE) :
    (cond_274)? (`TRUE) :
    1'd0;
assign wr_req_reset_rd =
    (cond_14)? (`TRUE) :
    (cond_16)? (`TRUE) :
    (cond_17)? (`TRUE) :
    (cond_23)? (`TRUE) :
    (cond_30)? (`TRUE) :
    (cond_31)? (`TRUE) :
    (cond_45 && cond_48)? (`TRUE) :
    (cond_54)? (`TRUE) :
    (cond_56)? (`TRUE) :
    (cond_58)? (`TRUE) :
    (cond_62 && cond_63)? (`TRUE) :
    (cond_74)? (`TRUE) :
    (cond_78)? (`TRUE) :
    (cond_81 && cond_53)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_46 && ~cond_7 && cond_84)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_85)? (`TRUE) :
    (cond_97 && cond_46 && ~cond_7 && cond_99)? (`TRUE) :
    (cond_97 && cond_85)? (`TRUE) :
    (cond_101)? (`TRUE) :
    (cond_104)? (`TRUE) :
    (cond_109 && cond_46 && ~cond_7 && cond_99)? (`TRUE) :
    (cond_109 && cond_85)? (`TRUE) :
    (cond_110 && cond_53)? (`TRUE) :
    (cond_123)? (`TRUE) :
    (cond_125)? (`TRUE) :
    (cond_128)? (`TRUE) :
    (cond_131 && cond_53)? (`TRUE) :
    (cond_134 && cond_138)? (`TRUE) :
    (cond_148)? (`TRUE) :
    (cond_155)? (`TRUE) :
    (cond_163)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_185)? (`TRUE) :
    (cond_193 && cond_194)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_46 && ~cond_231 && cond_84)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_85)? (`TRUE) :
    (cond_233)? (`TRUE) :
    (cond_243 && cond_244 && ~cond_231)? (`TRUE) :
    (cond_249 && ~cond_250)? (`TRUE) :
    (cond_255)? (`TRUE) :
    (cond_259)? (`TRUE) :
    (cond_270 && cond_271)? (`TRUE) :
    1'd0;
assign wr_make_esp_speculative =
    (cond_11)? (`TRUE) :
    (cond_21 && cond_22)? (`TRUE) :
    (cond_41 && cond_42)? (`TRUE) :
    (cond_102)? (`TRUE) :
    (cond_168)? (`TRUE) :
    (cond_174)? (`TRUE) :
    (cond_182)? (`TRUE) :
    (cond_184 && cond_20)? (`TRUE) :
    (cond_223 && cond_224)? (`TRUE) :
    (cond_227 && cond_42)? (`TRUE) :
    (cond_272)? (`TRUE) :
    1'd0;
assign wr_glob_param_1_value =
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? { 13'd0, `SEGMENT_LDT, exe_buffer_shifted[47:32] } : { 13'd0, `SEGMENT_LDT, exe_buffer_shifted[15:0] }) :
    (cond_212)? ( { 13'd0, `SEGMENT_SS, task_ss }) :
    (cond_214 && cond_216 && ~cond_7 && cond_215)? ( { 13'd0, `SEGMENT_DS, task_ds }) :
    (cond_214 && cond_216 && ~cond_7 && cond_217)? ( { 13'd0, `SEGMENT_ES, task_es }) :
    (cond_214 && cond_216 && ~cond_7 && cond_218)? ( { 13'd0, `SEGMENT_FS, glob_param_4[31:16] }) :
    (cond_214 && cond_216 && ~cond_7 && cond_219)? ( { 13'd0, `SEGMENT_GS, glob_param_4[15:0] }) :
    (cond_214 && cond_216 && ~cond_7 && cond_220)? ( { 13'd0, `SEGMENT_CS, task_cs }) :
    (cond_214 && cond_221 && cond_215)? ( { 13'd0, `SEGMENT_DS, task_ds }) :
    (cond_214 && cond_221 && cond_217)? ( { 13'd0, `SEGMENT_ES, task_es }) :
    (cond_214 && cond_221 && cond_218)? ( { 13'd0, `SEGMENT_FS, glob_param_4[31:16] }) :
    (cond_214 && cond_221 && cond_219)? ( { 13'd0, `SEGMENT_GS, glob_param_4[15:0] }) :
    (cond_214 && cond_221 && cond_220)? ( { 13'd0, `SEGMENT_CS, task_cs }) :
    (cond_214 && cond_222 && cond_215)? ( { 13'd0, `SEGMENT_DS, task_ds }) :
    (cond_214 && cond_222 && cond_217)? ( { 13'd0, `SEGMENT_ES, task_es }) :
    (cond_214 && cond_222 && cond_218)? ( { 13'd0, `SEGMENT_FS, glob_param_4[31:16] }) :
    (cond_214 && cond_222 && cond_219)? ( { 13'd0, `SEGMENT_GS, glob_param_4[15:0] }) :
    (cond_214 && cond_222 && cond_220)? ( { 13'd0, `SEGMENT_CS, task_cs }) :
    32'd0;
assign wr_not_finished =
    (cond_1)? (`TRUE) :
    (cond_4)? (`TRUE) :
    (cond_5)? (`TRUE) :
    (cond_6)? (`TRUE) :
    (cond_9)? (`TRUE) :
    (cond_11)? (`TRUE) :
    (cond_12)? (`TRUE) :
    (cond_13)? (`TRUE) :
    (cond_15)? (`TRUE) :
    (cond_19)? (`TRUE) :
    (cond_21)? (`TRUE) :
    (cond_26)? (`TRUE) :
    (cond_27)? (`TRUE) :
    (cond_28)? (`TRUE) :
    (cond_29)? (`TRUE) :
    (cond_34)? (`TRUE) :
    (cond_35)? (`TRUE) :
    (cond_41 && cond_43)? (`TRUE) :
    (cond_45 && cond_49)? (`TRUE) :
    (cond_55)? (`TRUE) :
    (cond_62 && cond_64)? (`TRUE) :
    (cond_73)? (`TRUE) :
    (cond_75 && cond_76)? (`TRUE) :
    (cond_82 && cond_83)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_46 && ~cond_7 && ~cond_84)? (`TRUE) :
    (cond_97 && cond_46 && ~cond_7 && ~cond_99 && cond_47)? (`TRUE) :
    (cond_100)? (`TRUE) :
    (cond_102)? (`TRUE) :
    (cond_103)? (`TRUE) :
    (cond_105)? (`TRUE) :
    (cond_106)? (`TRUE) :
    (cond_109 && cond_46 && ~cond_7 && ~cond_99 && cond_47)? (`TRUE) :
    (cond_112)? (`TRUE) :
    (cond_116)? (`TRUE) :
    (cond_134 && cond_135)? (`TRUE) :
    (cond_134 && ~cond_138)? (`TRUE) :
    (cond_147)? (`TRUE) :
    (cond_149)? (`TRUE) :
    (cond_150)? (`TRUE) :
    (cond_151)? (`TRUE) :
    (cond_152)? (`TRUE) :
    (cond_153)? (`TRUE) :
    (cond_154)? (`TRUE) :
    (cond_156)? (`TRUE) :
    (cond_165)? (`TRUE) :
    (cond_168)? (`TRUE) :
    (cond_174)? (`TRUE) :
    (cond_177)? (`TRUE) :
    (cond_181)? (`TRUE) :
    (cond_182)? (`TRUE) :
    (cond_183)? (`TRUE) :
    (cond_184)? (`TRUE) :
    (cond_186)? (`TRUE) :
    (cond_187)? (`TRUE) :
    (cond_188)? (`TRUE) :
    (cond_189)? (`TRUE) :
    (cond_190)? (`TRUE) :
    (cond_191)? (`TRUE) :
    (cond_193 && ~cond_194)? (`TRUE) :
    (cond_195)? (`TRUE) :
    (cond_196)? (`TRUE) :
    (cond_197)? (`TRUE) :
    (cond_199)? (`TRUE) :
    (cond_200)? (`TRUE) :
    (cond_201)? (`TRUE) :
    (cond_202)? (`TRUE) :
    (cond_204)? (`TRUE) :
    (cond_206)? (`TRUE) :
    (cond_207)? (`TRUE) :
    (cond_208)? (`TRUE) :
    (cond_210)? (`TRUE) :
    (cond_212)? (`TRUE) :
    (cond_214)? (`TRUE) :
    (cond_223)? (`TRUE) :
    (cond_227 && ~cond_228)? (`TRUE) :
    (cond_229 && cond_230)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_46 && ~cond_231 && ~cond_84)? (`TRUE) :
    (cond_232)? (`TRUE) :
    (cond_235)? (`TRUE) :
    (cond_237)? (`TRUE) :
    (cond_243 && ~cond_244)? (`TRUE) :
    (cond_245)? (`TRUE) :
    (cond_246)? (`TRUE) :
    (cond_247)? (`TRUE) :
    (cond_248)? (`TRUE) :
    (cond_249 && cond_250)? (`TRUE) :
    (cond_251)? (`TRUE) :
    (cond_254)? (`TRUE) :
    (cond_256)? (`TRUE) :
    (cond_257)? (`TRUE) :
    (cond_260)? (`TRUE) :
    (cond_261)? (`TRUE) :
    (cond_262)? (`TRUE) :
    (cond_263)? (`TRUE) :
    (cond_264)? (`TRUE) :
    (cond_265)? (`TRUE) :
    (cond_266)? (`TRUE) :
    (cond_267)? (`TRUE) :
    (cond_268)? (`TRUE) :
    (cond_269)? (`TRUE) :
    (cond_270 && cond_49)? (`TRUE) :
    (cond_272)? (`TRUE) :
    (cond_274)? (`TRUE) :
    1'd0;
assign write_rmw_system_dword =
    (cond_197 && cond_198)? (`TRUE) :
    (cond_208 && cond_209)? (`TRUE) :
    1'd0;
assign wr_validate_seg_regs =
    (cond_259)? (`TRUE) :
    1'd0;
assign wr_exception_external_set =
    (cond_248)? (`TRUE) :
    1'd0;
assign wr_seg_cache_mask =
    (cond_235 && cond_24)? ( `DESC_MASK_G | `DESC_MASK_D_B | `DESC_MASK_AVL | `DESC_MASK_LIMIT | `DESC_MASK_DPL | `DESC_MASK_TYPE) :
    64'd0;
assign write_new_stack_virtual =
    (cond_6 && cond_8)? (`TRUE) :
    (cond_9 && cond_8)? (`TRUE) :
    (cond_187 && cond_8)? (`TRUE) :
    (cond_190 && cond_8)? (`TRUE) :
    (cond_191 && cond_8)? (`TRUE) :
    1'd0;
assign wr_inhibit_interrupts_and_debug =
    (cond_56 && cond_57)? (`TRUE) :
    (cond_169 && cond_170)? (`TRUE) :
    1'd0;
assign wr_system_dword =
    (cond_197 && cond_198)? ( glob_param_2 & 32'hFFFFFDFF) :
    (cond_200)? (  (glob_param_1[`TASK_SWITCH_SOURCE_BITS] == `TASK_SWITCH_FROM_INT)? exc_eip : eip) :
    (cond_201)? (  result_push & ((glob_descriptor[`DESC_BITS_TYPE] == `DESC_TSS_BUSY_286 || glob_descriptor[`DESC_BITS_TYPE] == `DESC_TSS_BUSY_386)? 32'hFFFFBFFF : 32'hFFFFFFFF)) :
    (cond_202 && cond_203)? (  result2) :
    (cond_204 && cond_205)? (  { 16'd0, tr }) :
    (cond_208 && cond_209)? ( result2 | 32'h00000200) :
    32'd0;
assign write_system_word =
    (cond_200)? (  tr_cache[`DESC_BITS_TYPE] <= 4'd3) :
    (cond_201)? (  tr_cache[`DESC_BITS_TYPE] <= 4'd3) :
    (cond_202 && cond_203)? (  tr_cache[`DESC_BITS_TYPE] <= 4'd3 || wr_cmdex > `CMDEX_task_switch_2_STEP_7) :
    (cond_204 && cond_205)? (`TRUE) :
    1'd0;
assign wr_regrm_dword =
    (cond_115)? (`TRUE) :
    (cond_127)? (`TRUE) :
    1'd0;
assign tlbflushall_do =
    (cond_125 && cond_126)? (`TRUE) :
    (cond_128 && cond_117 && cond_129)? (`TRUE) :
    (cond_128 && cond_120)? (`TRUE) :
    (cond_210 && cond_211)? (`TRUE) :
    1'd0;
assign wr_glob_param_3_set =
    (cond_210)? (`TRUE) :
    1'd0;
assign write_system_touch =
    (cond_214 && cond_216)? (`TRUE) :
    (cond_237 && cond_238 && cond_239 && ~cond_240)? (`TRUE) :
    (cond_251 && cond_252)? (`TRUE) :
    (cond_254 && cond_252)? (`TRUE) :
    (cond_256 && cond_252)? (`TRUE) :
    (cond_257 && cond_258)? (`TRUE) :
    1'd0;
assign write_rmw_virtual =
    (cond_1)? (       wr_dst_is_memory) :
    (cond_52 && cond_53)? (   wr_dst_is_memory) :
    (cond_61 && cond_53)? (       wr_dst_is_memory) :
    (cond_66 && cond_67)? (   wr_dst_is_memory) :
    (cond_70)? (   wr_dst_is_memory) :
    (cond_133)? (   wr_dst_is_memory) :
    (cond_139 && cond_140)? (   wr_dst_is_memory) :
    (cond_160 && cond_162)? (  wr_dst_is_memory) :
    (cond_165)? (       wr_dst_is_memory) :
    (cond_171)? (   wr_dst_is_memory) :
    (cond_179 && cond_67)? (   wr_dst_is_memory) :
    1'd0;
assign wr_req_reset_exe =
    (cond_14)? (`TRUE) :
    (cond_16)? (`TRUE) :
    (cond_17)? (`TRUE) :
    (cond_23)? (`TRUE) :
    (cond_30)? (`TRUE) :
    (cond_31)? (`TRUE) :
    (cond_45 && cond_48)? (`TRUE) :
    (cond_54)? (`TRUE) :
    (cond_56)? (`TRUE) :
    (cond_58)? (`TRUE) :
    (cond_62 && cond_63)? (`TRUE) :
    (cond_74)? (`TRUE) :
    (cond_78)? (`TRUE) :
    (cond_81 && cond_53)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_46 && ~cond_7 && cond_84)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_85)? (`TRUE) :
    (cond_97 && cond_46 && ~cond_7 && cond_99)? (`TRUE) :
    (cond_97 && cond_85)? (`TRUE) :
    (cond_101)? (`TRUE) :
    (cond_104)? (`TRUE) :
    (cond_109 && cond_46 && ~cond_7 && cond_99)? (`TRUE) :
    (cond_109 && cond_85)? (`TRUE) :
    (cond_110 && cond_53)? (`TRUE) :
    (cond_123)? (`TRUE) :
    (cond_125)? (`TRUE) :
    (cond_128)? (`TRUE) :
    (cond_131 && cond_53)? (`TRUE) :
    (cond_134 && cond_138)? (`TRUE) :
    (cond_148)? (`TRUE) :
    (cond_155)? (`TRUE) :
    (cond_163)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_185)? (`TRUE) :
    (cond_193 && cond_194)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_46 && ~cond_231 && cond_84)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_85)? (`TRUE) :
    (cond_233)? (`TRUE) :
    (cond_243 && cond_244 && ~cond_231)? (`TRUE) :
    (cond_249 && ~cond_250)? (`TRUE) :
    (cond_255)? (`TRUE) :
    (cond_259)? (`TRUE) :
    (cond_270 && cond_271)? (`TRUE) :
    1'd0;
assign wr_push_length_word =
    (cond_6)? (  ~(glob_param_3[19])) :
    (cond_9)? ( ~(glob_param_3[19])) :
    (cond_19)? (`TRUE) :
    (cond_71)? (`TRUE) :
    (cond_190)? (  ~(glob_param_3[19])) :
    (cond_191)? (  ~(glob_param_3[19])) :
    (cond_223)? (  ~(glob_param_3[17])) :
    (cond_266)? (  ~(glob_param_1[19])) :
    1'd0;
assign wr_int_soft_int =
    (cond_246)? (`TRUE) :
    (cond_247)? (`TRUE) :
    (cond_249 && cond_250)? (`TRUE) :
    1'd0;
assign wr_seg_sel =
    (cond_214 && cond_221)? ( glob_param_1[15:0]) :
    (cond_235)? ( glob_param_1[15:0]) :
    (cond_237 && cond_238)? (          glob_param_1[15:0]) :
    (cond_251)? (          (wr_cmd == `CMD_CALL_2 || wr_cmd == `CMD_JMP || wr_cmd == `CMD_JMP_2 || wr_cmd == `CMD_int_2)? { glob_param_1[15:2], cpl } : glob_param_1[15:0]) :
    (cond_254)? (          { glob_param_1[15:2], glob_descriptor[`DESC_BITS_DPL] }) :
    (cond_256)? (          glob_param_1[15:0]) :
    (cond_257)? (          glob_param_1[15:0]) :
    16'd0;
assign wr_error_code =
    (cond_6)? ( (glob_param_1[`SELECTOR_BITS_RPL] != cpl)? `SELECTOR_FOR_CODE(glob_param_1) : 16'd0) :
    (cond_9)? ( (glob_param_1[`SELECTOR_BITS_RPL] != cpl)? `SELECTOR_FOR_CODE(glob_param_1) : 16'd0) :
    (cond_187)? ( (ss[`SELECTOR_BITS_RPL] != cpl)? `SELECTOR_FOR_CODE(ss) : 16'd0) :
    (cond_190)? ( (glob_param_1[`SELECTOR_BITS_RPL] != cpl)? `SELECTOR_FOR_CODE(glob_param_1) : 16'd0) :
    (cond_191)? ( (glob_param_1[`SELECTOR_BITS_RPL] != cpl)? `SELECTOR_FOR_CODE(glob_param_1) : 16'd0) :
    16'd0;
assign wr_inhibit_interrupts =
    (cond_39 && cond_40)? (`TRUE) :
    1'd0;
assign write_length_dword =
    (cond_75 && cond_77)? (`TRUE) :
    1'd0;
assign wr_glob_param_4_set =
    (cond_210)? (`TRUE) :
    1'd0;
assign wr_debug_task_trigger =
    (cond_225 && cond_226)? (`TRUE) :
    1'd0;
assign write_system_busy_tss =
    (cond_237 && cond_238 && cond_239 && cond_240)? (`TRUE) :
    1'd0;
assign wr_string_gp_fault_check =
    (cond_97)? (`TRUE) :
    (cond_109)? (`TRUE) :
    1'd0;
assign write_eax =
    (cond_111)? (`TRUE) :
    (cond_113)? (      wr_dst_is_eax) :
    (cond_160 && cond_162)? (          wr_dst_is_eax) :
    1'd0;
assign wr_new_push_ss_fault_check =
    (cond_6)? (`TRUE) :
    (cond_9)? (`TRUE) :
    (cond_187)? (`TRUE) :
    (cond_190)? (`TRUE) :
    (cond_191)? (`TRUE) :
    1'd0;
assign write_system_dword =
    (cond_200)? ( tr_cache[`DESC_BITS_TYPE] > 4'd3) :
    (cond_201)? ( tr_cache[`DESC_BITS_TYPE] > 4'd3) :
    (cond_202 && cond_203)? ( tr_cache[`DESC_BITS_TYPE] > 4'd3  && wr_cmdex <= `CMDEX_task_switch_2_STEP_7) :
    1'd0;
assign wr_req_reset_dec =
    (cond_14)? (`TRUE) :
    (cond_16)? (`TRUE) :
    (cond_17)? (`TRUE) :
    (cond_23)? (`TRUE) :
    (cond_30)? (`TRUE) :
    (cond_31)? (`TRUE) :
    (cond_54)? (`TRUE) :
    (cond_81 && cond_53)? (`TRUE) :
    (cond_104)? (`TRUE) :
    (cond_110 && cond_53)? (`TRUE) :
    (cond_125)? (`TRUE) :
    (cond_128)? (`TRUE) :
    (cond_131 && cond_53)? (`TRUE) :
    (cond_148)? (`TRUE) :
    (cond_185)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_255)? (`TRUE) :
    (cond_259)? (`TRUE) :
    1'd0;
assign write_seg_cache =
    (cond_214 && cond_216 && ~cond_7)? (`TRUE) :
    (cond_214 && cond_221)? (`TRUE) :
    (cond_235 && cond_18)? (`TRUE) :
    (cond_235 && cond_24)? (`TRUE) :
    (cond_235 && cond_236)? (`TRUE) :
    (cond_237 && cond_238 && cond_239 && ~cond_7)? (`TRUE) :
    (cond_237 && cond_238 && cond_241)? (`TRUE) :
    (cond_251 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_251 && ~cond_252)? (`TRUE) :
    (cond_254 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_254 && ~cond_252)? (`TRUE) :
    (cond_256 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_256 && ~cond_252)? (`TRUE) :
    (cond_257 && cond_258 && ~cond_7)? (`TRUE) :
    (cond_257 && ~cond_258)? (`TRUE) :
    1'd0;
assign write_seg_sel =
    (cond_235 && cond_18)? (`TRUE) :
    (cond_235 && cond_24)? (`TRUE) :
    (cond_235 && cond_236)? (`TRUE) :
    (cond_237 && cond_238 && cond_239 && ~cond_7)? (`TRUE) :
    (cond_237 && cond_238 && cond_241)? (`TRUE) :
    (cond_251 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_251 && ~cond_252)? (`TRUE) :
    (cond_254 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_254 && ~cond_252)? (`TRUE) :
    (cond_256 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_256 && ~cond_252)? (`TRUE) :
    (cond_257 && cond_258 && ~cond_7)? (`TRUE) :
    (cond_257 && ~cond_258)? (`TRUE) :
    1'd0;
assign write_length_word =
    (cond_52)? (`TRUE) :
    (cond_72)? (`TRUE) :
    (cond_75 && cond_76)? (`TRUE) :
    (cond_124)? (`TRUE) :
    1'd0;
assign write_string_es_virtual =
    (cond_82 && ~cond_83 && cond_46)? (`TRUE) :
    (cond_97 && cond_46 && cond_98)? (`TRUE) :
    (cond_109 && cond_46 && cond_98)? (`TRUE) :
    1'd0;
assign wr_req_reset_micro =
    (cond_14)? (`TRUE) :
    (cond_16)? (`TRUE) :
    (cond_17)? (`TRUE) :
    (cond_23)? (`TRUE) :
    (cond_30)? (`TRUE) :
    (cond_31)? (`TRUE) :
    (cond_45 && cond_48)? (`TRUE) :
    (cond_54)? (`TRUE) :
    (cond_56)? (`TRUE) :
    (cond_58)? (`TRUE) :
    (cond_62 && cond_63)? (`TRUE) :
    (cond_74)? (`TRUE) :
    (cond_78)? (`TRUE) :
    (cond_81 && cond_53)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_46 && ~cond_7 && cond_84)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_85)? (`TRUE) :
    (cond_97 && cond_46 && ~cond_7 && cond_99)? (`TRUE) :
    (cond_97 && cond_85)? (`TRUE) :
    (cond_101)? (`TRUE) :
    (cond_104)? (`TRUE) :
    (cond_109 && cond_46 && ~cond_7 && cond_99)? (`TRUE) :
    (cond_109 && cond_85)? (`TRUE) :
    (cond_110 && cond_53)? (`TRUE) :
    (cond_123)? (`TRUE) :
    (cond_125)? (`TRUE) :
    (cond_128)? (`TRUE) :
    (cond_131 && cond_53)? (`TRUE) :
    (cond_134 && cond_138)? (`TRUE) :
    (cond_148)? (`TRUE) :
    (cond_155)? (`TRUE) :
    (cond_163)? (`TRUE) :
    (cond_169)? (`TRUE) :
    (cond_185)? (`TRUE) :
    (cond_193 && cond_194)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_46 && ~cond_231 && cond_84)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_85)? (`TRUE) :
    (cond_233)? (`TRUE) :
    (cond_243 && cond_244 && ~cond_231)? (`TRUE) :
    (cond_249 && ~cond_250)? (`TRUE) :
    (cond_255)? (`TRUE) :
    (cond_259)? (`TRUE) :
    (cond_270 && cond_271)? (`TRUE) :
    1'd0;
assign write_virtual =
    (cond_65)? (   wr_dst_is_memory) :
    (cond_72)? (   wr_dst_is_memory) :
    (cond_75)? (`TRUE) :
    (cond_113)? (  wr_dst_is_memory) :
    (cond_124)? (   wr_dst_is_memory) :
    (cond_175)? (   wr_dst_is_memory) :
    1'd0;
assign wr_glob_param_1_set =
    (cond_210)? (`TRUE) :
    (cond_212)? (`TRUE) :
    (cond_214 && cond_216 && ~cond_7 && cond_215)? (`TRUE) :
    (cond_214 && cond_216 && ~cond_7 && cond_217)? (`TRUE) :
    (cond_214 && cond_216 && ~cond_7 && cond_218)? (`TRUE) :
    (cond_214 && cond_216 && ~cond_7 && cond_219)? (`TRUE) :
    (cond_214 && cond_216 && ~cond_7 && cond_220)? (`TRUE) :
    (cond_214 && cond_221 && cond_215)? (`TRUE) :
    (cond_214 && cond_221 && cond_217)? (`TRUE) :
    (cond_214 && cond_221 && cond_218)? (`TRUE) :
    (cond_214 && cond_221 && cond_219)? (`TRUE) :
    (cond_214 && cond_221 && cond_220)? (`TRUE) :
    (cond_214 && cond_222 && cond_215)? (`TRUE) :
    (cond_214 && cond_222 && cond_217)? (`TRUE) :
    (cond_214 && cond_222 && cond_218)? (`TRUE) :
    (cond_214 && cond_222 && cond_219)? (`TRUE) :
    (cond_214 && cond_222 && cond_220)? (`TRUE) :
    1'd0;
assign wr_push_length_dword =
    (cond_6)? ( glob_param_3[19]) :
    (cond_9)? ( glob_param_3[19]) :
    (cond_190)? ( glob_param_3[19]) :
    (cond_191)? ( glob_param_3[19]) :
    (cond_223)? ( glob_param_3[17]) :
    (cond_266)? ( glob_param_1[19]) :
    1'd0;
assign write_stack_virtual =
    (cond_19 && cond_20)? (`TRUE) :
    (cond_41 && cond_20)? (`TRUE) :
    (cond_50 && cond_20)? (`TRUE) :
    (cond_71 && cond_20)? (`TRUE) :
    (cond_164 && cond_20)? (`TRUE) :
    (cond_183 && cond_20)? (`TRUE) :
    (cond_184 && cond_20)? (`TRUE) :
    (cond_223 && cond_224 && cond_20)? (`TRUE) :
    (cond_266 && cond_20)? (`TRUE) :
    (cond_272 && cond_20)? (`TRUE) :
    (cond_274 && cond_20)? (`TRUE) :
    1'd0;
assign wr_string_in_progress =
    (cond_45 && cond_49)? (`TRUE) :
    (cond_62 && cond_64)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_46 && ~cond_7 && ~cond_84)? (`TRUE) :
    (cond_97 && cond_46 && ~cond_7 && ~cond_99 && cond_47)? (`TRUE) :
    (cond_109 && cond_46 && ~cond_7 && ~cond_99 && cond_47)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_46 && ~cond_231 && ~cond_84)? (`TRUE) :
    (cond_270 && cond_49)? (`TRUE) :
    1'd0;
assign wr_waiting =
    (cond_1 && cond_2)? (`TRUE) :
    (cond_6 && cond_7)? (`TRUE) :
    (cond_9 && cond_7)? (`TRUE) :
    (cond_19 && cond_7)? (`TRUE) :
    (cond_41 && cond_7)? (`TRUE) :
    (cond_50 && cond_7)? (`TRUE) :
    (cond_52 && cond_53 && cond_2)? (`TRUE) :
    (cond_61 && cond_53 && cond_2)? (`TRUE) :
    (cond_65 && cond_2)? (`TRUE) :
    (cond_66 && cond_67 && cond_2)? (`TRUE) :
    (cond_70 && cond_2)? (`TRUE) :
    (cond_71 && cond_7)? (`TRUE) :
    (cond_72 && cond_2)? (`TRUE) :
    (cond_75 && cond_7)? (`TRUE) :
    (cond_82 && ~cond_83 && cond_46 && cond_7)? (`TRUE) :
    (cond_97 && cond_46 && cond_7)? (`TRUE) :
    (cond_109 && cond_46 && cond_7)? (`TRUE) :
    (cond_113 && cond_2)? (`TRUE) :
    (cond_124 && cond_2)? (`TRUE) :
    (cond_133 && cond_2)? (`TRUE) :
    (cond_139 && cond_140 && cond_2)? (`TRUE) :
    (cond_160 && cond_161)? (`TRUE) :
    (cond_164 && cond_7)? (`TRUE) :
    (cond_165 && cond_2)? (`TRUE) :
    (cond_171 && cond_2)? (`TRUE) :
    (cond_175 && cond_2)? (`TRUE) :
    (cond_179 && cond_67 && cond_2)? (`TRUE) :
    (cond_183 && cond_7)? (`TRUE) :
    (cond_184 && cond_7)? (`TRUE) :
    (cond_187 && cond_7)? (`TRUE) :
    (cond_190 && cond_7)? (`TRUE) :
    (cond_191 && cond_7)? (`TRUE) :
    (cond_197 && cond_198 && cond_7)? (`TRUE) :
    (cond_200 && cond_7)? (`TRUE) :
    (cond_201 && cond_7)? (`TRUE) :
    (cond_202 && cond_203 && cond_7)? (`TRUE) :
    (cond_204 && cond_205 && cond_7)? (`TRUE) :
    (cond_208 && cond_209 && cond_7)? (`TRUE) :
    (cond_214 && cond_216 && cond_7)? (`TRUE) :
    (cond_223 && cond_224 && cond_7)? (`TRUE) :
    (cond_229 && ~cond_230 && cond_46 && cond_231)? (`TRUE) :
    (cond_237 && cond_238 && cond_239 && cond_7)? (`TRUE) :
    (cond_243 && cond_244 && cond_231)? (`TRUE) :
    (cond_251 && cond_252 && cond_7)? (`TRUE) :
    (cond_254 && cond_252 && cond_7)? (`TRUE) :
    (cond_256 && cond_252 && cond_7)? (`TRUE) :
    (cond_257 && cond_258 && cond_7)? (`TRUE) :
    (cond_266 && cond_7)? (`TRUE) :
    (cond_272 && cond_7)? (`TRUE) :
    (cond_274 && cond_7)? (`TRUE) :
    1'd0;
assign write_seg_cache_valid =
    (cond_214 && cond_216 && ~cond_7)? (`TRUE) :
    (cond_214 && cond_221)? (`TRUE) :
    (cond_235 && cond_18)? (`TRUE) :
    (cond_235 && cond_24)? (`TRUE) :
    (cond_235 && cond_236)? (`TRUE) :
    (cond_237 && cond_238 && cond_239 && ~cond_7)? (`TRUE) :
    (cond_237 && cond_238 && cond_241)? (`TRUE) :
    (cond_251 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_251 && ~cond_252)? (`TRUE) :
    (cond_254 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_254 && ~cond_252)? (`TRUE) :
    (cond_256 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_256 && ~cond_252)? (`TRUE) :
    (cond_257 && cond_258 && ~cond_7)? (`TRUE) :
    (cond_257 && ~cond_258)? (`TRUE) :
    1'd0;
assign write_seg_rpl =
    (cond_214 && cond_221 && cond_18)? (`TRUE) :
    (cond_235 && cond_18)? (`TRUE) :
    (cond_235 && cond_24)? (`TRUE) :
    (cond_235 && cond_236)? (`TRUE) :
    (cond_237 && cond_238 && cond_239 && ~cond_7)? (`TRUE) :
    (cond_237 && cond_238 && cond_241)? (`TRUE) :
    (cond_251 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_251 && ~cond_252)? (`TRUE) :
    (cond_254 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_254 && ~cond_252)? (`TRUE) :
    (cond_256 && cond_252 && ~cond_7)? (`TRUE) :
    (cond_256 && ~cond_252)? (`TRUE) :
    (cond_257 && cond_258 && ~cond_7)? (`TRUE) :
    (cond_257 && ~cond_258)? (`TRUE) :
    1'd0;
assign wr_glob_param_3_value =
    (cond_210)? ( (glob_descriptor[`DESC_BITS_TYPE] <= 4'd3)? glob_param_3 : glob_param_3 | 32'h00020000) :
    32'd0;
assign wr_debug_trap_clear =
    (cond_11)? (`TRUE) :
    (cond_195)? (`TRUE) :
    1'd0;
assign write_regrm =
    (cond_0)? (`TRUE) :
    (cond_1)? (             wr_dst_is_rm) :
    (cond_3)? (`TRUE) :
    (cond_52 && cond_53)? (         wr_dst_is_rm) :
    (cond_61 && cond_53)? (             wr_dst_is_rm) :
    (cond_65)? (     wr_dst_is_rm) :
    (cond_66 && cond_67)? (         wr_dst_is_rm) :
    (cond_70)? (         wr_dst_is_implicit_reg || wr_dst_is_rm) :
    (cond_72)? (     wr_dst_is_rm) :
    (cond_92)? ( wr_dst_is_reg) :
    (cond_95)? (`TRUE) :
    (cond_96)? (`TRUE) :
    (cond_113)? (    wr_dst_is_reg || wr_dst_is_rm || wr_dst_is_implicit_reg) :
    (cond_114)? ( wr_dst_is_reg) :
    (cond_115)? (`TRUE) :
    (cond_124)? (     wr_dst_is_rm) :
    (cond_127)? (`TRUE) :
    (cond_133)? (         wr_dst_is_rm) :
    (cond_139 && cond_140)? (         wr_dst_is_rm) :
    (cond_146 && ~cond_53)? (`TRUE) :
    (cond_157 && cond_158)? (`TRUE) :
    (cond_160 && cond_162)? (        wr_dst_is_reg || wr_dst_is_rm) :
    (cond_165)? (             wr_dst_is_rm) :
    (cond_166 && cond_167)? (`TRUE) :
    (cond_171)? (         wr_dst_is_rm) :
    (cond_173)? (`TRUE) :
    (cond_175)? (     wr_dst_is_rm) :
    (cond_179 && cond_67)? (         wr_dst_is_rm) :
    (cond_233)? (`TRUE) :
    (cond_242)? (`TRUE) :
    1'd0;
assign wr_seg_rpl =
    (cond_214 && cond_221 && cond_18)? (      2'd3) :
    (cond_235 && cond_18)? (      2'd3) :
    (cond_235 && cond_24)? (      2'd0) :
    (cond_235 && cond_236)? ( glob_param_1[1:0]) :
    (cond_237 && cond_238)? (          glob_param_1[1:0]) :
    (cond_251)? (          (wr_cmd == `CMD_CALL_2 || wr_cmd == `CMD_JMP || wr_cmd == `CMD_JMP_2 || wr_cmd == `CMD_int_2)? cpl : glob_param_1[1:0]) :
    (cond_254)? (          glob_descriptor[`DESC_BITS_DPL]) :
    (cond_256)? (          glob_param_1[1:0]) :
    (cond_257)? (          glob_param_1[1:0]) :
    2'd0;
assign wr_system_linear =
    (cond_200)? ( wr_task_switch_linear) :
    (cond_201)? ( wr_task_switch_linear) :
    (cond_202 && cond_203)? ( wr_task_switch_linear) :
    (cond_204 && cond_205)? ( glob_desc_base) :
    32'd0;
assign wr_req_reset_pr =
    (cond_14)? (`TRUE) :
    (cond_16)? (`TRUE) :
    (cond_17)? (`TRUE) :
    (cond_23)? (`TRUE) :
    (cond_30)? (`TRUE) :
    (cond_31)? (`TRUE) :
    (cond_54)? (`TRUE) :
    (cond_81 && cond_53)? (`TRUE) :
    (cond_104)? (`TRUE) :
    (cond_110 && cond_53)? (`TRUE) :
    (cond_125)? (`TRUE) :
    (cond_128)? (`TRUE) :
    (cond_131 && cond_53)? (`TRUE) :
    (cond_148)? (`TRUE) :
    (cond_185)? (`TRUE) :
    (cond_225)? (`TRUE) :
    (cond_255)? (`TRUE) :
    (cond_259)? (`TRUE) :
    1'd0;
assign wr_regrm_word =
    (cond_52)? (`TRUE) :
    1'd0;
assign write_io =
    (cond_229 && ~cond_230 && cond_46)? (`TRUE) :
    (cond_243 && cond_244)? (`TRUE) :
    1'd0;
assign wr_hlt_in_progress =
    (cond_245)? (`TRUE) :
    1'd0;
