module full_handshake_tx #(
    parameter DW = 32)(            

    input wire clk,                 
    input wire rst_n,             

    // from rx
    input wire ack_i,              

    // from tx
    input wire req_i,               
    input wire[DW-1:0] req_data_i,  
    // to tx
    output wire idle_o,            

    // to rx
    output wire req_o,             
    output wire[DW-1:0] req_data_o  

    );

    localparam STATE_IDLE     = 3'b001;
    localparam STATE_ASSERT   = 3'b010;
    localparam STATE_DEASSERT = 3'b100;

    reg[2:0] state;
    reg[2:0] state_next;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
        end 
        else begin
            state <= state_next;
        end
    end

    always @ (*) begin
        case (state)
            STATE_IDLE: begin
                if (req_i == 1'b1) begin
                    state_next = STATE_ASSERT;
                end 
                else begin
                    state_next = STATE_IDLE;
                end
            end
            STATE_ASSERT: begin
                if (!ack) begin
                    state_next = STATE_ASSERT;
                end 
                else begin
                    state_next = STATE_DEASSERT;
                end
            end
            STATE_DEASSERT: begin
                if (!ack) begin
                    state_next = STATE_IDLE;
                end 
                else begin
                    state_next = STATE_DEASSERT;
                end
            end
            default: begin
                state_next = STATE_IDLE;
            end
        endcase
    end

    reg ack_d;
    reg ack;
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ack_d <= 1'b0;
            ack <= 1'b0;
        end 
        else begin
            ack_d <= ack_i;
            ack <= ack_d;
        end
    end

    reg req;
    reg[DW-1:0] req_data;
    reg idle;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            idle <= 1'b1;
            req <= 1'b0;
            req_data <= {(DW){1'b0}};
        end 
        else begin
            case (state)
                STATE_IDLE: begin
                    if (req_i == 1'b1) begin
                        idle <= 1'b0;
                        req <= req_i;
                        req_data <= req_data_i;
                    end 
                    else begin
                        idle <= 1'b1;
                        req <= 1'b0;
                    end
                end
                STATE_ASSERT: begin
                    if (ack == 1'b1) begin
                        req <= 1'b0;
                        req_data <= {(DW){1'b0}};
                    end
                end
                STATE_DEASSERT: begin
                    if (!ack) begin
                        idle <= 1'b1;
                    end
                end
            endcase
        end
    end
    assign idle_o = idle;
    assign req_o = req;
    assign req_data_o = req_data;

endmodule
