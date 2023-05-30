/* TODO: Zhongxiang Wang zwang380
      Qinpeng          pengqin*/

`timescale 1ns / 1ps
`default_nettype none

//pc & add & ldr & jmp
module alu_pc(input  wire [15:0] i_insn,
            input wire [15:0]  i_pc,
            input wire [15:0]  i_r1data,
            input wire [15:0]  i_r2data,
            output wire [15:0] o_result);

      wire[15:0] o_result_tmp;

      wire[15:0] cla_data1, cla_data2;
      wire cla_cin;

      wire[3:0] i_ins_temp = i_insn >> 12;
      wire[2:0] insn_add = i_insn >> 3;
      wire insn_tmp = i_insn >> 11;
      wire[15:0] useless;
      wire[15:0] dividend;

      lc4_divider l1(.i_dividend(i_r1data), .i_divisor(i_r2data), .o_remainder(useless), .o_quotient(dividend));

      assign cla_data1 = (i_ins_temp[3:0] == 4'b0000) & (i_insn[8] == 1'b1) ? i_pc :
                         (i_ins_temp[3:0] == 4'b0000) & (i_insn[8] == 1'b0) ? i_pc :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:1] == 2'b10) ? i_r1data :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:1] == 2'b11) ? i_r1data :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b011) ? 1'b0 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b010) ? i_r1data :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b001) ? 1'b0 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b000) ? i_r1data :
                         (i_ins_temp[3:1] == 3'b011) & (i_insn[5] == 1'b1) ? i_r1data :
                         (i_ins_temp[3:1] == 3'b011) & (i_insn[5] == 1'b0) ? i_r1data :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[11] == 1'b0) ? i_r1data :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[10] == 1'b1) ? i_pc :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[10] == 1'b0) ? i_pc :
                         16'b0;

      assign cla_data2 = (i_ins_temp[3:0] == 4'b0000) & (i_insn[8] == 1'b1) ? (16'b1111111111111111 << 9 | i_insn[8:0]) :
                         (i_ins_temp[3:0] == 4'b0000) & (i_insn[8] == 1'b0) ? (16'b0 | i_insn[7:0]) :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:1] == 2'b10) ? (16'b0 | i_insn[4:0]) :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:1] == 2'b11) ? ((16'b1111111111111111 << 5) | i_insn[4:0]) :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b011) ? (i_r1data > i_r2data) ? dividend : 16'b0 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b010) ? ~i_r2data :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b001) ? i_r1data * i_r2data :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b000) ? i_r2data :
                         (i_ins_temp[3:1] == 3'b011) & (i_insn[5] == 1'b1) ? (16'b1111111111111111 << 6 | i_insn[5:0]) :
                         (i_ins_temp[3:1] == 3'b011) & (i_insn[5] == 1'b0) ? (16'b0 << 5 | i_insn[4:0]) :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[11] == 1'b0) ? 16'b0 :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[10] == 1'b1) ? (16'b1111111111111111 << 11| i_insn[10:0]) :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[10] == 1'b0) ? (16'b0 | i_insn[10:0]) :
                         16'b0;
                         
      assign cla_cin =   (i_ins_temp[3:0] == 4'b0000) & (i_insn[8] == 1'b1) ? 1'b1 :
                         (i_ins_temp[3:0] == 4'b0000) & (i_insn[8] == 1'b0) ? 1'b1 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:1] == 2'b10) ? 1'b0 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:1] == 2'b11) ? 1'b0 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b011) ? 1'b0 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b010) ? 1'b1 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b001) ? 1'b0 :
                         (i_ins_temp[3:0] == 4'b0001) & (insn_add[2:0] == 3'b000) ? 1'b0 :
                         (i_ins_temp[3:1] == 3'b011) & (i_insn[5] == 1'b1) ? 1'b0 :
                         (i_ins_temp[3:1] == 3'b011) & (i_insn[5] == 1'b0) ? 1'b0 :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[11] == 1'b0) ? 1'b0 :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[10] == 1'b1) ? 1'b1 :
                         (i_ins_temp[3:0] == 4'b1100) & (i_insn[10] == 1'b0) ? 1'b1 :
                         1'b0;

      cla16 c1(.a(cla_data1), .b(cla_data2), .cin(cla_cin), .sum(o_result_tmp[15:0]));

      assign o_result[15:0] = o_result_tmp;

