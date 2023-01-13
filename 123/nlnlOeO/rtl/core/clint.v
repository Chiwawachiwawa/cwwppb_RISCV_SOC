module clint(

    input wire clk,
    input wire rst,

    // from core
    input wire[7:0] int_flag_i,          

    // from id
    input wire[31:0] inst_i,              
    input wire[31:0] inst_addr_i,     

    // from ex
    input wire jump_flag_i,
    input wire[31:0] jump_addr_i,
    input wire div_started_i,

    // from ctrl
    input wire[2:0] hold_flag_i,  

    // from csr_reg
    input wire[31:0] data_i,               
    input wire[31:0] csr_mtvec,            
    input wire[31:0] csr_mepc,             
    input wire[31:0] csr_mstatus,          

    input wire  global_int_en_i,               
    // to ctrl
    output wire     hold_flag_o,                  
    // to csr_reg
    output reg             we_o,                          
    output reg[31:0]    waddr_o,          
    output reg[31:0]    raddr_o,          
    output reg[31:0]     data_o,               

    // to ex
    output reg[31:0]  int_addr_o,      
    output reg      int_assert_o                   
    );
    //def有限狀態機
    localparam INT_IDLE  = 4'b0001;
    localparam INT_SYNC  = 4'b0010;
    localparam INT_ASYNC = 4'b0100;
    localparam INT_MERT  = 4'b1000;
    //csr regs狀態定義
    localparam CSR_IDEL  =5'b00001;
    localparam CSR_STAT  =5'b00010;
    localparam CSR_MEPC  =5'b00100;
    localparam CSR_STMT  =5'b01000;
    localparam CSR_CAUS  =5'b10000;

    reg [3:0]    int_st;
    reg [4:0]    csr_st;
    reg [31:0] int_addr;
    reg [31:0]    cause;

    assign hold_flag_o = ((int_st!=INT_IDLE)|(csr_st!=CSR_IDEL))?1'b1:1'b0;

    always @(*) begin
        if(rst==1'b0)begin
            int_st=INT_IDLE;
        end
        else begin
            if(inst_i==32'h73||inst_i==32'h00100073)begin
                if(div_started_i==1'b0)begin
                    int_st=INT_SYNC;
                end
                else begin
                    int_st=INT_IDLE;
                end
            end
            else if(int_flag_i!=8'h0&&global_int_en_i==1'b1)begin
                int_st=INT_ASYNC;
            end
            else if(inst_i==32'h30200073)begin
                int_st=INT_MERT;
            end
            else begin
                int_st=INT_IDLE;
            end
        end
    end


    always @(posedge clk) begin
        if (rst==1'b0) begin
            csr_st<=CSR_IDEL;
            cause<=32'h0;
            int_addr<=32'h0;
        end
        else begin
            case(csr_st)
            CSR_IDEL:begin
                if (int_st==INT_SYNC) begin
                    csr_st<=CSR_MEPC;
                    if (jump_flag_i==1'b1) begin
                        int_addr<=jump_addr_i-4'h4;
                    end
                    else begin
                         int_addr<=inst_addr_i;
                    end
                    case(inst_i)
                        32'h73:begin
                            cause<=32'd11;
                        end
                        32'h00100073:begin
                            cause<=32'd3;
                        end
                        default:begin
                            cause<=32'd10;
                        end
                    endcase
                end
                else if (int_st==INT_ASYNC) begin
                    cause<=32'h80000004;
                    csr_st<=CSR_MEPC;
                    if (jump_flag_i==1'b1) begin
                        int_addr<=jump_addr_i;
                    end
                    else if(div_started_i==1'b1) begin
                        int_addr<=inst_addr_i-4'h4;
                    end
                    else begin
                        int_addr<=inst_addr_i;
                    end
                end
                else if (int_st==INT_MERT) begin
                    csr_st<=CSR_STMT;
                end
            end
            CSR_STAT:begin
                csr_st<=CSR_STAT;
            end
            CSR_MEPC:begin
                csr_st<=CSR_CAUS;
            end
            CSR_STMT:begin
                csr_st<=CSR_IDEL;
            end
            CSR_CAUS:begin
                csr_st<=CSR_IDEL;
            end
            default:begin
                csr_st<=CSR_IDEL;
            end
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst == 1'b0) begin
            we_o <= 1'b0;
            waddr_o <= 32'h0;
            data_o <= 32'h0;
        end
        else begin
            case(csr_st)
                CSR_MEPC:begin
                    we_o<=1'b1;
                    waddr_o<={20'h0,12'h341};
                    data_o<=int_addr;
                end 
                CSR_CAUS:begin
                    we_o<=1'b1;
                    waddr_o<={20'h0,12'h342};
                    data_o<=cause;
                end 
                CSR_STAT:begin
                    we_o<=1'b1;
                    waddr_o<={20'h0,12'h300};
                    data_o<={csr_mstatus[31:4],1'b0,csr_mstatus[2:0]};
                end 
                CSR_STMT:begin
                    we_o<=1'b1;
                    waddr_o<={20'h0,12'h300};
                    data_o<={csr_mstatus[31:4],csr_mstatus[7],csr_mstatus[2:0]};
                end 
                default:begin
                    we_o<=1'b0;
                    waddr_o<=32'h0;
                    data_o<=32'h0;
                end 
            endcase
        end 
    end
    
    always @(posedge clk) begin
        if (rst==1'b0) begin
            int_assert_o<=1'b0;
            int_addr_o<=32'h0;
        end
        else begin
            case(csr_st)
                CSR_CAUS:begin
                    int_assert_o<=1'b1;
                    int_addr_o<=csr_mtvec;
                end
                CSR_STMT:begin
                    int_assert_o<=1'b1;
                    int_addr_o<=csr_mepc;
                end
                default:begin
                    int_assert_o<=1'b0;
                    int_addr_o<=32'h0;
                end
            endcase
        end     
    end
endmodule