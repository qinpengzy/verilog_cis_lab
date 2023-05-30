`timescale 1ns / 1ps

// Prevent implicit wire declaration
`default_nettype none

module lc4_processor(input wire         clk,             // main cock
                     input wire         rst,             // global reset
                     input wire         gwe,             // global we for single-step clock

                     output wire [15:0] o_cur_pc,        // address to read from instruction memory
                     input wire [15:0]  i_cur_insn_A,    // output of instruction memory (pipe A)
                     input wire [15:0]  i_cur_insn_B,    // output of instruction memory (pipe B)

                     output wire [15:0] o_dmem_addr,     // address to read/write from/to data memory
                     input wire [15:0]  i_cur_dmem_data, // contents of o_dmem_addr
                     output wire        o_dmem_we,       // data memory write enable
                     output wire [15:0] o_dmem_towrite,  // data to write to o_dmem_addr if we is set

                     // testbench signals (always emitted from the WB stage)
                     output wire [ 1:0] test_stall_A,        // is this a stall cycle?  (0: no stall,
                     output wire [ 1:0] test_stall_B,        // 1: pipeline stall, 2: branch stall, 3: load stall)

                     output wire [15:0] test_cur_pc_A,       // program counter
                     output wire [15:0] test_cur_pc_B,
                     output wire [15:0] test_cur_insn_A,     // instruction bits
                     output wire [15:0] test_cur_insn_B,
                     output wire        test_regfile_we_A,   // register file write-enable
                     output wire        test_regfile_we_B,
                     output wire [ 2:0] test_regfile_wsel_A, // which register to write
                     output wire [ 2:0] test_regfile_wsel_B,
                     output wire [15:0] test_regfile_data_A, // data to write to register file
                     output wire [15:0] test_regfile_data_B,
                     output wire        test_nzp_we_A,       // nzp register write enable
                     output wire        test_nzp_we_B,
                     output wire [ 2:0] test_nzp_new_bits_A, // new nzp bits
                     output wire [ 2:0] test_nzp_new_bits_B,
                     output wire        test_dmem_we_A,      // data memory write enable
                     output wire        test_dmem_we_B,
                     output wire [15:0] test_dmem_addr_A,    // address to read/write from/to memory
                     output wire [15:0] test_dmem_addr_B,
                     output wire [15:0] test_dmem_data_A,    // data to read/write from/to memory
                     output wire [15:0] test_dmem_data_B,

                     // zedboard switches/display/leds (ignore if you don't want to control these)
                     input  wire [ 7:0] switch_data,         // read on/off status of zedboard's 8 switches
                     output wire [15:0] seven_segment_data,  // value to display on zedboard's two-digit display
                     output wire [ 7:0] led_data             // set on/off status of zedboard's 8 leds
                     );
 /***  YOUR CODE HERE ***/

