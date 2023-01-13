module gpio(

    input wire clk,
	input wire rst,

    input wire we_i,
    input wire[31:0] addr_i,
    input wire[31:0] data_i,

    output reg[31:0] data_o,

    input wire[1:0] io_pin_i,
    output wire[31:0] reg_ctrl,
    output wire[31:0] reg_data

    );
    localparam GPIO_CONTROL = 4'h0;
    localparam GPIO_DATA = 4'h4;
    reg[31:0] gpio_control;
    reg[31:0] gpio_data;
    assign reg_control = gpio_control;
    assign reg_data = gpio_data;


    
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            gpio_data <= 32'h0;
            gpio_control <= 32'h0;
        end else begin
            if (we_i == 1'b1) begin
                case (addr_i[3:0])
                    GPIO_CONTROL: begin
                        gpio_control <= data_i;
                    end
                    GPIO_DATA: begin
                        gpio_data <= data_i;
                    end
                endcase
            end else begin
                if (gpio_control[1:0] == 2'b10) begin
                    gpio_data[0] <= io_pin_i[0];
                end
                if (gpio_control[3:2] == 2'b10) begin
                    gpio_data[1] <= io_pin_i[1];
                end
            end
        end
    end

    always @ (*) begin
        if (rst == 1'b0) begin
            data_o = 32'h0;
        end else begin
            case (addr_i[3:0])
                GPIO_CONTROL: begin
                    data_o = gpio_control;
                end
                GPIO_DATA: begin
                    data_o = gpio_data;
                end
                default: begin
                    data_o = 32'h0;
                end
            endcase
        end
    end

endmodule