endmodule

module alu_cmp(input  wire [15:0] i_insn,
            input wire [15:0]  i_pc,
            input wire [15:0]  i_r1data,
            input wire [15:0]  i_r2data,
            output wire [15:0] o_result);

      wire[1:0] insn_tmp = i_insn >> 7;
      wire[9:0] r1data_n = i_r1data >> 6;

      assign o_result[15:0] = (insn_tmp[1:0] == 2'b00) ?    ((i_r1data[15] & i_r2data[15] & 1'b1) & (i_r1data < i_r2data)) |
                                                            (((i_r1data[15] ^ 1'b1) & (i_r2data[15] ^ 1'b1)) & (i_r1data < i_r2data)) | 
                                                            (i_r1data[15] > i_r2data[15])  ?  16'b1111111111111111: 

                                                            ((i_r1data[15] & i_r2data[15] & 1'b1) & (i_r1data > i_r2data)) |
                                                            (((i_r1data[15] ^ 1'b1) & (i_r2data[15] ^ 1'b1)) & (i_r1data > i_r2data)) | 
                                                            (i_r1data[15] < i_r2data[15])  ?  16'b0000000000000001:
                                                            16'b0:
                              (insn_tmp[1:0] == 2'b10) ?    ((r1data_n == 10'b1111111111) & (i_r1data[6:0] == i_insn[6:0])) ?  16'b0 : 
                                                            ((i_r1data[15] & i_insn[6] & 1'b1) & (i_r1data > i_insn[6:0])) | 
                                                            (((i_r1data[15] ^ 1'b1) & (i_insn[6] ^ 1'b1)) & (i_r1data < i_insn[6:0])) | 
                                                            (i_r1data[15] > i_insn[6])  ?  16'b1111111111111111: 
                                                            
                                                            ((i_r1data[15] & i_insn[6] & 1'b1) & (i_r1data < i_insn[6:0])) | 
                                                            (((i_r1data[15] ^ 1'b1) & (i_insn[6] ^ 1'b1)) & (i_r1data > i_insn[6:0])) | 
                                                            (i_r1data[15] < i_insn[6])  ?  16'b0000000000000001: 
                                                            16'b0 : 
                              (insn_tmp[1:0] == 2'b11) ?  (i_r1data > i_insn[6:0]) ? 16'b0000000000000001 :(i_r1data < i_insn[6:0]) ? 16'b1111111111111111: 16'b0 : 
                              (insn_tmp[1:0] == 2'b01) ?  (i_r1data > i_r2data) ? 16'b0000000000000001 : 16'b1111111111111111 :
                              16'b0; 
endmodule

module alu_jsr(input  wire [15:0] i_insn,
            input wire [15:0]  i_pc,
            input wire [15:0]  i_r1data,
            input wire [15:0]  i_r2data,
            output wire [15:0] o_result);

      wire insn_tmp = i_insn >> 11;
      wire[15:0] insn_use = i_insn << 4;

      assign o_result[15:0] = (insn_tmp == 1'b0) ?  i_r1data :
                              (insn_tmp == 1'b1) ?  (i_pc[15] == 1'b1) ? {1'b1, insn_use[14:0]}: {1'b0, insn_use[14:0]} :
                              16'b0; 
endmodule

module alu_and(input  wire [15:0] i_insn,
            input wire [15:0]  i_pc,
            input wire [15:0]  i_r1data,
            input wire [15:0]  i_r2data,
            output wire [15:0] o_result);

      wire[2:0] insn_tmp = i_insn >> 3;
      wire[4:0] insn_andi = i_r1data & i_insn[4:0];

      assign o_result[15:0] = (insn_tmp == 3'b000) ?  i_r1data & i_r2data :
                              (insn_tmp == 3'b001) ?  ~i_r1data :
                              (insn_tmp == 3'b010) ?  i_r1data | i_r2data :
                              (insn_tmp == 3'b011) ?  i_r1data ^ i_r2data :
                              (i_insn[4] == 1'b1) ? {i_r1data[15:5], insn_andi}:
                              i_r1data & i_insn[4:0]; 
endmodule

module alu_sll(input  wire [15:0] i_insn,
            input wire [15:0]  i_pc,
            input wire [15:0]  i_r1data,
            input wire [15:0]  i_r2data,
            output wire [15:0] o_result);

      wire[1:0] insn_tmp = i_insn >> 4;
      wire[3:0] insn_use = i_insn;

      wire[15:0] useless;
      wire[15:0] remainder;

      lc4_divider l2(.i_dividend(i_r1data), .i_divisor(i_r2data), .o_remainder(remainder),.o_quotient(useless));
      
      assign o_result[15:0] = (insn_tmp == 2'b00) ? i_r1data << insn_use:
                              (insn_tmp == 2'b01) ? i_r1data[15] == 1'b1 ?  {16'b1111111111111111, i_r1data} >> insn_use : i_r1data >> insn_use :
                              (insn_tmp == 2'b10) ? i_r1data >> insn_use:
                              (insn_tmp == 2'b11) ? remainder:
                              16'b0; 
endmodule

module lc4_alu(input  wire [15:0] i_insn,
               input wire [15:0]  i_pc,
               input wire [15:0]  i_r1data,
               input wire [15:0]  i_r2data,
               output wire [15:0] o_result);

      wire [3:0] i_ins_temp = i_insn >> 12;
      wire [8:0] i_ins_const = i_insn[8:0];
      wire [7:0] i_ins_hiconst = i_insn[7:0];
      wire [7:0] r1data_hiconst = i_r1data[7:0];

      wire [15:0] out_pc_add_ldr_jmp; //pc & add & ldr & jmp
      wire [15:0] out_cmp;
      wire [15:0] out_jsr;
      wire [15:0] out_and1;
      wire [15:0] out_sll;

      alu_pc nop(  .i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .i_r2data(i_r2data), .o_result(out_pc_add_ldr_jmp));
      alu_cmp cmp( .i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .i_r2data(i_r2data), .o_result(out_cmp));
      alu_jsr jsr( .i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .i_r2data(i_r2data), .o_result(out_jsr));
      alu_and and1(.i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .i_r2data(i_r2data), .o_result(out_and1));
      alu_sll sll( .i_insn(i_insn), .i_pc(i_pc), .i_r1data(i_r1data), .i_r2data(i_r2data), .o_result(out_sll));


      assign o_result[15:0] = (i_ins_temp[3:0] == 4'b0000) ?  out_pc_add_ldr_jmp :
                              (i_ins_temp[3:0] == 4'b0001) ?  out_pc_add_ldr_jmp :
                              (i_ins_temp[3:0] == 4'b0010) ?  out_cmp :
                              (i_ins_temp[3:0] == 4'b0100) ?  out_jsr :
                              (i_ins_temp[3:0] == 4'b0101) ?  out_and1 :
                              (i_ins_temp[3:1] == 3'b011) ?  out_pc_add_ldr_jmp :
                              (i_ins_temp[3:0] == 4'b1000) ?  i_r1data :      
                              (i_ins_temp[3:0] == 4'b1001) ?  (i_insn[8] == 1) ? {7'b1111111, i_ins_const} : i_ins_const : 
                              (i_ins_temp[3:0] == 4'b1010) ?  out_sll :      
                              (i_ins_temp[3:0] == 4'b1100) ?  out_pc_add_ldr_jmp :          
                              (i_ins_temp[3:0] == 4'b1101) ?  {i_ins_hiconst, r1data_hiconst} :
                              (i_ins_temp[3:0] == 4'b1111) ?  {8'b10000000, i_ins_hiconst} :                
                              16'b0;

endmodule