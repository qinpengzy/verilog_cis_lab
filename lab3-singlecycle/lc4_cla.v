/* TODO: Zhongxiang Wang zwang380
         Qinpeng          pengqin */

`timescale 1ns / 1ps
`default_nettype none

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);
    assign cout[0] = gin[0] | pin[0] & cin ;
    assign cout[1] = gin[1] | pin[1] & cout[0];
    assign cout[2] = gin[2] | pin[2] & cout[1];
    //assign cout[4] = gin[3] | pin[3] & gin[2] | pin[3] & pin[2] & gin[1] | pin[3] & pin[2] & pin[1] & gin[0] | pin[3] & pin[2] & pin[1] & pin[0] & cin

    assign gout = gin[3] | pin[3] & gin[2] | pin[3] & pin[2] & gin[1] | pin[3] & pin[2] & pin[1] & gin[0] ;
    assign pout = pin[3] & pin[2] & pin[1] & pin[0] ;
endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);
   
   
   wire gout[3:0];
   wire pout[3:0];
   wire [15:0] p;
   wire [15:0] g; 
   wire [15:0] c;
  genvar i  ;
   for (i = 0; i < 16; i = i + 1) begin   
      gp1 g0(.a(a[i]),
	     .b(b[i]),
	     .g(g[i]),
	     .p(p[i]));
   end

    gp4 m1(.gin(g[3:0]), .pin(p[3:0]), .cin(cin), .gout(gout[0]), .pout(pout[0]), .cout(c[2:0]));
    assign c[3] = gout[0] | pout[0] & cin;

    gp4 m2(.gin(g[7:4]), .pin(p[7:4]), .cin(c[3]), .gout(gout[1]), .pout(pout[1]), .cout(c[6:4]));
    assign c[7] = gout[1] | pout[1] & c[3];

    gp4 m3(.gin(g[11:8]), .pin(p[11:8]), .cin(c[7]), .gout(gout[2]), .pout(pout[2]), .cout(c[10:8]));
    assign c[11] = gout[2] | pout[2] & c[7];

    gp4 m4(.gin(g[15:12]), .pin(p[15:12]), .cin(c[11]), .gout(gout[3]), .pout(pout[3]), .cout(c[14:12]));
    assign c[15] = gout[3] | pout[3] & c[11];

    assign sum[0] = a[0] ^ b[0] ^ cin;

  for(i = 1; i < 16; i = i + 1) begin
    assign sum[i] = a[i] ^ b[i] ^ c[i-1];
  end
endmodule


/** Lab 2 Extra Credit, see details at
  https://github.com/upenn-acg/cis501/blob/master/lab2-alu/lab2-cla.md#extra-credit
 If you are not doing the extra credit, you should leave this module empty.
 */
module gpn
  #(parameter N = 4)
  (input wire [N-1:0] gin, pin,
   input wire  cin,
   output wire gout, pout,
   output wire [N-2:0] cout);

   wire [N-1:0] gout_tmp;

  genvar i;
   for (i = 0; i < N - 1; i = i + 1) begin   
      assign cout[i] = gin[i] | pin[i] & ((i == 0)? cin : cout[i-1]) ;
   end

  assign pout = (~pin > 1'b0) ?  1'b0 : 1'b1;
  //assign gout = (N > 2'b10)? gin[N-2] | pin[N-2] & cout[N-1] :  gin[0] | pin[0] & cin;

   for (i = 0; i < N ; i = i + 1) begin   
      assign gout_tmp[i] = (i == 0)? gin[0] : gin[i] | pin[i] & gout_tmp[i - 1] ;
   end

   assign gout = gout_tmp[N - 1];
 
endmodule
