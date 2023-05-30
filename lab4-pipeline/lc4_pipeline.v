/* TODO: Zhongxiang Wang   zwang380
         Peng       Qin    pengqin*/

`timescale 1ns / 1ps

// disable implicit wire declaration
`default_nettype none

module lc4_processor
   (input  wire        clk,                // main clock
    input wire         rst, // global reset
    input wire         gwe, // global we for single-step clock
                                    
    output wire [15:0] o_cur_pc, // Address to read from instruction memory
    input wire [15:0]  i_cur_insn, // Output of instruction memory
    output wire [15:0] o_dmem_addr, // Address to read/write from/to data memory
    input wire [15:0]  i_cur_dmem_data, // Output of data memory
    output wire        o_dmem_we, // Data memory write enable
    output wire [15:0] o_dmem_towrite, // Value to write to data memory
   
    output wire [1:0]  test_stall, // Testbench: is this is stall cycle? (don't compare the test values)
    output wire [15:0] test_cur_pc, // Testbench: program counter
    output wire [15:0] test_cur_insn, // Testbench: instruction bits
    output wire        test_regfile_we, // Testbench: register file write enable
    output wire [2:0]  test_regfile_wsel, // Testbench: which register to write in the register file 
    output wire [15:0] test_regfile_data, // Testbench: value to write into the register file
    output wire        test_nzp_we, // Testbench: NZP condition codes write enable
    output wire [2:0]  test_nzp_new_bits, // Testbench: value to write to NZP bits
    output wire        test_dmem_we, // Testbench: data memory write enable
    output wire [15:0] test_dmem_addr, // Testbench: address to read/write memory
    output wire [15:0] test_dmem_data, // Testbench: value read/writen from/to memory

    input wire [7:0]   switch_data, // Current settings of the Zedboard switches
    output wire [7:0]  led_data // Which Zedboard LEDs should be turned on?
    );

   // Data mem
   assign o_dmem_addr = m_is_load ? m_alu_result  : 
                        m_is_store ? m_alu_result : 
                        16'b0;
   assign o_dmem_we = m_is_store; // store
   assign o_dmem_towrite = (m_is_store) ? m_rt_data : 16'b0;

   //output
   assign test_stall = w_stall;
   assign test_cur_pc = w_pc;
   assign test_cur_insn = w_insn;
   assign test_regfile_we = w_regfile_we;
   assign test_regfile_wsel = w_wsel;
   assign test_regfile_data = w_mux_output;
   assign test_nzp_we = w_nzp_we_pass;
   assign test_nzp_new_bits = w_nzp_we_pass ? m_nzp_bits : 3'b0;
   assign test_dmem_we = w_is_store;
   assign test_dmem_addr = w_dmem_addr;
   assign test_dmem_data = w_is_load ? w_dmem_output: w_is_store ? w_rt_data: 16'b0;



