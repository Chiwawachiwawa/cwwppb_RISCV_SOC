module pc_reg(

    input wire clk,
    input wire rst,

    input wire jump_flag_i,
    input wire[31:0] jump_addr_i,
    input wire[2:0] hold_flag_i,
    input wire jtag_reset_flag_i,

    output reg[31:0] pc_o

    );


    always @ (posedge clk) begin
        
        if (rst == 1'b0 || jtag_reset_flag_i == 1'b1) begin
            pc_o <= 32'h0;
        
        end else if (jump_flag_i == 1'b1) begin
            pc_o <= jump_addr_i;
        
        end else if (hold_flag_i >= 3'b001) begin
            pc_o <= pc_o;
        
        end else begin
            pc_o <= pc_o + 4'h4;
        end
    end

endmodule
