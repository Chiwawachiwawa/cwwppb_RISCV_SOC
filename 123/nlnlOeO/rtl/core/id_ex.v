module id_ex(

    input wire clk,
    input wire rst,

    input wire[31:0] inst_i,             
    input wire[31:0] inst_addr_i,    
    input wire reg_we_i,                     
    input wire[4:0] reg_waddr_i,     
    input wire[31:0] reg1_rdata_i,        
    input wire[31:0] reg2_rdata_i,        
    input wire csr_we_i,                     
    input wire[31:0] csr_waddr_i,     
    input wire[31:0] csr_rdata_i,         
    input wire[31:0] op1_i,
    input wire[31:0] op2_i,
    input wire[31:0] op1_jump_i,
    input wire[31:0] op2_jump_i,

    input wire[2:0] hold_flag_i,  

    output wire[31:0] op1_o,
    output wire[31:0] op2_o,
    output wire[31:0] op1_jump_o,
    output wire[31:0] op2_jump_o,
    output wire[31:0] inst_o,
    output wire[31:0] inst_addr_o,
    output wire reg_we_o,
    output wire[4:0] reg_waddr_o,
    output wire[31:0] reg1_rdata_o,
    output wire[31:0] reg2_rdata_o,
    output wire csr_we_o,
    output wire[31:0] csr_waddr_o,
    output wire[31:0] csr_rdata_o

    );

    wire hold_en = (hold_flag_i >= 3'b011);

    wire[31:0] inst;
    gen_pipe_dff #(32) inst_ff(clk, rst, hold_en, 32'h00000001, inst_i, inst);
    assign inst_o = inst;//inst_nop

    wire[31:0] inst_addr;
    gen_pipe_dff #(32) inst_addr_ff(clk, rst, hold_en, 32'h0, inst_addr_i, inst_addr);
    assign inst_addr_o = inst_addr;

    wire reg_we;
    gen_pipe_dff #(1) reg_we_ff(clk, rst, hold_en, 1'b0, reg_we_i, reg_we);
    assign reg_we_o = reg_we;

    wire[4:0] reg_waddr;
    gen_pipe_dff #(5) reg_waddr_ff(clk, rst, hold_en, 5'h0, reg_waddr_i, reg_waddr);
    assign reg_waddr_o = reg_waddr;

    wire[31:0] reg1_rdata;
    gen_pipe_dff #(32) reg1_rdata_ff(clk, rst, hold_en, 32'h0, reg1_rdata_i, reg1_rdata);
    assign reg1_rdata_o = reg1_rdata;

    wire[31:0] reg2_rdata;
    gen_pipe_dff #(32) reg2_rdata_ff(clk, rst, hold_en, 32'h0, reg2_rdata_i, reg2_rdata);
    assign reg2_rdata_o = reg2_rdata;

    wire csr_we;
    gen_pipe_dff #(1) csr_we_ff(clk, rst, hold_en, 1'b0, csr_we_i, csr_we);
    assign csr_we_o = csr_we;

    wire[31:0] csr_waddr;
    gen_pipe_dff #(32) csr_waddr_ff(clk, rst, hold_en, 32'h0, csr_waddr_i, csr_waddr);
    assign csr_waddr_o = csr_waddr;

    wire[31:0] csr_rdata;
    gen_pipe_dff #(32) csr_rdata_ff(clk, rst, hold_en, 32'h0, csr_rdata_i, csr_rdata);
    assign csr_rdata_o = csr_rdata;

    wire[31:0] op1;
    gen_pipe_dff #(32) op1_ff(clk, rst, hold_en, 32'h0, op1_i, op1);
    assign op1_o = op1;

    wire[31:0] op2;
    gen_pipe_dff #(32) op2_ff(clk, rst, hold_en, 32'h0, op2_i, op2);
    assign op2_o = op2;

    wire[31:0] op1_jump;
    gen_pipe_dff #(32) op1_jump_ff(clk, rst, hold_en, 32'h0, op1_jump_i, op1_jump);
    assign op1_jump_o = op1_jump;

    wire[31:0] op2_jump;
    gen_pipe_dff #(32) op2_jump_ff(clk, rst, hold_en, 32'h0, op2_jump_i, op2_jump);
    assign op2_jump_o = op2_jump;

endmodule
