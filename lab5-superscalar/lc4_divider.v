/* TODO: Zhongxiang Wang   zwang380
         Peng       Qin    pengqin*/

`timescale 1ns / 1ps
`default_nettype none

module lc4_divider(input  wire [15:0] i_dividend,
                   input  wire [15:0] i_divisor,
                   output wire [15:0] o_remainder,
                   output wire [15:0] o_quotient);

      wire [15:0] new_quotient[16:0];
      wire [15:0] remainder[16:0];
      wire [15:0] new_dividend[16:0];
 
      assign new_quotient[0] = 16'd0;
      assign remainder[0] = 16'd0;
      assign new_dividend[0] = i_dividend;
      /*
      genvar i;
      for(i = 0; i < 16; i = i+1) begin
        lc4_divider_one_iter dut00(.i_dividend(new_dividend[i]), .i_divisor(i_divisor), .i_remainder(remainder[i]), .i_quotient(quotient[i]), .o_dividend(new_dividend[i+1]), .o_remainder(remainder[i+1]), .o_quotient(quotient[i+1]));
      end
      */
      lc4_divider_one_iter dut00(.i_dividend(new_dividend[0]), .i_divisor(i_divisor),.i_remainder(remainder[0]),.i_quotient(new_quotient[0]),.o_dividend(new_dividend[1]),.o_remainder(remainder[1]),.o_quotient(new_quotient[1]));
      lc4_divider_one_iter dut01(.i_dividend(new_dividend[1]), .i_divisor(i_divisor),.i_remainder(remainder[1]),.i_quotient(new_quotient[1]),.o_dividend(new_dividend[2]),.o_remainder(remainder[2]),.o_quotient(new_quotient[2]));
      lc4_divider_one_iter dut02(.i_dividend(new_dividend[2]), .i_divisor(i_divisor),.i_remainder(remainder[2]),.i_quotient(new_quotient[2]),.o_dividend(new_dividend[3]),.o_remainder(remainder[3]),.o_quotient(new_quotient[3]));
      lc4_divider_one_iter dut03(.i_dividend(new_dividend[3]), .i_divisor(i_divisor),.i_remainder(remainder[3]),.i_quotient(new_quotient[3]),.o_dividend(new_dividend[4]),.o_remainder(remainder[4]),.o_quotient(new_quotient[4]));
      lc4_divider_one_iter dut04(.i_dividend(new_dividend[4]), .i_divisor(i_divisor),.i_remainder(remainder[4]),.i_quotient(new_quotient[4]),.o_dividend(new_dividend[5]),.o_remainder(remainder[5]),.o_quotient(new_quotient[5]));
      lc4_divider_one_iter dut05(.i_dividend(new_dividend[5]), .i_divisor(i_divisor),.i_remainder(remainder[5]),.i_quotient(new_quotient[5]),.o_dividend(new_dividend[6]),.o_remainder(remainder[6]),.o_quotient(new_quotient[6]));
      lc4_divider_one_iter dut06(.i_dividend(new_dividend[6]), .i_divisor(i_divisor),.i_remainder(remainder[6]),.i_quotient(new_quotient[6]),.o_dividend(new_dividend[7]),.o_remainder(remainder[7]),.o_quotient(new_quotient[7]));
      lc4_divider_one_iter dut07(.i_dividend(new_dividend[7]), .i_divisor(i_divisor),.i_remainder(remainder[7]),.i_quotient(new_quotient[7]),.o_dividend(new_dividend[8]),.o_remainder(remainder[8]),.o_quotient(new_quotient[8]));
      lc4_divider_one_iter dut08(.i_dividend(new_dividend[8]), .i_divisor(i_divisor),.i_remainder(remainder[8]),.i_quotient(new_quotient[8]),.o_dividend(new_dividend[9]),.o_remainder(remainder[9]),.o_quotient(new_quotient[9]));
      lc4_divider_one_iter dut09(.i_dividend(new_dividend[9]), .i_divisor(i_divisor),.i_remainder(remainder[9]),.i_quotient(new_quotient[9]),.o_dividend(new_dividend[10]),.o_remainder(remainder[10]),.o_quotient(new_quotient[10]));
      lc4_divider_one_iter dut10(.i_dividend(new_dividend[10]), .i_divisor(i_divisor),.i_remainder(remainder[10]),.i_quotient(new_quotient[10]),.o_dividend(new_dividend[11]),.o_remainder(remainder[11]),.o_quotient(new_quotient[11]));
      lc4_divider_one_iter dut11(.i_dividend(new_dividend[11]), .i_divisor(i_divisor),.i_remainder(remainder[11]),.i_quotient(new_quotient[11]),.o_dividend(new_dividend[12]),.o_remainder(remainder[12]),.o_quotient(new_quotient[12]));
      lc4_divider_one_iter dut12(.i_dividend(new_dividend[12]), .i_divisor(i_divisor),.i_remainder(remainder[12]),.i_quotient(new_quotient[12]),.o_dividend(new_dividend[13]),.o_remainder(remainder[13]),.o_quotient(new_quotient[13]));
      lc4_divider_one_iter dut13(.i_dividend(new_dividend[13]), .i_divisor(i_divisor),.i_remainder(remainder[13]),.i_quotient(new_quotient[13]),.o_dividend(new_dividend[14]),.o_remainder(remainder[14]),.o_quotient(new_quotient[14]));
      lc4_divider_one_iter dut14(.i_dividend(new_dividend[14]), .i_divisor(i_divisor),.i_remainder(remainder[14]),.i_quotient(new_quotient[14]),.o_dividend(new_dividend[15]),.o_remainder(remainder[15]),.o_quotient(new_quotient[15]));
      lc4_divider_one_iter dut15(.i_dividend(new_dividend[15]), .i_divisor(i_divisor),.i_remainder(remainder[15]),.i_quotient(new_quotient[15]),.o_dividend(new_dividend[16]),.o_remainder(remainder[16]),.o_quotient(new_quotient[16]));
     
      assign  o_remainder = remainder[16] ;
      assign o_quotient = new_quotient[16] ;

endmodule // lc4_divider

module lc4_divider_one_iter(input  wire [15:0] i_dividend,
                            input  wire [15:0] i_divisor,
                            input  wire [15:0] i_remainder,
                            input  wire [15:0] i_quotient,
                            output wire [15:0] o_dividend,
                            output wire [15:0] o_remainder,
                            output wire [15:0] o_quotient);

      wire [15:0] new_remainder;
      wire [15:0] compare;
      wire [15:0] new_quotient;
      wire [15:0] remainder;
      
      //  & 1'b1 can delete 
         
      assign new_remainder = (i_remainder << 1) | ((i_dividend>> 15 ) & 1'b1);
      assign compare = new_remainder < i_divisor;
      
      //  & 1'b0 can delete 
      assign new_quotient = compare[0] ? ((i_quotient << 1) | 1'b0) : ((i_quotient << 1) | 1'b1);
      assign remainder = compare[0] ? new_remainder : (new_remainder - i_divisor);

      assign o_quotient  = (i_divisor == 0) ? 1'b0 : new_quotient;
      assign o_remainder = (i_divisor == 0) ? 1'b0 : remainder;
      assign o_dividend  = i_dividend << 1;

endmodule
