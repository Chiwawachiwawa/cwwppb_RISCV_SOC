module rom(

    input wire clk,
    input wire rst,

    input wire we_i,// write enable
    input wire[31:0] addr_i,// addr
    input wire[31:0] data_i,

    output reg[31:0] data_o// read data

    );

    reg[31:0] _rom[0:4095];//rom total-1


    always @ (posedge clk) begin
        if (we_i == 1'b1) begin
            _rom[addr_i[31:2]] <= data_i;
        end
    end

    always @ (*) begin
        if (rst == 1'b0) begin
            data_o = 32'h0;
        end 
        else begin
            data_o = _rom[addr_i[31:2]];
        end
    end

endmodule