//A
 wire [2:0]d_r1sel_A,              x_r1sel_A,              m_r1selA,                w_r1selA;
 wire      d_r1re_A,               x_r1re_A,               m_r1re_A,                w_r1re_A;
 wire [2:0]d_r2sel_A,              x_r2sel_A,              m_r2sel_A,               w_r2sel_A;
 wire      d_r2re_A,               x_r2re_A,               m_r2re_A,                w_r2re_A;
 wire [2:0]d_wsel_A,               x_wselA,                m_wsel_A,                w_wsel_A;
 wire      d_regfile_we_A,         x_regfile_we_A,         m_regfile_we_A,          w_regfile_we_A;
 wire      d_nzp_we_A,             x_nzp_we_A,             m_nzp_we_A,              w_nzp_we_A;
 wire      d_select_pc_plus_one_A, x_select_pc_plus_one_A, m_select_pc_plus_one_A , w_select_pc_plus_one_A;
 wire      d_is_load_A,            x_is_load_A,            m_is_load_A,             w_is_load_A;
 wire      d_is_store_A,           x_is_storeA,            m_is_store_A,            w_is_store_A;
 wire      d_is_branch_A,          x_is_branch_A,          m_is_branch_A,           w_is_branch_A;
 wire      d_is_control_insn_A,    x_is_control_insn_A,    m_is_control_insn_A,     w_is_control_insn_A;

 lc4_decoder decoderA (.insn(d_insn_A), 
                       .r1sel(d_r1sel_A), 
                       .r1re(d_r1re_A), 
                       .r2sel(d_r2sel_A), 
                       .r2re(d_r2re_A), 
                       .wsel(d_wsel_A), 
                       .regfile_we(d_regfile_we_A), 
                       .nzp_we(d_nzp_we_A), 
                       .select_pc_plus_one(d_select_pc_plus_one_A), 
                       .is_load(d_is_load_A), 
                       .is_store(d_is_store_A), 
                       .is_branch(d_is_branch_A), 
                       .is_control_insn(d_is_control_insn_A));

 Nbit_reg #(3)x_r1sel_regA(.in(d_r1sel_A), .out(x_r1sel_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)m_r1sel_regA(.in(x_r1sel_A), .out(m_r1selA), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)w_r1sel_regA(.in(m_r1selA), .out(w_r1selA), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire x_r1re_A_tmp = (is_flush||load_to_use_stall_A)? 1'b0 : x_r1re_A;
 Nbit_reg #(1)x_r1re_regA(.in(x_r1re_A_tmp), .out(x_r1re_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_r1re_regA(.in(x_r1re_A), .out(m_r1re_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_r1re_regA(.in(m_r1re_A), .out(w_r1re_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 Nbit_reg #(3)x_r2sel_regA(.in(d_r2sel_A), .out(x_r2sel_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)m_r2sel_regA(.in(x_r2sel_A), .out(m_r2sel_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)w_r2sel_regA(.in(m_r2sel_A), .out(w_r2sel_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire d_r2re_A_tmp = (is_flush || load_to_use_stall_A)? 1'b0 : d_r2re_A;
 Nbit_reg #(1)x_r2re_regA(.in(d_r2re_A_tmp), .out(x_r2re_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_r2re_regA(.in(x_r2re_A), .out(m_r2re_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_r2re_regA(.in(m_r2re_A), .out(w_r2re_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 Nbit_reg #(3)x_wsel_regA(.in(d_wsel_A), .out(x_wselA), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)m_wsel_regA(.in(x_wselA), .out(m_wsel_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)w_wsel_regA(.in(m_wsel_A), .out(w_wsel_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_regfile_we_A_tmp = (is_flush || load_to_use_stall_A)? 1'b0 : d_regfile_we_A;
 Nbit_reg #(1)x_regfile_we_regA(.in(d_regfile_we_A_tmp), .out(x_regfile_we_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_regfile_we_regA(.in(x_regfile_we_A), .out(m_regfile_we_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_regfile_we_regA(.in(m_regfile_we_A), .out(w_regfile_we_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_nzp_we_A_tmp = (is_flush || load_to_use_stall_A)? 1'b0 : d_nzp_we_A;
 Nbit_reg #(1)x_nzp_we_regA(.in(d_nzp_we_A_tmp), .out(x_nzp_we_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_nzp_we_regA(.in(x_nzp_we_A), .out(m_nzp_we_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_nzp_we_regA(.in(m_nzp_we_A), .out(w_nzp_we_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_select_pc_plus_one_A_tmp = (is_flush || load_to_use_stall_A)? 1'b0 : d_select_pc_plus_one_A;
 Nbit_reg #(1)x_select_pc_plus_one_regA(.in(d_select_pc_plus_one_A_tmp), .out(x_select_pc_plus_one_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_select_pc_plus_one_regA(.in(x_select_pc_plus_one_A), .out(m_select_pc_plus_one_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_select_pc_plus_one_regA(.in(m_select_pc_plus_one_A), .out(w_select_pc_plus_one_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_is_load_A_tmp = (is_flush || load_to_use_stall_A)? 1'b0 : d_is_load_A;
 Nbit_reg #(1)x_is_load_regA(.in(d_is_load_A_tmp), .out(x_is_load_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_is_load_regA(.in(x_is_load_A), .out(m_is_load_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_is_load_regA(.in(m_is_load_A), .out(w_is_load_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire d_is_store_A_tmp = (is_flush || load_to_use_stall_A)? 1'b0 : d_is_store_A;
 Nbit_reg #(1)x_is_store_regA(.in(d_is_store_A_tmp), .out(x_is_storeA), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_is_store_regA(.in(x_is_storeA), .out(m_is_store_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_is_store_regA(.in(m_is_store_A), .out(w_is_store_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_is_branch_A_tmp = (is_flush || load_to_use_stall_A)? 1'b0 : d_is_branch_A;
 Nbit_reg #(1)x_is_branch_regA(.in(d_is_branch_A_tmp), .out(x_is_branch_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_is_branch_regA(.in(x_is_branch_A), .out(m_is_branch_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_is_branch_regA(.in(m_is_branch_A), .out(w_is_branch_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire d_is_control_insn_A_tmp = (is_flush || load_to_use_stall_A)? 1'b0 : d_is_control_insn_A;
 Nbit_reg #(1)x_is_control_insn_regA (.in(d_is_control_insn_A_tmp), .out(x_is_control_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_is_control_insn_regA (.in(x_is_control_insn_A), .out(m_is_control_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_is_control_insn_regA (.in(m_is_control_insn_A), .out(w_is_control_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

