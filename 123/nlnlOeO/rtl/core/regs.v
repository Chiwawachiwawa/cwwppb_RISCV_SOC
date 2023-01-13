module regs(

    input wire clk,
    input wire rst,

    // from ex
    input wire we_i,                      
    input wire[4:0] waddr_i,      
    input wire[31:0] wdata_i,          

    // from jtag
    input wire jtag_we_i,                 
    input wire[4:0] jtag_addr_i,  
    input wire[31:0] jtag_data_i,      

    // from id
    input wire[4:0] raddr1_i,     

    // to id
    output reg[31:0] rdata1_o,         

    // from id
    input wire[4:0] raddr2_i,     

    // to id
    output reg[31:0] rdata2_o,         

    // to jtag
    output reg[31:0] jtag_data_o       

    );

    reg[31:0] regs[0:32 - 1];

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            if ((we_i == 1'b1) && (waddr_i != 5'h0)) begin
                regs[waddr_i] <= wdata_i;
            end else if ((jtag_we_i == 1'b1) && (jtag_addr_i != 5'h0)) begin
                regs[jtag_addr_i] <= jtag_data_i;
            end
        end
    end

    always @ (*) begin
        if (raddr1_i == 5'h0) begin
            rdata1_o = 32'h0;
        end else if (raddr1_i == waddr_i && we_i == 1'b1) begin
            rdata1_o = wdata_i;
        end else begin
            rdata1_o = regs[raddr1_i];
        end
    end

    always @ (*) begin
        if (raddr2_i == 5'h0) begin
            rdata2_o = 32'h0;
        end else if (raddr2_i == waddr_i && we_i == 1'b1) begin
            rdata2_o = wdata_i;
        end else begin
            rdata2_o = regs[raddr2_i];
        end
    end

    always @ (*) begin
        if (jtag_addr_i == 5'h0) begin
            jtag_data_o = 32'h0;
        end else begin
            jtag_data_o = regs[jtag_addr_i];
        end
    end

endmodule
