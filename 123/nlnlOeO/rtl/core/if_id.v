module if_id(

    input wire clk,
    input wire rst,

    input wire[31:0] inst_i,             
    input wire[31:0] inst_addr_i,    

    input wire[2:0] hold_flag_i,  

    input wire[7:0] int_flag_i,         
    output wire[7:0] int_flag_o,

    output wire[31:0] inst_o,            
    output wire[31:0] inst_addr_o    

    );

    wire hold_en = (hold_flag_i >= 3'b010);

    wire[31:0] inst;
    gen_pipe_dff #(32) inst_ff(clk, rst, hold_en, 32'h00000001, inst_i, inst);
    assign inst_o = inst;

    wire[31:0] inst_addr;
    gen_pipe_dff #(32) inst_addr_ff(clk, rst, hold_en, 32'h0, inst_addr_i, inst_addr);
    assign inst_addr_o = inst_addr;

    wire[7:0] int_flag;
    gen_pipe_dff #(8) int_ff(clk, rst, hold_en, 8'h0, int_flag_i, int_flag);
    assign int_flag_o = int_flag;

endmodule
