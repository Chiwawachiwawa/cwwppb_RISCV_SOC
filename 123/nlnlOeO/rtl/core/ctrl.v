module ctrl(
    input wire rst,
    // from ex
    input wire        jump_flag_i,
    input wire[31:0]  jump_addr_i,
    input wire        hold_flag_ex_i,
    // from rib
    input wire hold_flag_rib_i,
    // from jtag
    input wire jtag_halt_flag_i,
    // from clint
    input wire hold_flag_clint_i,
    output reg[2:0] hold_flag_o,
    // to pc_reg
    output reg jump_flag_o,
    output reg[31:0] jump_addr_o
    );
    always @ (*) begin
        jump_addr_o = jump_addr_i;
        jump_flag_o = jump_flag_i;
        hold_flag_o = 3'b000;
        if (jump_flag_i == 1'b1 || hold_flag_ex_i == 1'b1 || hold_flag_clint_i == 1'b1) begin
            hold_flag_o = 3'b011;
        end else if (hold_flag_rib_i == 1'b1) begin
            hold_flag_o = 3'b001;
        end else if (jtag_halt_flag_i == 1'b1) begin
            hold_flag_o = 3'b011;
        end else begin
            hold_flag_o = 3'b000;
        end
    end

endmodule
