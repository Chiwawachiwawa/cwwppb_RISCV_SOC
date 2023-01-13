module uart(

	input wire clk,
	input wire rst,

    input wire we_i,
    input wire[31:0] addr_i,
    input wire[31:0] data_i,

    output reg[31:0] data_o,
	output wire tx_pin,
    input wire rx_pin

    );

    localparam BAUD_115200 = 32'h1B8;

    localparam S_IDLE       = 4'b0001;
    localparam S_START      = 4'b0010;
    localparam S_SEND_BYTE  = 4'b0100;
    localparam S_STOP       = 4'b1000;
    reg tx_data_valid;
    reg tx_data_ready;
    reg[3:0] state;
    reg[15:0] cycle_count;
    reg[3:0] bit_count;
    reg[7:0] tx_data;
    reg tx_reg;
    reg rx_q0;
    reg rx_q1;
    wire rx_neg_edge;
    reg rx_start;                      
    reg[3:0] rx_clk_edge_count;          
    reg rx_clk_edge_level;             
    reg rx_done;
    reg[15:0] rx_clk_count;
    reg[15:0] rx_div_count;
    reg[7:0] rx_data;
    reg rx_over;
    localparam UART_CTRL = 8'h0;
    localparam UART_STATUS = 8'h4;
    localparam UART_BAUD = 8'h8;
    localparam UART_TXDATA = 8'hc;
    localparam UART_RXDATA = 8'h10;
    reg[31:0] uart_ctrl;
    reg[31:0] uart_status;
    reg[31:0] uart_baud;
    reg[31:0] uart_rx;
    assign tx_pin = tx_reg;
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            uart_ctrl <= 32'h0;
            uart_status <= 32'h0;
            uart_rx <= 32'h0;
            uart_baud <= BAUD_115200;
            tx_data_valid <= 1'b0;
        end 
        else begin
            if (we_i == 1'b1) begin
                case (addr_i[7:0])
                    UART_CTRL: begin
                        uart_ctrl <= data_i;
                    end
                    UART_BAUD: begin
                        uart_baud <= data_i;
                    end
                    UART_STATUS: begin
                        uart_status[1] <= data_i[1];
                    end
                    UART_TXDATA: begin
                        if (uart_ctrl[0] == 1'b1 && uart_status[0] == 1'b0) begin
                            tx_data <= data_i[7:0];
                            uart_status[0] <= 1'b1;
                            tx_data_valid <= 1'b1;
                        end
                    end
                endcase
            end else begin
                tx_data_valid <= 1'b0;
                if (tx_data_ready == 1'b1) begin
                    uart_status[0] <= 1'b0;
                end
                if (uart_ctrl[1] == 1'b1) begin
                    if (rx_over == 1'b1) begin
                        uart_status[1] <= 1'b1;
                        uart_rx <= {24'h0, rx_data};
                    end
                end
            end
        end
    end

    always @ (*) begin
        if (rst == 1'b0) begin
            data_o = 32'h0;
        end 
        else begin
            case (addr_i[7:0])
                UART_CTRL: begin
                    data_o = uart_ctrl;
                end
                UART_STATUS: begin
                    data_o = uart_status;
                end
                UART_BAUD: begin
                    data_o = uart_baud;
                end
                UART_RXDATA: begin
                    data_o = uart_rx;
                end
                default: begin
                    data_o = 32'h0;
                end
            endcase
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            state <= S_IDLE;
            cycle_count <= 16'd0;
            tx_reg <= 1'b0;
            bit_count <= 4'd0;
            tx_data_ready <= 1'b0;
        end 
        else begin
            if (state == S_IDLE) begin
                tx_reg <= 1'b1;
                tx_data_ready <= 1'b0;
                if (tx_data_valid == 1'b1) begin
                    state <= S_START;
                    cycle_count <= 16'd0;
                    bit_count <= 4'd0;
                    tx_reg <= 1'b0;
                end
            end 
            else begin
                cycle_count <= cycle_count + 16'd1;
                if (cycle_count == uart_baud[15:0]) begin
                    cycle_count <= 16'd0;
                    case (state)
                        S_START: begin
                            tx_reg <= tx_data[bit_count];
                            state <= S_SEND_BYTE;
                            bit_count <= bit_count + 4'd1;
                        end
                        S_SEND_BYTE: begin
                            bit_count <= bit_count + 4'd1;
                            if (bit_count == 4'd8) begin
                                state <= S_STOP;
                                tx_reg <= 1'b1;
                            end
                            else begin                
                                tx_reg <= tx_data[bit_count];
                            end
                        end
                        S_STOP: begin
                            tx_reg <= 1'b1;
                            state <= S_IDLE;
                            tx_data_ready <= 1'b1;
                        end
                    endcase
                end
            end
        end
    end
    assign rx_neg_edge = rx_q1 && ~rx_q0;

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            rx_q0 <= 1'b0;
            rx_q1 <= 1'b0;	
        end 
        else begin
            rx_q0 <= rx_pin;
            rx_q1 <= rx_q0;
        end
    end
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            rx_start <= 1'b0;
        end 
        else begin
            if (uart_ctrl[1]) begin
                if (rx_neg_edge) begin
                    rx_start <= 1'b1;
                end 
                else if (rx_clk_edge_count == 4'd9) begin
                    rx_start <= 1'b0;
                end
            end else begin
                rx_start <= 1'b0;
            end
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            rx_div_count <= 16'h0;
        end 
        else begin
            if (rx_start == 1'b1 && rx_clk_edge_count == 4'h0) begin
                rx_div_count <= {1'b0, uart_baud[15:1]};
            end 
            else begin
                rx_div_count <= uart_baud[15:0];
            end
        end
    end
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            rx_clk_count <= 16'h0;
        end 
        else if (rx_start == 1'b1) begin
            if (rx_clk_count == rx_div_count) begin
                rx_clk_count <= 16'h0;
            end 
            else begin
                rx_clk_count <= rx_clk_count + 1'b1;
            end
        end 
        else begin
            rx_clk_count <= 16'h0;
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            rx_clk_edge_count <= 4'h0;
            rx_clk_edge_level <= 1'b0;
        end 
        else if (rx_start == 1'b1) begin
            if (rx_clk_count == rx_div_count) begin
                if (rx_clk_edge_count == 4'd9) begin
                    rx_clk_edge_count <= 4'h0;
                    rx_clk_edge_level <= 1'b0;
                end 
                else begin
                    rx_clk_edge_count <= rx_clk_edge_count + 1'b1;
                    rx_clk_edge_level <= 1'b1;
                end
            end 
            else begin
                rx_clk_edge_level <= 1'b0;
            end
        end 
        else begin
            rx_clk_edge_count <= 4'h0;
            rx_clk_edge_level <= 1'b0;
        end
    end
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            rx_data <= 8'h0;
            rx_over <= 1'b0;
        end 
        else begin
            if (rx_start == 1'b1) begin
                if (rx_clk_edge_level == 1'b1) begin
                    case (rx_clk_edge_count)
                        1: begin

                        end
                        2, 3, 4, 5, 6, 7, 8, 9: begin
                            rx_data <= rx_data | (rx_pin << (rx_clk_edge_count - 2));
                            if (rx_clk_edge_count == 4'h9) begin
                                rx_over <= 1'b1;
                            end
                        end
                    endcase
                end
            end 
            else begin
                rx_data <= 8'h0;
                rx_over <= 1'b0;
            end
        end
    end
endmodule