//B
 wire [2:0]d_r1sel_B,              x_r1sel_B,              m_r1sel_B,              w_r1sel_B;
 wire      d_r1re_B,               x_r1re_B,               m_r1re_B,               w_r1re_B;
 wire [2:0]d_r2sel_B,              x_r2sel_B,              m_r2sel_B,              w_r2sel_B;
 wire      d_r2re_B,               x_r2re_B,               m_r2re_B,               w_r2re_B;
 wire [2:0]d_wsel_B,               x_wsel_B,               m_wsel_B,               w_wsel_B;
 wire      d_regfile_we_B,         x_regfile_we_B,         m_regfile_we_B,         w_regfile_we_B;
 wire      d_nzp_we_B,             x_nzp_we_B,             m_nzp_we_B,             w_nzp_we_B;
 wire      d_select_pc_plus_one_B, x_select_pc_plus_one_B, m_select_pc_plus_one_B, w_select_pc_plus_one_B;
 wire      d_is_load_B,            x_is_load_B,            m_is_load_B,            w_is_load_B;
 wire      d_is_store_B,           x_is_store_B,           m_is_store_B,           w_is_store_B;
 wire      d_is_branch_B,          x_is_branch_B,          m_is_branch_B,          w_is_branch_B;
 wire      d_is_control_insn_B,    x_is_control_insn_B,    m_is_control_insn_B,    w_is_control_insn_B;

  lc4_decoder decoderB (.insn(d_insn_B), 
                       .r1sel(d_r1sel_B), 
                       .r1re(d_r1re_B), 
                       .r2sel(d_r2sel_B), 
                       .r2re(d_r2re_B), 
                       .wsel(d_wsel_B), 
                       .regfile_we(d_regfile_we_B), 
                       .nzp_we(d_nzp_we_B), 
                       .select_pc_plus_one(d_select_pc_plus_one_B), 
                       .is_load(d_is_load_B), 
                       .is_store(d_is_store_B), 
                       .is_branch(d_is_branch_B), 
                       .is_control_insn(d_is_control_insn_B));

 Nbit_reg #(3)x_r1sel_regB(.in(d_r1sel_B), .out(x_r1sel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)m_r1sel_regB(.in(x_r1sel_B), .out(m_r1sel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)w_r1sel_regB(.in(m_r1sel_B), .out(w_r1sel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_r1re_B_tmp = (is_flush || load_to_use_stall_B || superscalar_stall)   ? 1'b0 : d_r1re_B;
 Nbit_reg #(1)x_r1re_regB(.in(d_r1re_B_tmp), .out(x_r1re_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_r1re_regB(.in(x_r1re_B), .out(m_r1re_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_r1re_regB(.in(m_r1re_B), .out(w_r1re_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 Nbit_reg #(3)x_r2sel_regB(.in(d_r2sel_B), .out(x_r2sel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)m_r2sel_regB(.in(x_r2sel_B), .out(m_r2sel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)w_r2sel_regB(.in(m_r2sel_B), .out(w_r2sel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_r2re_B_tmp = (is_flush || load_to_use_stall_B || superscalar_stall)   ? 1'b0 : d_r2re_B;
 Nbit_reg #(1)x_r2re_regB(.in(d_r2re_B_tmp), .out(x_r2re_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_r2re_regB(.in(x_r2re_B), .out(m_r2re_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_r2re_regB(.in(m_r2re_B), .out(w_r2re_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 Nbit_reg #(3)x_wsel_regB(.in(d_wsel_B), .out(x_wsel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)m_wsel_regB(.in(x_wsel_B), .out(m_wsel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)w_wsel_regB(.in(m_wsel_B), .out(w_wsel_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_regfile_we_B_tmp = (is_flush || load_to_use_stall_B || superscalar_stall)   ? 1'b0 : d_regfile_we_B;
 Nbit_reg #(1)x_regfile_we_regB(.in(d_regfile_we_B_tmp), .out(x_regfile_we_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_regfile_we_regB(.in((is_flush_A) ? 1'b0 : x_regfile_we_B), .out(m_regfile_we_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_regfile_we_regB(.in(m_regfile_we_B), .out(w_regfile_we_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire d_nzp_we_B_tmp = (is_flush||load_to_use_stall_B||superscalar_stall)?1'b0:d_nzp_we_B;
 Nbit_reg #(1)x_nzp_we_regB(.in(d_nzp_we_B_tmp), .out(x_nzp_we_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_nzp_we_regB(.in((is_flush_A) ? 1'b0 : x_nzp_we_B), .out(m_nzp_we_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_nzp_we_regB(.in(m_nzp_we_B), .out(w_nzp_we_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire d_select_pc_plus_one_B_tmp = (is_flush || load_to_use_stall_B || superscalar_stall)? 1'b0 : d_select_pc_plus_one_B;
 Nbit_reg #(1)x_select_pc_plus_one_regB(.in(d_select_pc_plus_one_B_tmp), .out(x_select_pc_plus_one_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_select_pc_plus_one_regB(.in(x_select_pc_plus_one_B), .out(m_select_pc_plus_one_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_select_pc_plus_one_regB(.in(m_select_pc_plus_one_B), .out(w_select_pc_plus_one_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire d_is_load_B_tmp = (is_flush || load_to_use_stall_B || superscalar_stall)? 1'b0 : d_is_load_B;
 Nbit_reg #(1)x_is_load_regB(.in(d_is_load_B_tmp), .out(x_is_load_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_is_load_regB(.in((is_flush_A) ? 1'b0 : x_is_load_B), .out(m_is_load_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_is_load_regB(.in(m_is_load_B), .out(w_is_load_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire d_is_store_B_tmp = (is_flush || load_to_use_stall_B || superscalar_stall)? 1'b0 : d_is_store_B;
 Nbit_reg #(1)x_is_store_regB(.in(d_is_store_B_tmp), .out(x_is_store_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_is_store_regB(.in(( is_flush_A ) ? 1'b0 : x_is_store_B), .out(m_is_store_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_is_store_regB(.in(m_is_store_B), .out(w_is_store_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire d_is_branch_B_tmp = (is_flush || load_to_use_stall_B || superscalar_stall)? 1'b0 : d_is_branch_B;
 Nbit_reg #(1)x_is_branch_regB(.in(d_is_branch_B_tmp), .out(x_is_branch_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_is_branch_regB(.in(x_is_branch_B), .out(m_is_branch_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_is_branch_regB(.in(m_is_branch_B), .out(w_is_branch_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire d_is_control_insn_B_tmp = (is_flush || load_to_use_stall_B || superscalar_stall)? 1'b0 : d_is_control_insn_B;
 Nbit_reg #(1)x_is_control_insn_regB(.in(d_is_control_insn_B_tmp), .out(x_is_control_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)m_is_control_insn_regB(.in(x_is_control_insn_B), .out(m_is_control_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(1)w_is_control_insn_regB(.in(m_is_control_insn_B), .out(w_is_control_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

//decoder
 wire [15:0]    d_ort_data_A;
 wire [15:0]    d_ors_data_A;
 wire [15:0]    d_ort_data_B;
 wire [15:0]    d_ors_data_B;

  lc4_regfile_ss regfile (.clk(clk), .gwe(gwe), .rst(rst), 
            .i_rs_A(d_r1sel_A), .o_rs_data_A(d_ors_data_A), .i_rt_A(d_r2sel_A), .o_rt_data_A(d_ort_data_A), 
            .i_rs_B(d_r1sel_B), .o_rs_data_B(d_ors_data_B), .i_rt_B(d_r2sel_B), .o_rt_data_B(d_ort_data_B), 
            .i_rd_A(w_wsel_A), .i_rd_B(w_wsel_B), .i_wdata_A(w_mux_output_A), .i_wdata_B(w_mux_output_B), 
            .i_rd_we_A(w_regfile_we_A), .i_rd_we_B(w_regfile_we_B) );

