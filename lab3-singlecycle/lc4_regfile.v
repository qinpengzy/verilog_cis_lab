/* TODO: Zhongxiang Wang zwang380
         Qinpeng          pengqin
 *
 * lc4_regfile.v
 * Implements an 8-register register file parameterized on word size.
 *
 */

`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

module lc4_regfile #(parameter n = 16)
   (input  wire         clk,
    input  wire         gwe,
    input  wire         rst,
    input  wire [  2:0] i_rs,      // rs selector
    output wire [n-1:0] o_rs_data, // rs contents
    input  wire [  2:0] i_rt,      // rt selector
    output wire [n-1:0] o_rt_data, // rt contents
    input  wire [  2:0] i_rd,      // rd selector
    input  wire [n-1:0] i_wdata,   // data to write
    input  wire         i_rd_we    // write enable
    );

   
    wire [n-1:0] result0, result1, result2, result3, result4, result5, result6, result7;

   Nbit_reg #(n) r0 (.in(i_wdata),.out(result0),.clk(clk),.we((i_rd == 3'd0) & i_rd_we),.gwe(gwe),.rst(rst));
   
   Nbit_reg #(n) r1 (.in(i_wdata),.out(result1),.clk(clk),.we((i_rd == 3'd1) & i_rd_we),.gwe(gwe),.rst(rst));
   
   Nbit_reg #(n) r2 (.in(i_wdata),.out(result2),.clk(clk),.we((i_rd == 3'd2) & i_rd_we),.gwe(gwe),.rst(rst));
   
   Nbit_reg #(n) r3 (.in(i_wdata),.out(result3),.clk(clk),.we((i_rd == 3'd3) & i_rd_we),.gwe(gwe),.rst(rst));
   
   Nbit_reg #(n) r4 (.in(i_wdata),.out(result4),.clk(clk),.we((i_rd == 3'd4) & i_rd_we),.gwe(gwe),.rst(rst));
   
   Nbit_reg #(n) r5 (.in(i_wdata),.out(result5),.clk(clk),.we((i_rd == 3'd5) & i_rd_we),.gwe(gwe),.rst(rst));
   
   Nbit_reg #(n) r6 (.in(i_wdata),.out(result6),.clk(clk),.we((i_rd == 3'd6) & i_rd_we),.gwe(gwe),.rst(rst));
   
   Nbit_reg #(n) r7 (.in(i_wdata),.out(result7),.clk(clk),.we((i_rd == 3'd7) & i_rd_we),.gwe(gwe),.rst(rst));

   //select read source Values for read port
   assign o_rs_data = i_rs == 3'd0 ? result0 :
                      i_rs == 3'd1 ? result1 :
                      i_rs == 3'd2 ? result2 :
                      i_rs == 3'd3 ? result3 :
                      i_rs == 3'd4 ? result4 :
                      i_rs == 3'd5 ? result5 :
                      i_rs == 3'd6 ? result6 :
                      result7;

   assign o_rt_data = i_rt == 3'd0 ? result0 :
                      i_rt == 3'd1 ? result1 :
                      i_rt == 3'd2 ? result2 :
                      i_rt == 3'd3 ? result3 :
                      i_rt == 3'd4 ? result4 :
                      i_rt == 3'd5 ? result5 :
                      i_rt == 3'd6 ? result6 :
                      result7;

endmodule
