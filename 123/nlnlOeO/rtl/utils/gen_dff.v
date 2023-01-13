module gen_pipe_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,
    input wire hold_en,

    input wire[DW-1:0] def_val,
    input wire[DW-1:0] din,
    output wire[DW-1:0] qout
    );
    reg[DW-1:0] qout_r;
    always @ (posedge clk) begin
        if (!rst | hold_en) begin
            qout_r <= def_val;
        end else begin
            qout_r <= din;
        end
    end
    assign qout = qout_r;
endmodule
module gen_rst_0_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,

    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;
    always @ (posedge clk) begin
        if (!rst) begin
            qout_r <= {DW{1'b0}};
        end 
        else begin                  
            qout_r <= din;
        end
    end
    assign qout = qout_r;

endmodule
module gen_rst_1_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,

    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

    always @ (posedge clk) begin
        if (!rst) begin
            qout_r <= {DW{1'b1}};
        end 
        else begin                  
            qout_r <= din;
        end
    end

    assign qout = qout_r;

endmodule
module gen_rst_def_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,
    input wire[DW-1:0] def_val,

    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

    always @ (posedge clk) begin
        if (!rst) begin
            qout_r <= def_val;
        end else begin                  
            qout_r <= din;
        end
    end

    assign qout = qout_r;

endmodule

module gen_en_dff #(
    parameter DW = 32)(

    input wire clk,
    input wire rst,

    input wire en,
    input wire[DW-1:0] din,
    output wire[DW-1:0] qout

    );

    reg[DW-1:0] qout_r;

    always @ (posedge clk) begin
        if (!rst) begin
            qout_r <= {DW{1'b0}};
        end 
        else if (en == 1'b1) begin
            qout_r <= din;
        end
    end

    assign qout = qout_r;

endmodule