//test output below -----------



   lc4_decoder d1 (.insn(d_insn),        // instruction
                   .r1sel(r1sel),            // rs
                   .r1re(r1re),              // does this instruction read from rs?
                   .r2sel(r2sel),            // rt
                   .r2re(r2re),              // does this instruction read from rt?
                   .wsel(wsel),              // rd
                   .regfile_we(regfile_we),  // does this instruction write to rd?
                   .nzp_we(nzp_we),          // does this instruction write the NZP bits?
                   .select_pc_plus_one(select_pc_plus_one),    // write PC+1 to the regfile?
                   .is_load(is_load),        // is this a load instruction?
                   .is_store(is_store),      // is this a store instruction?
                   .is_branch(is_branch),    // is this a branch instruction?
                   .is_control_insn(is_control_insn));   // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?

   lc4_decoder d1_tmp (.insn(d_insn_tmp),        // instruction
                   .r1sel(r1sel_tmp),            // rs
                   .r1re(r1re_tmp),              // does this instruction read from rs?
                   .r2sel(r2sel_tmp),            // rt
                   .r2re(r2re_tmp),              // does this instruction read from rt?
                   .wsel(wsel_tmp),              // rd
                   .regfile_we(regfile_we_tmp),  // does this instruction write to rd?
                   .nzp_we(nzp_we_tmp),          // does this instruction write the NZP bits?
                   .select_pc_plus_one(select_pc_plus_one_tmp),    // write PC+1 to the regfile?
                   .is_load(is_load_tmp),        // is this a load instruction?
                   .is_store(is_store_tmp),      // is this a store instruction?
                   .is_branch(is_branch_tmp),    // is this a branch instruction?
                   .is_control_insn(is_control_insn_tmp));   // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?


   lc4_decoder x1 (.insn(x_insn),        // instruction
                   .r1sel(x_r1sel),            // rs
                   .r1re(x_r1re),              // does this instruction read from rs?
                   .r2sel(x_r2sel),            // rt
                   .r2re(x_r2re),              // does this instruction read from rt?
                   .wsel(x_wsel),              // rd
                   .regfile_we(x_regfile_we),  // does this instruction write to rd?
                   .nzp_we(x_nzp_we),          // does this instruction write the NZP bits?
                   .select_pc_plus_one(x_select_pc_plus_one),    // write PC+1 to the regfile?
                   .is_load(x_is_load),        // is this a load instruction?
                   .is_store(x_is_store),      // is this a store instruction?
                   .is_branch(x_is_branch),    // is this a branch instruction?
                   .is_control_insn(x_is_control_insn));   // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?

   lc4_decoder m1 (.insn(m_insn),        // instruction
                   .r1sel(m_r1sel),            // rs
                   .r1re(m_r1re),              // does this instruction read from rs?
                   .r2sel(m_r2sel),            // rt
                   .r2re(m_r2re),              // does this instruction read from rt?
                   .wsel(m_wsel),              // rd
                   .regfile_we(m_regfile_we),  // does this instruction write to rd?
                   .nzp_we(m_nzp_we),          // does this instruction write the NZP bits?
                   .select_pc_plus_one(m_select_pc_plus_one),    // write PC+1 to the regfile?
                   .is_load(m_is_load),        // is this a load instruction?
                   .is_store(m_is_store),      // is this a store instruction?
                   .is_branch(m_is_branch),    // is this a branch instruction?
                   .is_control_insn(m_is_control_insn));   // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?

   lc4_decoder w1 (.insn(w_insn),        // instruction
                   .r1sel(w_r1sel),            // rs
                   .r1re(w_r1re),              // does this instruction read from rs?
                   .r2sel(w_r2sel),            // rt
                   .r2re(w_r2re),              // does this instruction read from rt?
                   .wsel(w_wsel),              // rd
                   .regfile_we(w_regfile_we),  // does this instruction write to rd?
                   .nzp_we(w_nzp_we),          // does this instruction write the NZP bits?
                   .select_pc_plus_one(w_select_pc_plus_one),    // write PC+1 to the regfile?
                   .is_load(w_is_load),        // is this a load instruction?
                   .is_store(w_is_store),      // is this a store instruction?
                   .is_branch(w_is_branch),    // is this a branch instruction?
                   .is_control_insn(w_is_control_insn));   // is this a control instruction (JSR, JSRR, RTI, JMPR, JMP, TRAP)?

   // insert decoder
   wire [1:0] f_stall, d_stall, x_stall, m_stall, w_stall, f_insn_tmp;
   wire [15:0] d_insn_tmp, d_insn, x_insn, m_insn, w_insn;
   wire [2:0] r1sel_tmp, r1sel, x_r1sel, m_r1sel, w_r1sel;
   wire r1re_tmp, r1re, x_r1re, m_r1re, w_r1re ;
   wire [2:0] r2sel_tmp, r2sel, x_r2sel, m_r2sel, w_r2sel ;
   wire r2re_tmp, r2re, x_r2re, m_r2re, w_r2re ;
   wire [2:0] wsel_tmp, wsel, x_wsel, m_wsel, w_wsel ;
   wire regfile_we_tmp, regfile_we, x_regfile_we, m_regfile_we, w_regfile_we ;
   wire nzp_we_tmp, nzp_we, x_nzp_we, m_nzp_we, w_nzp_we;
   wire select_pc_plus_one_tmp, select_pc_plus_one, x_select_pc_plus_one, m_select_pc_plus_one, w_select_pc_plus_one ;
   wire is_load_tmp, is_load, x_is_load, m_is_load, w_is_load ;
   wire is_store_tmp, is_store, x_is_store, m_is_store, w_is_store ;
   wire is_branch_tmp, is_branch, x_is_branch, m_is_branch, w_is_branch ;
   wire is_control_insn_tmp, is_control_insn, x_is_control_insn, m_is_control_insn, w_is_control_insn ;

