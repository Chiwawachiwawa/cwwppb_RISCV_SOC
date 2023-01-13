module spi(

    input wire clk,
    input wire rst,

    input wire[31:0] data_i,
    input wire[31:0] addr_i,
    input wire we_i,

    output reg[31:0] data_o,

    output reg spi_mosi,
    input wire spi_miso,
    output wire spi_ss,
    output reg spi_clk

    );


    localparam SPI_CTRL   = 4'h0;    
    localparam SPI_DATA   = 4'h4;    
    localparam SPI_ST = 4'h8;    

    reg[31:0] ctrl_spi;
    reg[31:0] data_spi;
    reg[31:0] st_spi;

    reg[8:0] clk_ct;               
    reg en;                         
    reg[4:0] spi_clk_ct;      
    reg spi_clk_lv;         
    reg[7:0] rdata;                 
    reg done;                       
    reg[3:0] bit_id;             
    wire[8:0] ct_div;


    assign spi_ss = ~ctrl_spi[3];   

    assign ct_div = ctrl_spi[15:8];


    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            en <= 1'b0;
        end else begin
            if (ctrl_spi[0] == 1'b1) begin
                en <= 1'b1;
            end else if (done == 1'b1) begin
                en <= 1'b0;
            end else begin
                en <= en;
            end
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            clk_ct <= 9'h0;
        end 
        else if (en == 1'b1) begin
            if (clk_ct == ct_div) begin
                clk_ct <= 9'h0;
            end 
            else begin
                clk_ct <= clk_ct + 1'b1;
            end
        end 
        else begin
            clk_ct <= 9'h0;
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            spi_clk_ct <= 5'h0;
            spi_clk_lv <= 1'b0;
        end else if (en == 1'b1) begin
            if (clk_ct == ct_div) begin
                if (spi_clk_ct == 5'd17) begin
                    spi_clk_ct <= 5'h0;
                    spi_clk_lv <= 1'b0;
                end else begin
                    spi_clk_ct <= spi_clk_ct + 1'b1;
                    spi_clk_lv <= 1'b1;
                end
            end else begin
                spi_clk_lv <= 1'b0;
            end
        end else begin
            spi_clk_ct <= 5'h0;
            spi_clk_lv <= 1'b0;
        end
    end
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            spi_clk <= 1'b0;
            rdata <= 8'h0;
            spi_mosi <= 1'b0;
            bit_id <= 4'h0;
        end else begin
            if (en) begin
                if (spi_clk_lv == 1'b1) begin
                    case (spi_clk_ct)
                        1, 3, 5, 7, 9, 11, 13, 15: begin
                            spi_clk <= ~spi_clk;
                            if (ctrl_spi[2] == 1'b1) begin
                                spi_mosi <= data_spi[bit_id];  
                                bit_id <= bit_id - 1'b1;
                            end else begin
                                rdata <= {rdata[6:0], spi_miso};   
                            end
                        end
                        2, 4, 6, 8, 10, 12, 14, 16: begin
                            spi_clk <= ~spi_clk;
                            if (ctrl_spi[2] == 1'b1) begin
                                rdata <= {rdata[6:0], spi_miso};   
                            end else begin
                                spi_mosi <= data_spi[bit_id];  
                                bit_id <= bit_id - 1'b1;
                            end
                        end
                        17: begin
                            spi_clk <= ctrl_spi[1];
                        end
                    endcase
                end
            end 
            else begin
                spi_clk <= ctrl_spi[1];
                if (ctrl_spi[2] == 1'b0) begin
                    spi_mosi <= data_spi[7];           
                    bit_id <= 4'h6;
                end else begin
                    bit_id <= 4'h7;
                end
            end
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            done <= 1'b0;
        end else begin
            if (en && spi_clk_ct == 5'd17) begin
                done <= 1'b1;
            end else begin
                done <= 1'b0;
            end
        end
    end

    // write reg
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            ctrl_spi <= 32'h0;
            data_spi <= 32'h0;
            st_spi <= 32'h0;
        end else begin
            st_spi[0] <= en;
            if (we_i == 1'b1) begin
                case (addr_i[3:0])
                    SPI_CTRL: begin
                        ctrl_spi <= data_i;
                    end
                    SPI_DATA: begin
                        data_spi <= data_i;
                    end
                    default: begin

                    end
                endcase
            end else begin
                ctrl_spi[0] <= 1'b0;
                if (done == 1'b1) begin
                    data_spi <= {24'h0, rdata};
                end
            end
        end
    end

    // read reg
    always @ (*) begin
        if (rst == 1'b0) begin
            data_o = 32'h0;
        end else begin
            case (addr_i[3:0])
                SPI_CTRL: begin
                    data_o = ctrl_spi;
                end
                SPI_DATA: begin
                    data_o = data_spi;
                end
                SPI_ST: begin
                    data_o = st_spi;
                end
                default: begin
                    data_o = 32'h0;
                end
            endcase
        end
    end

endmodule
