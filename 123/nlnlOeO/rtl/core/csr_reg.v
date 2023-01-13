module csr_reg(

    input wire clk,
    input wire rst,

    // form ex
    input wire we_i,                         
    input wire[31:0] raddr_i,         
    input wire[31:0] waddr_i,         
    input wire[31:0] data_i,              

    // from clint
    input wire clint_we_i,                   
    input wire[31:0] clint_raddr_i,   
    input wire[31:0] clint_waddr_i,   
    input wire[31:0] clint_data_i,        

    output wire global_int_en_o,             

    // to clint
    output reg[31:0] clint_data_o,        
    output wire[31:0] clint_csr_mtvec,    
    output wire[31:0] clint_csr_mepc,     
    output wire[31:0] clint_csr_mstatus,  

    // to ex
    output reg[31:0] data_o               
    );
    reg[63:0] cycle  ;
    reg[31:0] tvec   ;
    reg[31:0] cause  ;
    reg[31:0] epc    ;
    reg[31:0] mei    ;
    reg[31:0] status ;
    reg[31:0] scratch;
    
    assign global_int_en_o=(status[3]==1'b1)?1'b1:1'b0;

    assign clint_csr_mtvec      = tvec   ;
    assign clint_csr_mepc       = epc    ;
    assign clint_csr_mstatus    = status ;
always @(posedge clk) begin
    if(rst==1'b0)begin
        cycle<={32'h0,32'h0};
    end
    else begin
        cycle<=cycle+1'b1;
    end
end

always @(posedge clk) begin
    if (rst==1'b1) begin
        tvec<=32'h0;
        cause<=32'h0;
        epc<=32'h0;
        mei<=32'h0;
        status<=32'h0;
        scratch<=32'h0;
    end
    else begin
        if (we_i==1'b1) begin
            case (waddr_i[11:0])
                12'h305:begin
                    tvec<=data_i;
                end 
                12'h342:begin
                    cause<=data_i;
                end
                12'h341:begin
                    epc<=data_i;
                end
                12'h304:begin
                    mei<=data_i;
                end
                12'h300:begin
                    status<=data_i;
                end
                12'h340:begin
                    scratch<=data_i;
                end
                default:begin
                    
                end 
            endcase    
        end
        else if(clint_we_i == 1'b1) begin
            case (clint_waddr_i[11:0])
                12'h305:begin
                    tvec<=clint_data_i;
                end 
                12'h342:begin
                    cause<=clint_data_i;
                end
                12'h341:begin
                    epc<=clint_data_i;
                end
                12'h304:begin
                    mei<=clint_data_i;
                end
                12'h300:begin
                    status<=clint_data_i;
                end
                12'h340:begin
                    scratch<=clint_data_i;
                end
                default:begin
                    
                end 
            endcase
        end
    end
end

always @(*) begin
    if ((waddr_i[11:0] == raddr_i[11:0]) && (we_i == 1'b1)) begin
        data_o=data_i;
    end
    else begin
        case (raddr_i[11:0])
            12'hc00:begin
                data_o= cycle[31:0];
            end
            12'hc80:begin
                data_o= cycle[63:32];
            end
            12'h305:begin
                data_o= tvec;
            end
            12'h342:begin
                data_o= cause;
            end
            12'h341:begin
                data_o= epc;
            end
            12'h304:begin
                data_o= mei;
            end
            12'h300:begin
                data_o= status;
            end
            12'h340:begin
                data_o= scratch;
            end 
            default:begin
                data_o= 32'h0;
            end 
        endcase
        
    end
end

always @(*) begin
        if ((clint_waddr_i[11:0] == clint_raddr_i[11:0]) && (clint_we_i == 1'b1)) begin
            clint_data_o = clint_data_i;
        end 
        else begin
            case (clint_raddr_i[11:0])
                12'hc00:begin
                    clint_data_o = cycle[31:0];
                end
                12'hc80:begin
                    clint_data_o = cycle[63:32];
                end
                12'h305:begin
                    clint_data_o =tvec;
                end
                12'h342:begin
                    clint_data_o =cause;
                end
                12'h341:begin
                    clint_data_o =epc;
                end
                12'h304:begin
                    clint_data_o =mei;
                end
                12'h300:begin
                    clint_data_o =status;
                end
                12'h340:begin
                    clint_data_o =scratch;
                end
                default:begin
                    clint_data_o  =32'h0;
                end
            endcase
        end
end

endmodule