//stall
   assign f_stall = ((x_is_branch & x_is_branch_taken) | x_is_control_insn) ? 2'd2 : 2'd0;
   wire is_stall = x_is_load & (((r1sel_tmp == x_wsel) & r1re_tmp) | (((r2sel_tmp == x_wsel) & r2re_tmp ) & (~is_store_tmp)) | is_branch_tmp); // go over logistac of using d_is_store here
   assign d_stall = is_stall ? 2'd3 : ((x_is_branch & x_is_branch_taken) | x_is_control_insn) ? 2'd2 : f_insn_tmp;
   wire flush_signal = ((x_is_branch & x_is_branch_taken) | x_is_control_insn) ? 1'b1 : 1'b0;
   Nbit_reg #(2, 2'd2) f_d_stall (.in(f_stall), .out(f_insn_tmp), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(2, 2'd2) d_x_stall (.in(d_stall), .out(x_stall), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(2, 2'd2) x_m_stall (.in(x_stall), .out(m_stall), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(2, 2'd2) m_w_stall (.in(m_stall), .out(w_stall), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   wire x_is_branch_taken = (x_bypassed_nzp_bits[2] & x_insn[11]) | (x_bypassed_nzp_bits[1] & x_insn[10]) | (x_bypassed_nzp_bits[0] & x_insn[9]);
   assign d_insn = (is_stall | (x_is_branch & x_is_branch_taken) | x_is_control_insn) ? 16'b0 : d_insn_tmp; //add a nop

//insn
   wire [15:0] f_insn = ((x_is_branch & x_is_branch_taken) | x_is_control_insn) ? 16'b0 : i_cur_insn;
   // Nbit_reg #(16) f_d_insn (.in(flush_signal ? 16'b0 : f_insn), .out(d_insn_tmp), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   // Nbit_reg #(16) d_x_insn (.in(flush_signal ? 16'b1 : d_insn), .out(x_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) f_d_insn (.in(f_insn), .out(d_insn_tmp), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) d_x_insn (.in(d_insn), .out(x_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) x_m_insn (.in(x_insn), .out(m_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) m_w_insn (.in(m_insn), .out(w_insn), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

