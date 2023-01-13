module div(

    input wire clk,
    input wire rst,

    // from ex
    input wire[31:0] dividend_i,      
    input wire[31:0] divisor_i,       
    input wire start_i,                  
    input wire[2:0] op_i,                
    input wire[4:0] reg_waddr_i, 

    // to ex
    output reg[31:0] result_o,        
    output reg ready_o,                  
    output reg busy_o,                  
    output reg[4:0] reg_waddr_o  

    );
    localparam FSM_IDEL  = 4'b0001;
    localparam FSM_START = 4'b0010;
    localparam FSM_CALC  = 4'b0100;
    localparam FSM_END   = 4'b1000;

    reg [31:0] dividend  ;
    reg [31:0] divisor   ;
    reg [2:0]  op_r      ;
    reg [3:0]  fsm_st    ;
    reg [31:0] ct        ;
    reg [31:0] div_result;
    reg [31:0] div_remain;
    reg [31:0] minen     ;
    reg     invert_result;

    wire div_op =(op_r==3'b100);
    wire divu_op=(op_r==3'b101);
    wire rem_op =(op_r==3'b110);
    wire remu_op=(op_r==3'b111);
    wire [31:0] dividend_neg    = (-dividend)  ;
    wire [31:0] divisor_neg     = (-divisor)   ;
    wire minen_divisor=minen   >= divisor      ;
    wire [31:0] minen_sub_res   = minen-divisor;
    wire [31:0] div_result_temp = minen_divisor?({div_result[30:0], 1'b1}): ({div_result[30:0], 1'b0});
    wire [31:0] minen_temp      = minen_divisor?minen_sub_res[30:0]:minen[30:0];

    //FSM
    always @(posedge clk) begin
        if(rst==1'b0)begin
            fsm_st        <=FSM_IDEL;
            ready_o           <=1'b0;
            result_o         <=32'h0;
            div_result       <=32'h0;
            div_remain       <=32'h0;
            op_r              <=3'h0;
            reg_waddr_o      <=32'h0;
            dividend         <=32'h0;
            divisor          <=32'h0;
            minen            <=32'h0;
            invert_result     <=1'b0;
            busy_o            <=1'b0;
            ct               <=32'h0;
        end
        else begin
            case(fsm_st)
                FSM_IDEL:begin
                    if (start_i == 1'b1) begin
                        op_r        <=       op_i;
                        dividend    <= dividend_i;
                        divisor     <=  divisor_i;
                        reg_waddr_o <=reg_waddr_o;
                        fsm_st      <=  FSM_START;
                        busy_o      <=       1'b1;
                    end
                    else begin
                        op_r<=3'h0;
                        reg_waddr_o <=32'h0;
                        dividend    <=32'h0;
                        divisor     <=32'h0;
                        ready_o     <= 1'b0;
                        result_o    <=32'h0;
                        busy_o      <= 1'b0;
                    end
                end
                FSM_START:begin
                    if (start_i==1'b1) begin
                        if (divisor==32'h0) begin
                            if (div_op|divu_op) begin
                                result_o<=32'hffffffff;
                            end
                            else begin
                                result_o<=dividend;
                            end
                            ready_o   <=1'b1    ;
                            fsm_st        <=FSM_IDEL;
                            busy_o    <=1'b0    ;
                        end
                        else begin
                            busy_o      <=1'h1         ;
                            ct          <=32'h40000000 ;
                            fsm_st      <=FSM_CALC     ;
                            div_result  <=32'h0        ;
                            div_remain  <=32'h0        ;
                            if (div_op|rem_op) begin
                                if (dividend[31]==1'b1) begin
                                    dividend<=dividend_neg;
                                    minen<=dividend_neg[31];
                                end
                                else begin
                                    minen<=dividend[31];
                                end
                                if (divisor[31]==1'b1) begin
                                    divisor<=divisor_neg;
                                end
                            end
                            else begin
                                minen<=dividend[31];
                            end
                            if ((div_op && (dividend[31] ^ divisor[31] == 1'b1))||(rem_op && (dividend[31] == 1'b1))) begin
                                invert_result<=1'b1;
                            end
                            else begin
                                invert_result<=1'b0;
                            end
                        end
                    end
                    else begin
                        fsm_st<=FSM_IDEL;
                        result_o<=32'h0;
                        ready_o<=1'b0;
                        busy_o<=1'b0;
                    end
                end
                FSM_CALC:begin
                    if (start_i==1'b1) begin
                        dividend<={dividend[30:0], 1'b0};
                        div_result<=div_result_temp;
                        ct<={1'b0,ct[31:1]};
                        if (|ct) begin
                            minen<= {minen_temp[30:0], dividend[30]};
                        end
                        else begin
                            fsm_st<=FSM_END;
                            if (minen_divisor) begin
                                div_remain<=minen_sub_res;
                            end
                            else begin
                                div_remain<=minen;
                            end
                        end
                    end
                    else begin
                        fsm_st      <=  FSM_IDEL;
                        result_o<=     32'h0;
                        ready_o <=      1'b0;
                        busy_o  <=      1'b0;
                    end
                end
                FSM_END:begin
                    if (start_i==1'b1) begin
                        ready_o<=1'b1;
                        fsm_st<=FSM_IDEL;
                        busy_o<=1'b0;
                        if (div_op|divu_op) begin
                            if (invert_result) begin
                                result_o<=(-div_result);
                            end
                            else begin
                                result_o<=div_result;
                            end
                        end
                        else begin
                            if (invert_result) begin
                                result_o<=(-div_remain);
                            end
                            else begin
                                result_o<=div_remain;
                            end
                        end
                    end
                    else begin
                        fsm_st<=FSM_IDEL;
                        result_o<=32'h0;
                        ready_o<=1'b0;
                        busy_o<=1'b0;
                    end
                end
            endcase
        end
    end
endmodule
