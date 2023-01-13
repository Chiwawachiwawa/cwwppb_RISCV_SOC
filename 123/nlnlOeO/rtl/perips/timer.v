module timer(
    input wire clk,
    input wire rst,

    input wire[31:0] data_i,
    input wire[31:0] addr_i,
    input wire we_i,

    output reg[31:0] data_o,
    output wire int_sig_o
    );
    localparam CTRL = 4'h0;
    localparam CT = 4'h4;
    localparam VALUE = 4'h8;

    reg[31:0] t_ctrl;
    reg[31:0] t_ct;
    reg[31:0] t_val;
    assign int_sig_o = ((t_ctrl[2] == 1'b1) && (t_ctrl[1] == 1'b1))? 1'b1:1'b0;

    // counter
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            t_ct <= 32'h0;
        end 
        else begin
            if (t_ctrl[0] == 1'b1) begin
                t_ct <= t_ct + 1'b1;
                if (t_ct >= t_val) begin
                    t_ct <= 32'h0;
                end
            end else begin
                t_ct <= 32'h0;
            end
        end
    end

    // write regs
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            t_ctrl <= 32'h0;
            t_val <= 32'h0;
        end 
        else begin
            if (we_i == 1'b1) begin
                case (addr_i[3:0])
                    CTRL: begin
                        t_ctrl <= {data_i[31:3], (t_ctrl[2] & (~data_i[2])), data_i[1:0]};
                    end
                    VALUE: begin
                        t_val <= data_i;
                    end
                endcase
            end 
            else begin
                if ((t_ctrl[0] == 1'b1) && (t_ct >= t_val)) begin
                    t_ctrl[0] <= 1'b0;
                    t_ctrl[2] <= 1'b1;
                end
            end
        end
    end

    // read regs
    always @ (*) begin
        if (rst == 1'b0) begin
            data_o = 32'h0;
        end 
        else begin
            case (addr_i[3:0])
                VALUE: begin
                    data_o = t_val;
                end
                CTRL: begin
                    data_o = t_ctrl;
                end
                CT: begin
                    data_o = t_ct;
                end
                default: begin
                    data_o = 32'h0;
                end
            endcase
        end
    end

endmodule