//stall logic
 wire load_to_use_stall, load_to_use_stall_A, load_to_use_stall_B, superscalar_stall;
 wire is_flush ;
 wire [1:0] f_temp_stall = ( is_flush ) ? 2'd2 : 2'd0; 
 assign is_flush = (is_flush_A || is_flush_B); 

 wire [1:0] d_stall_A,x_stall_A,m_stall_A,w_stall_A;
 wire is_flush_A = (( o_branch_A & x_is_branch_A ) | x_is_control_insn_A);
 wire [1:0] d_temp_stall_A = ( is_flush )? 2'd2 :(load_to_use_stall_A)? 2'd3 : d_stall_A ;
 Nbit_reg #(2, 2'd2)d_stall_regA(.in(f_temp_stall), .out(d_stall_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst || is_flush));
 Nbit_reg #(2, 2'd2)x_stall_regA(.in(d_temp_stall_A), .out(x_stall_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(2, 2'd2)m_stall_regA(.in(x_stall_A), .out(m_stall_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(2, 2'd2)w_stall_regA(.in(m_stall_A), .out(w_stall_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire [1:0] d_stall_B,x_stall_B,m_stall_B,w_stall_B;
 wire is_flush_B = (( o_branch_B & x_is_branch_B ) | x_is_control_insn_B);
 wire [1:0] d_temp_stall_B = (is_flush)? 2'd2 :(load_to_use_stall_B) ? 2'd3 :(superscalar_stall)? 2'd1 :d_stall_B;
 Nbit_reg #(2, 2'd2)d_stall_regB(.in(f_temp_stall), .out(d_stall_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst || is_flush));
 Nbit_reg #(2, 2'd2)x_stall_regB(.in(d_temp_stall_B), .out(x_stall_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 wire [1:0] x_temp_stall_B = (is_flush_A ) ? 2'd2 : x_stall_B;
 Nbit_reg #(2, 2'd2)m_stall_regB(.in(x_temp_stall_B), .out(m_stall_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(2, 2'd2)w_stall_regB(.in(m_stall_B), .out(w_stall_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

  assign load_to_use_stall_A = 
                    (x_is_load_A && (
                        (d_is_branch_A && !x_nzp_we_B) || 
                        (d_r1sel_A == x_wselA && d_r1re_A && !(x_regfile_we_B && ((d_r1sel_A == x_wsel_B && d_r1re_A)))) ||
                        (d_r2sel_A == x_wselA && d_r2re_A && (!d_is_store_A) && !(x_regfile_we_B && ((d_r2sel_A == x_wsel_B && d_r2re_A && !d_is_store_A)))))
                    )||
                    (x_is_load_B && 
                        (d_is_branch_A ||(d_r1sel_A == x_wsel_B && d_r1re_A) ||(d_r2sel_A == x_wsel_B && d_r2re_A && (!d_is_store_A)))
                    ); 
  assign load_to_use_stall_B  = 
                !superscalar_stall  && (
                    (x_is_load_A && 
                        ((d_is_branch_B && !x_nzp_we_B) || 
                         (d_r1sel_B == x_wselA && d_r1re_B && !(x_regfile_we_B && ((d_r1sel_B == x_wsel_B && d_r1re_B)))) ||
                         (d_r2sel_B == x_wselA && d_r2re_B && (!d_is_store_B) && !(x_regfile_we_B && ((d_r2sel_B == x_wsel_B && d_r2re_B && !d_is_store_B)))))
                    )||
                    (x_is_load_B && 
                        (d_is_branch_B ||(d_r1sel_B == x_wsel_B && d_r1re_B) ||(d_r2sel_B == x_wsel_B && d_r2re_B && (!d_is_store_B)))
                    )
                ); 
  assign superscalar_stall  = 
          (d_regfile_we_A && ((d_wsel_A == d_r1sel_B && d_r1re_B) ||(d_wsel_A == d_r2sel_B && d_r2re_B && !d_is_store_B) ||(d_is_branch_B)))|| 
          ((d_is_load_A || d_is_store_A) && (d_is_load_B || d_is_store_B)) || 
          load_to_use_stall_A ||
          (d_is_branch_B && (d_insn_A[15:12] == 4'b0010));

 assign load_to_use_stall = 1'd0; 
 
//pc
 wire [15:0] f_pc, next_pc;
 wire[15:0]f_pc_result,f_pc_result_2;
 cla16 f1(.a(f_pc), .b(16'b0), .cin(1'b1), .sum(f_pc_result));
 cla16 f2(.a(f_pc_result), .b(16'b0), .cin(1'b1), .sum(f_pc_result_2));
 assign next_pc =   ( is_flush_A )           ? alu_result_A    :
                    ( is_flush_B )           ? alu_result_B    :
                    ( load_to_use_stall_A )  ? f_pc      :
                    ( load_to_use_stall_B )  ? f_pc_result   :  
                    ( superscalar_stall )    ? f_pc_result   :
                      f_pc_result_2;  // idk if it should come from A or B
 Nbit_reg #(16, 16'h8200) f_pc_reg(.in(next_pc), .out(f_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));  
 wire[15:0]d_pc_result;
 cla16 c1(.a(d_pc), .b(16'b0), .cin(1'b1), .sum(d_pc_result));
 wire [15:0]f_temp_pc,d_pc,x_pc,m_pc,w_pc;
 assign f_temp_pc =     ( load_to_use_stall_A )  ? d_pc      :
                        ( load_to_use_stall_B )  ?d_pc_result :
                        ( superscalar_stall )   ? d_pc_result : 
                          f_pc;
 Nbit_reg #(16)d_pc_reg(.in(f_temp_pc), .out(d_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)x_pc_reg(.in(d_pc), .out(x_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));               
 Nbit_reg #(16)m_pc_reg(.in(x_pc), .out(m_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_pc_reg(.in(m_pc), .out(w_pc), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 assign o_cur_pc = f_pc;

//ins
 wire [15:0]f_insn_A,d_insn_A,x_insn_A,m_insn_A,w_insn_A;
 assign f_insn_A=(is_flush)?(16'b0):(load_to_use_stall_A)?(d_insn_A):(load_to_use_stall_B)?(d_insn_B):(superscalar_stall)?(d_insn_B):i_cur_insn_A;                 
 Nbit_reg #(16)d_insn_regA(.in(f_insn_A), .out(d_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 wire [15:0] d_temp_insn_A =(d_stall_A) ? (x_insn_A):( is_flush || load_to_use_stall_A)? (16'b0) : d_insn_A;
 Nbit_reg #(16)x_insn_regA(.in(d_temp_insn_A), .out(x_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)m_insn_regA(.in(x_insn_A), .out(m_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_insn_regA (.in(m_insn_A), .out(w_insn_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire [15:0]f_insn_B,d_insn_B,x_insn_B,m_insn_B,w_insn_B;
 assign f_insn_B=(is_flush)?(16'b0):(load_to_use_stall_A)?(d_insn_B):(superscalar_stall)?(i_cur_insn_A):(load_to_use_stall_B)?(i_cur_insn_A):i_cur_insn_B;
 Nbit_reg #(16)d_insn_regB(.in(f_insn_B), .out(d_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 wire [15:0] d_temp_insnB =(d_stall_B) ? (x_insn_B):( is_flush || load_to_use_stall_B || superscalar_stall) ? (16'b0) : d_insn_B;
 Nbit_reg #(16)x_insn_regB(.in(d_temp_insnB), .out(x_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 wire [15:0] x_temp_insn_B =(is_flush_A)? (16'b0):x_insn_B;
 Nbit_reg #(16)m_insn_regB(.in(x_temp_insn_B), .out(m_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_insn_regB(.in(m_insn_B), .out(w_insn_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
//alu
  wire [15:0]x_pc_result, x_pc_result_2;
 cla16 x1(.a(x_pc), .b(16'b0), .cin(1'b1), .sum(x_pc_result));

 wire [15:0] alu_result_A, m_oalu_A, m_oresult_A, w_oresult_A;
 lc4_alu aluA(.i_insn(x_insn_A), .i_pc(x_pc), .i_r1data(x_r1_data_bypassed_A), .i_r2data(x_r2_data_bypassed_A), .o_result(alu_result_A));
 Nbit_reg #(16)m_oalu_regA(.in(alu_result_A), .out(m_oalu_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 wire [15:0] x_oresult_A = (x_select_pc_plus_one_A) ? (x_pc_result):(alu_result_A ); 
 Nbit_reg #(16)m_oresult_regA(.in(x_oresult_A), .out(m_oresult_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_oresult_regA(.in(m_oresult_A), .out(w_oresult_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire [15:0] alu_result_B,m_oalu_B,m_oresult_B,w_oresult_B;
 lc4_alu aluB(.i_insn(x_insn_B), .i_pc(x_pc_result), .i_r1data(x_r1_data_bypassed_B), .i_r2data(x_r2_data_bypassed_B),.o_result(alu_result_B));
 Nbit_reg #(16)m_oalu_regB(.in(alu_result_B), .out(m_oalu_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 cla16 x2(.a(x_pc_result), .b(16'b0), .cin(1'b1), .sum(x_pc_result_2));
 wire [15:0] x_oresult_B = (x_select_pc_plus_one_B) ? x_pc_result_2:(alu_result_B ); 
 Nbit_reg #(16)m_oresult_regB(.in(x_oresult_B), .out(m_oresult_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_oresult_regB(.in(m_oresult_B), .out(w_oresult_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

//NZP
 wire [2:0] x_nzp_bits_A, m_nzp_bits_A, w_nzp_bits_A;
 assign x_nzp_bits_A[0] = (!x_oresult_A[15]) & (!x_nzp_bits_A[1]);
 assign x_nzp_bits_A[1] = (x_oresult_A == 16'b0);
 assign x_nzp_bits_A[2] =  x_oresult_A[15];
 Nbit_reg #(3)m_nzp_regA(.in(x_nzp_bits_A), .out(m_nzp_bits_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)w_nzp_regA(.in(m_nzp_bits_A), .out(w_nzp_bits_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire [15:0] w_mux_output_A;
 assign w_mux_output_A = ( w_is_load_A ) ? w_dmem_data_A : w_oresult_A;
 wire [2:0] w_temp_nzp_bits_A;
 assign w_temp_nzp_bits_A[0] = ( w_is_load_A ) ? ((!w_mux_output_A[15]) & (!w_temp_nzp_bits_A[1])) : w_nzp_bits_A[0];
 assign w_temp_nzp_bits_A[1] = ( w_is_load_A ) ? (w_mux_output_A == 16'b0) : w_nzp_bits_A[1];
 assign w_temp_nzp_bits_A[2] = ( w_is_load_A ) ? (w_mux_output_A[15]) : (w_nzp_bits_A[2]);

 wire [2:0] x_nzp_bits_B,m_nzp_bits_B,w_nzp_bits_B;
 assign x_nzp_bits_B[0] = (!x_oresult_B[15]) & (!x_nzp_bits_B[1]);
 assign x_nzp_bits_B[1] = (x_oresult_B == 16'b0);
 assign x_nzp_bits_B[2] =  x_oresult_B[15];
 Nbit_reg #(3)m_nzp_regB(.in(x_nzp_bits_B), .out(m_nzp_bits_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(3)w_nzp_regB(.in(m_nzp_bits_B), .out(w_nzp_bits_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 wire [15:0]w_mux_output_B;
 assign w_mux_output_B = ( w_is_load_B ) ? w_dmem_data_B : w_oresult_B;
 wire [2:0] w_temp_nzp_bits_B;
 assign w_temp_nzp_bits_B[0] = ( w_is_load_B ) ? ((!w_mux_output_B[15]) & (!w_temp_nzp_bits_B[1])) : w_nzp_bits_B[0];
 assign w_temp_nzp_bits_B[1] = ( w_is_load_B ) ? (w_mux_output_B == 16'b0) : w_nzp_bits_B[1];
 assign w_temp_nzp_bits_B[2] = ( w_is_load_B ) ? (w_mux_output_B[15]) : (w_nzp_bits_B[2]);

 wire [2:0] w_nzp_into_reg = ( w_nzp_we_B ) ? w_temp_nzp_bits_B : w_temp_nzp_bits_A;
 Nbit_reg #(3) nzp_reg (.in(w_nzp_into_reg), .out(curr_nzp), .clk(clk), .we(w_nzp_we_A || w_nzp_we_B), .gwe(gwe), .rst(rst));    

//data mem
 assign o_dmem_towrite =(m_is_store_A)?((w_regfile_we_B && (w_wsel_B == m_r2sel_A))?w_mux_output_B:
                                        (w_regfile_we_A && (w_wsel_A == m_r2sel_A))?w_mux_output_A: 
                                        m_r2data_A):
                        (m_is_store_B)?(( m_regfile_we_A && (m_wsel_A == m_r2sel_B)) ? m_oalu_A :
                                        (w_regfile_we_B && (w_wsel_B == m_r2sel_B))?w_mux_output_B:
                                        (w_regfile_we_A && (w_wsel_A == m_r2sel_B))?w_mux_output_A: 
                                        m_r2data_B) : 16'b0;                       
 assign o_dmem_addr =(m_is_load_A || m_is_store_A) ? m_oalu_A : 
                     (m_is_load_B || m_is_store_B) ? m_oalu_B :
                                                16'b0;                              
 assign o_dmem_we = ( m_is_store_A || m_is_store_B );

//dmem
 wire [15:0] m_dmem_data;
 assign m_dmem_data  = i_cur_dmem_data;
 wire [15:0]    m_dmem_dataA, m_dmem_addr_A,w_dmem_addr_A, m_dmem_towrite_A,w_dmem_data_A,w_dmem_towrite_A;
 wire           m_dmem_we_A,w_dmem_we_A;
 assign m_dmem_addr_A = ( m_is_store_A || m_is_load_A )   ?   o_dmem_addr : 16'b0;
 Nbit_reg #(16)w_dmem_addrA_reg(.in(m_dmem_addr_A), .out(w_dmem_addr_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 assign m_dmem_towrite_A = (m_is_store_A) ?o_dmem_towrite : 16'b0;
 assign m_dmem_dataA = ( m_is_load_A )  ?   i_cur_dmem_data : 
                       ( m_is_store_A ) ?   m_dmem_towrite_A :
                        16'b0;
 Nbit_reg #(16)w_dmem_dataA_reg(.in(m_dmem_dataA), .out(w_dmem_data_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_dmem_towriteA_reg(.in(m_dmem_towrite_A), .out(w_dmem_towrite_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 assign m_dmem_we_A =(m_is_store_A || m_is_load_A )?   m_is_store_A : 0;
 Nbit_reg #(1)w_dmem_weA_reg(.in(m_dmem_we_A), .out(w_dmem_we_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire [15:0]    m_dmem_dataB, m_dmem_addr_B,w_dmem_addr_B, m_dmem_towrite_B,w_dmem_data_B,w_dmem_towrite_B;
 wire           m_dmem_we_B,w_dmem_we_B;
 assign m_dmem_addr_B = (m_is_store_B || m_is_load_B)?   o_dmem_addr : 16'b0;
 Nbit_reg #(16)w_dmem_addrB_reg(.in(m_dmem_addr_B), .out(w_dmem_addr_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_dmem_dataB_reg(.in(m_dmem_dataB), .out(w_dmem_data_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 assign m_dmem_towrite_B = (m_is_store_B) ?o_dmem_towrite : 16'b0;
 assign m_dmem_dataB = ( m_is_load_B )  ?   i_cur_dmem_data :
                      ( m_is_store_B ) ?   m_dmem_towrite_B : 
                      16'b0;
 Nbit_reg #(16)w_dmem_towriteB_reg(.in(m_dmem_towrite_B), .out(w_dmem_towrite_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 assign m_dmem_we_B =(m_is_store_B || m_is_load_B)?m_is_store_B : 0;
 Nbit_reg #(1)w_dmem_weB_reg(.in(m_dmem_we_B), .out(w_dmem_we_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

//Bypass
 wire [15:0] x_r1_data_bypassed_A, x_r2_data_bypassed_A,m_r1data_A,m_r2data_A,w_r1data_A,w_r2data_A,x_r1data_A,x_r2data_A;
 assign x_r1_data_bypassed_A =    ( (x_r1sel_A == m_wsel_B) && (m_regfile_we_B) )   ? m_oresult_B    : 
                    ( (x_r1sel_A == m_wsel_A) && (m_regfile_we_A) )   ? m_oresult_A    : 
                    ( (x_r1sel_A == w_wsel_B) && (w_regfile_we_B) )   ? w_mux_output_B     :
                    ( (x_r1sel_A == w_wsel_A) && (w_regfile_we_A) )   ? w_mux_output_A     : x_r1data_A;
 Nbit_reg #(16)x_r1data_regA(.in(d_ors_data_A), .out(x_r1data_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)m_r1data_regA(.in(x_r1_data_bypassed_A),.out(m_r1data_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_r1data_regA(.in(m_r1data_A), .out(w_r1data_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 
 assign x_r2_data_bypassed_A =    ( (x_r2sel_A == m_wsel_B) && (m_regfile_we_B) )   ? m_oresult_B    : 
                    ( (x_r2sel_A == m_wsel_A) && (m_regfile_we_A) )   ? m_oresult_A    : 
                    ( (x_r2sel_A == w_wsel_B) && (w_regfile_we_B) )   ? w_mux_output_B     :
                    ( (x_r2sel_A == w_wsel_A) && (w_regfile_we_A) )   ? w_mux_output_A     : x_r2data_A;
 Nbit_reg #(16)_r2data_regA(.in(d_ort_data_A), .out(x_r2data_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)m_r2data_regA(.in(x_r2_data_bypassed_A),.out(m_r2data_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_r2data_regA(.in(m_r2data_A), .out(w_r2data_A), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 wire [15:0] x_r1_data_bypassed_B, x_r2_data_bypassed_B,m_r1data_B,m_r2data_B,w_r1data_B,w_r2data_B,x_r1data_B,x_r2data_B;
 assign x_r1_data_bypassed_B =    ( (x_r1sel_B == m_wsel_B) && (m_regfile_we_B) )   ? m_oresult_B    : 
                    ( (x_r1sel_B == m_wsel_A) && (m_regfile_we_A) )   ? m_oresult_A    : 
                    ( (x_r1sel_B == w_wsel_B) && (w_regfile_we_B) )  ? w_mux_output_B     :
                    ( (x_r1sel_B == w_wsel_A) && (w_regfile_we_A) )  ? w_mux_output_A     : x_r1data_B;
 Nbit_reg #(16)x_r1data_regB (.in(d_ors_data_B), .out(x_r1data_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)m_r1data_regB(.in(x_r1_data_bypassed_B), .out(m_r1data_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_r1data_regB(.in(m_r1data_B), .out(w_r1data_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));

 assign x_r2_data_bypassed_B =    ( (x_r2sel_B == m_wsel_B) && (m_regfile_we_B) )   ? m_oresult_B    : 
                    ( (x_r2sel_B == m_wsel_A) && (m_regfile_we_A) )   ? m_oresult_A    : 
                    ( (x_r2sel_B == w_wsel_B) && (w_regfile_we_B) )  ? w_mux_output_B     :
                    ( (x_r2sel_B == w_wsel_A) && (w_regfile_we_A) )  ? w_mux_output_A     : x_r2data_B;
 Nbit_reg #(16)x_r2data_regB(.in(d_ort_data_B), .out(x_r2data_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)m_r2data_regB(.in(x_r2_data_bypassed_B), .out(m_r2data_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));
 Nbit_reg #(16)w_r2data_regB(.in(m_r2data_B), .out(w_r2data_B), .clk(clk), .we(1'b1), .gwe(gwe), .rst(rst));


//debug this logic 
//gtkwave num_cycles
//LBL_8244 BRnp LBL_823a
//LBL_8245 CONST R3, #-120

//branch
 wire [2:0] br_nzp_A; 
 wire [2:0] curr_nzp;
 assign br_nzp_A = 
     ( m_nzp_we_B ) ? ( m_nzp_bits_B ) : 
     ( m_nzp_we_A ) ? ( m_nzp_bits_A ) :
     ( w_nzp_we_B ) ? ( w_nzp_bits_B ) :
     ( w_nzp_we_A ) ? ( w_nzp_bits_A ) : ( curr_nzp );
 wire o_branch_A = (( x_insn_A[11:9] & br_nzp_A ) != 3'b000);

 wire [2:0] br_nzp_B; 
 assign br_nzp_B = ( x_nzp_we_A ) ? ( x_nzp_bits_A ) : br_nzp_A;
 wire o_branch_B = (( x_insn_B[11:9] & br_nzp_B ) != 3'b000);

// test
 assign test_stall_A = w_stall_A;                        
 assign test_stall_B = w_stall_B;                     
 assign test_cur_pc_A = w_pc;        
 wire[15:0]w_pc_result;                  
 cla16 c2(.a(w_pc), .b(16'b0), .cin(1'b1), .sum(w_pc_result));      
 assign test_cur_pc_B = w_pc_result;
 assign test_cur_insn_A = w_insn_A;                                                        
 assign test_cur_insn_B = w_insn_B;                                                              
 assign test_regfile_we_A = w_regfile_we_A;   			                  
 assign test_regfile_we_B = w_regfile_we_B;                                                      
 assign test_regfile_wsel_A = w_wsel_A;                                               
 assign test_regfile_wsel_B = w_wsel_B;                                                          
 assign test_regfile_data_A = w_mux_output_A;                    
 assign test_regfile_data_B = w_mux_output_B;     
 assign test_nzp_we_A = w_nzp_we_A;                                         
 assign test_nzp_we_B = w_nzp_we_B;                                                     
 assign test_nzp_new_bits_A = w_temp_nzp_bits_A;
 assign test_nzp_new_bits_B = w_temp_nzp_bits_B;
 assign test_dmem_we_A = w_dmem_we_A;                                                        
 assign test_dmem_we_B = w_dmem_we_B;                                                                         
 assign test_dmem_addr_A = w_dmem_addr_A;                                        
 assign test_dmem_addr_B = w_dmem_addr_B;                                                                       
 assign test_dmem_data_A = w_dmem_data_A;                                           
 assign test_dmem_data_B = w_dmem_data_B;                                                                       

 /* Add $display(...) calls in the always block below to
    * print out debug information at the end of every cycle.
    *
    * You may also use if statements inside the always block
    * to conditionally print out information.
    */
  always @(posedge gwe) begin
    /*
    $display("1:f_pcA: %h,i_cur_insnA: %h,f_insn_A: %h"  ,f_pc,i_cur_insn_A,f_insn_A);
    $display("1:f_pcB: %h,i_cur_insnB: %h,f_insn_B: %h"  ,f_pc,i_cur_insn_B,f_insn_B);
    $display("2:d_pcA: %h,i_cur_insnA: %h,x_pcA: %h,x_insn_A: %h" ,d_pc,d_insn_A,x_pc,x_insn_A);
    $display("2:d_pcB: %h,i_cur_insnB: %h,x_pcA: %h,x_insn_B: %h" ,d_pc,d_insn_B,x_pc,x_insn_B);
    $display("3:m_pcA: %h,m_insn_A: %h,w_pcA: %h,w_insn_A: %h" ,m_pc,m_insn_A,w_pc,w_insn_A);
    $display("3:m_pcB: %h,m_insn_B: %h,w_pcB: %h,w_insn_B: %h" ,m_pc,m_insn_B,w_pc,w_insn_B);
    $display("4:superscalar_stall: %h,w_stall_A: %h,w_stall_B: %h" ,superscalar_stall,w_stall_A,w_stall_B);
    $write("X: x_r1data_B: %h x_r2data_B: %h ", x_r1data_B, x_r2data_B); $display(" ");
        $write("X: x_r1_data_bypassed_B: %h x_r2_data_bypassed_B: %h ", x_r1_data_bypassed_B, x_r2_data_bypassed_B); $display(" ");
        $write("X: alu_result_A: %h alu_result_B: %h ", alu_result_A, alu_result_B); $display(" ");
        $write("X: m_dmem_dataA: %h m_dmem_dataB: %h ",m_dmem_dataA, m_dmem_dataB); $display("");
        $write("o_dmem_towrite: %h ",o_dmem_towrite); $display("");
        $write("w_regfileA: %h w_regfileB: %h ", w_mux_output_A, w_mux_output_B); 
        $write("w_temp_nzp_bits_A: %h w_temp_nzp_bits_B: %h ", w_temp_nzp_bits_A, w_temp_nzp_bits_B); $display(")");
        $write("w_nzp_into_reg: %h w_nzp_we_A: %h w_nzp_we_B: %h ", w_nzp_into_reg, w_nzp_we_A, w_nzp_we_B);
        $display("");
        */
    //$display("1:w_is_load: %h,  o_rs_data: %h, o_rt_data: %h, x_bypassed_nzp_bits: %b,  alu: %h, x_r1_data_bypassed: %h, x_r2_data_bypassed: %h", w_is_load, o_rs_data, o_rt_data, x_bypassed_nzp_bits, alu_result, x_r1_data_bypassed, x_r2_data_bypassed);
    //$display("2:pc: %h, insn: %b, d_stall: %h, w_dmem_output: %h, f_stall: %h, is_stall :%h", pc, x_insn, d_stall, w_dmem_output, f_stall, is_stall);        
    // $display("1:w_is_load: %h,  o_rs_data: %h, o_rt_data: %h,w_o_rt_data: %h, w_is_store: %h,  alu: %h, x_r1_data_bypassed: %h, x_r2_data_bypassed: %h", w_is_load, o_rs_data, o_rt_data, w_rt_data,w_is_store, alu_result, x_r1_data_bypassed, x_r2_data_bypassed);
    // $display("2:pc: %h, insn: %b, alu: %h, w_dmem_output: %h, m_nzp_bits: %h, w_mux_output :%h", pc, x_insn, alu_result, w_dmem_output, m_nzp_bits, w_mux_output);      
    // $display("3:m_is_load: %h ,m_pc: %h,w_is_load :%h, w_pc: %h, w_dmem_output : %h, i_cur_dmem_data: %h", m_is_load, m_pc ,w_is_load,w_pc, w_dmem_output,i_cur_dmem_data );      
    //  $display("4:is_stall: %h,d_stall: %h,x_stall: %h, m_stall: %h,w_stall: %h" ,is_stall,d_stall,x_stall,m_stall,w_stall);
    //$display("5:pc: %h,next_pc: %h,d_pc: %h, x_pc: %h,m_pc: %h,w_pc: %h"  ,pc,next_pc,d_pc,x_pc,m_pc,w_pc);
    //display("6:f_insn: %h,d_insn: %h, d_insn_tmp: %h,x_insn: %h,m_insn: %h,w_insn: %h"  ,f_insn,d_insn,d_insn_tmp,x_insn,m_insn,w_insn);
    
      // $display("%d %h %h %h %h %h", $time, f_pc, d_pc, e_pc, m_pc, test_cur_pc);
      // if (o_dmem_we)
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
      // run it for that many nanoseconds, then set
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
endmodule