//insert pc caluation
   // pc wires attached to the PC register's ports
   wire [15:0]   pc;      // Current program counter (read out from pc_reg)
   wire [15:0]   next_pc; // Next program counter (you compute this and feed it into next_pc)

   // Program counter register, starts at 8200h at bootup
   Nbit_reg #(16, 16'h8200) pc_reg (.in(next_pc), .out(pc_tmp), .clk(clk), .we(d_stall != 2'd3), .gwe(gwe), .rst(rst));
   wire [15:0] pc_result, d_pc, x_pc, m_pc, w_pc, pc_tmp; 
   assign pc = (d_stall == 2'd3) ? pc_tmp - 1 : ((x_is_branch & x_is_branch_taken) | x_is_control_insn) ? alu_result - 1 : pc_tmp;
   cla16 c1(.a(pc), .b(16'b0), .cin(1'b1), .sum(pc_result));
   assign next_pc = ((x_is_branch & x_is_branch_taken) | x_is_control_insn) ? alu_result : pc_result;
   Nbit_reg #(16) f_d_pc (.in(pc), .out(d_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) d_x_pc (.in(d_pc), .out(x_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) x_m_pc (.in(x_pc), .out(m_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) m_w_pc (.in(m_pc), .out(w_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   assign o_cur_pc = pc;

//insert alu for x and reg it
   wire [15:0] alu_result, m_alu_result, w_alu_result, w_dmem_output;
   lc4_alu a1 (.i_insn(x_insn), .i_pc(x_pc), .i_r1data(x_r1_data_bypassed), .i_r2data(x_r2_data_bypassed), .o_result(alu_result));
   Nbit_reg #(16) x_m_alu (.in(alu_result), .out(m_alu_result), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   wire [15:0] m_alu_result_tmp = m_select_pc_plus_one ? m_pc + 1 : m_alu_result; 
   Nbit_reg #(16) m_w_alu (.in(m_alu_result_tmp), .out(w_alu_result), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   wire [15:0] w_mux_output = w_is_load ? w_dmem_output : w_alu_result;

//NZP kanbuxiaqule mingziyouwenti
   wire [2:0] m_nzp_bits, w_nzp_bits, reg_nzp_bits, x_bypassed_nzp_bits, reg_nzp_bits_last;
   assign m_nzp_bits = (w_mux_output[15] == 1'b1) ? 3'b100 : (w_mux_output == 16'b0) ? 3'b010 : 3'b001;
   assign w_nzp_bits = (m_alu_result[15] == 1'b1) ? 3'b100 : (m_alu_result == 16'd0) ? 3'b010 : 3'b001;
   Nbit_reg #(3) m_w_by_nzp_reg(m_nzp_bits, reg_nzp_bits_last, clk, w_nzp_we_pass, gwe, rst); 
   Nbit_reg #(3) w_by_nzp_reg(w_nzp_bits, reg_nzp_bits, clk, 1'b1, gwe, rst); 
   assign x_bypassed_nzp_bits = m_nzp_we_pass ? w_nzp_bits :
                                w_nzp_we_pass ? reg_nzp_bits : reg_nzp_bits_last;  
   wire d_nzp_we_pass, x_nzp_we_pass, m_nzp_we_pass, w_nzp_we_pass;
   Nbit_reg #(1) f_d_nzp_reg (.in((is_stall | flush_signal)? 1'b0 : nzp_we), .out(x_nzp_we_pass), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1) d_x_nzp_reg (.in(x_nzp_we_pass), .out(m_nzp_we_pass), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(1) x_m_nzp_reg (.in(m_nzp_we_pass), .out(w_nzp_we_pass), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   
   

//DMEM
   wire [15:0] m_dmem_addr, w_dmem_addr;
   assign m_dmem_addr = (m_is_load | m_is_store) ? m_alu_result : 16'b0; 
   Nbit_reg #(16) m_w_memaddr (.in(m_dmem_addr), .out(w_dmem_addr), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) m_w_memdata (.in(i_cur_dmem_data), .out(w_dmem_output), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

//Bypass
   wire [15:0] d_m_r1_data_bypassed, d_m_r2_data_bypassed;

   wire [15:0] d_r1_data_bypassed = (r1sel == w_wsel) & (w_regfile_we) ? w_mux_output : o_rs_data;
   wire [15:0] d_r2_data_bypassed = (r2sel == w_wsel) & (w_regfile_we) ? w_mux_output : o_rt_data;

   Nbit_reg #(16) m_w_rdbypass (.in(d_r1_data_bypassed), .out(d_m_r1_data_bypassed), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   Nbit_reg #(16) m_w_rtbypass (.in(d_r2_data_bypassed), .out(d_m_r2_data_bypassed), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

   wire [15:0] x_r1_data_bypassed = (x_r1sel == m_wsel) & (m_regfile_we) ? m_alu_result : 
                                    (x_r1sel == w_wsel) & (w_regfile_we) ? w_mux_output : 
                                     d_m_r1_data_bypassed;

   wire [15:0] x_r2_data_bypassed = (x_r2sel == m_wsel) & (m_regfile_we) ? m_alu_result : 
                                    (x_r2sel == w_wsel) & (w_regfile_we) ? w_mux_output : 
                                     d_m_r2_data_bypassed;

//   0000000011111100
//

   /***** FETCH STAGE *****/  

   wire r1stall = (x_r1sel==m_r1sel)|(m_r1sel==w_r1sel);
   wire r2stall = (x_r2sel==m_r2sel)|(m_r2sel==w_r2sel);
   wire wstall = (x_wsel==m_wsel)|(m_wsel==w_wsel);


   /*** YOUR CODE HERE ***/

   wire load_to_use = (regfile_we == 1 & (r1stall | r2stall | wstall))? 1'b1: 1'b0;

   //insert regfile file and data wire

   wire [15:0] o_rs_data;
   wire [15:0] o_rt_data, x_rt_data, m_rt_data, w_rt_data, m_rt_data_tmp;
   Nbit_reg #(16) x_m_rtbypassdata (.in(x_r2_data_bypassed), .out(m_rt_data_tmp), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   assign m_rt_data = (m_r2sel == w_wsel) & (w_regfile_we) & (m_is_store) & w_is_load ? w_dmem_output : m_rt_data_tmp;
   Nbit_reg #(16) m_w_rtbypassdata (.in(m_rt_data), .out(w_rt_data), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
   wire [15:0] i_wdata;



   lc4_regfile r1 (.clk(clk),.gwe(gwe),.rst(rst),.i_rs(r1sel),.o_rs_data(o_rs_data),.i_rt(r2sel),.o_rt_data(o_rt_data),.i_rd(w_wsel),.i_wdata(w_mux_output),.i_rd_we(w_regfile_we));
 

   assign i_wdata = is_load == 1'b1 ? w_dmem_output :
		              select_pc_plus_one == 1'b1 ? w_pc:
		              w_alu_result; 
   

   wire[2:0] nzp_out;
   //Nbit_reg #(3, 0) nzp_reg (.in(nzp_in), .out(nzp_out), .clk(clk), .we(nzp_we), .gwe(gwe), .rst(rst));

   wire[2:0] br_insn = i_cur_insn >> 9;

   wire is_branch_insn = (nzp_out == 3'b001 & br_insn[0]) ? 1'b1:
                         (nzp_out == 3'b010 & br_insn[1]) ? 1'b1:
                         (nzp_out == 3'b100 & br_insn[2]) ? 1'b1:
                         1'b0;

   


   // Always execute one instruction each cycle (test_stall will get used in your pipelined processor)

   /* Add $display(...) calls in the always block below to
    * print out debug information at the end of every cycle.
    * 
    * You may also use if statements inside the always block
    * to conditionally print out information.
    *
    * You do not need to resynthesize and re-implement if this is all you change;
    * just restart the simulation.
    */
`ifndef NDEBUG
   always @(posedge gwe) begin
      //$display("1:w_is_load: %h,  o_rs_data: %h, o_rt_data: %h, x_bypassed_nzp_bits: %b,  alu: %h, x_r1_data_bypassed: %h, x_r2_data_bypassed: %h", w_is_load, o_rs_data, o_rt_data, x_bypassed_nzp_bits, alu_result, x_r1_data_bypassed, x_r2_data_bypassed);
      //$display("2:pc: %h, insn: %b, d_stall: %h, w_dmem_output: %h, f_stall: %h, is_stall :%h", pc, x_insn, d_stall, w_dmem_output, f_stall, is_stall); 
      // $display("-------------------------------------------------");  
            
      // $display("1:w_is_load: %h,  o_rs_data: %h, o_rt_data: %h,w_o_rt_data: %h, w_is_store: %h,  alu: %h, x_r1_data_bypassed: %h, x_r2_data_bypassed: %h", w_is_load, o_rs_data, o_rt_data, w_rt_data,w_is_store, alu_result, x_r1_data_bypassed, x_r2_data_bypassed);
      // $display("2:pc: %h, insn: %b, alu: %h, w_dmem_output: %h, m_nzp_bits: %h, w_mux_output :%h", pc, x_insn, alu_result, w_dmem_output, m_nzp_bits, w_mux_output);      
      // $display("3:m_is_load: %h ,m_pc: %h,w_is_load :%h, w_pc: %h, w_dmem_output : %h, i_cur_dmem_data: %h", m_is_load, m_pc ,w_is_load,w_pc, w_dmem_output,i_cur_dmem_data );      
      //  $display("4:is_stall: %h,d_stall: %h,x_stall: %h, m_stall: %h,w_stall: %h" ,is_stall,d_stall,x_stall,m_stall,w_stall);
      //$display("5:pc: %h,next_pc: %h,d_pc: %h, x_pc: %h,m_pc: %h,w_pc: %h"  ,pc,next_pc,d_pc,x_pc,m_pc,w_pc);
      //display("6:f_insn: %h,d_insn: %h, d_insn_tmp: %h,x_insn: %h,m_insn: %h,w_insn: %h"  ,f_insn,d_insn,d_insn_tmp,x_insn,m_insn,w_insn);
      
      //   $display("%d STORE %h <= %h", $time, o_dmem_addr, o_dmem_towrite);

      // Start each $display() format string with a %d argument for time
      // it will make the output easier to read.  Use %b, %h, and %d
      // for binary, hex, and decimal output of additional variables.
      // You do not need to add a \n at the end of your format string.
      // $display("%d ...", $time);

      // Try adding a $display() call that prints out the PCs of
      // each pipeline stage in hex.  Then you can easily look up the
      // instructions in the .asm files in test_data.

      // basic if syntax:
      // if (cond) begin
      //    ...;
      //    ...;
      // end

      // Set a breakpoint on the empty $display() below
      // to step through your pipeline cycle-by-cycle.
      // You'll need to rewind the simulation to start
      // stepping from the beginning.

      // You can also simulate for XXX ns, then set the
      // breakpoint to start stepping midway through the
      // testbench.  Use the $time printouts you added above (!)
      // to figure out when your problem instruction first
      // enters the fetch stage.  Rewind your simulation,
      // run it for that many nano-seconds, then set
      // the breakpoint.

      // In the objects view, you can change the values to
      // hexadecimal by selecting all signals (Ctrl-A),
      // then right-click, and select Radix->Hexadecimal.

      // To see the values of wires within a module, select
      // the module in the hierarchy in the "Scopes" pane.
      // The Objects pane will update to display the wires
      // in that module.

      //$display(); 
   end
`endif
endmodule