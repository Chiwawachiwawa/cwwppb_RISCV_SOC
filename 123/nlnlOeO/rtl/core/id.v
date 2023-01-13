module id(

	input wire rst,

    // from if_id
    input wire[31:0] inst_i,             
    input wire[31:0] inst_addr_i,    
    // from regs
    input wire[31:0] reg1_rdata_i,        
    input wire[31:0] reg2_rdata_i,        

    // from csr reg
    input wire[31:0] csr_rdata_i,         

    // from ex
    input wire ex_jump_flag_i,               

    // to regs
    output reg[4:0] reg1_raddr_o,    
    output reg[4:0] reg2_raddr_o,    

    // to csr reg
    output reg[31:0] csr_raddr_o,     

    // to ex
    output reg[31:0] op1_o,
    output reg[31:0] op2_o,
    output reg[31:0] op1_jump_o,
    output reg[31:0] op2_jump_o,
    output reg[31:0] inst_o,             
    output reg[31:0] inst_addr_o,    
    output reg[31:0] reg1_rdata_o,        
    output reg[31:0] reg2_rdata_o,        
    output reg reg_we_o,                     
    output reg[4:0] reg_waddr_o,     
    output reg csr_we_o,                     
    output reg[31:0] csr_rdata_o,         
    output reg[31:0] csr_waddr_o      

    );

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] fun3 = inst_i[14:12];
    wire[6:0] fun7 = inst_i[31:25];
    wire[4:0] rd = inst_i[11:7];
    wire[4:0] rs1 = inst_i[19:15];
    wire[4:0] rs2 = inst_i[24:20];


    always @ (*) begin
        inst_o = inst_i;
        inst_addr_o = inst_addr_i;
        reg1_rdata_o = reg1_rdata_i;
        reg2_rdata_o = reg2_rdata_i;
        csr_rdata_o = csr_rdata_i;
        csr_raddr_o = 32'h0;
        csr_waddr_o = 32'h0;
        csr_we_o = 1'b0;
        op1_o = 32'h0;
        op2_o = 32'h0;
        op1_jump_o = 32'h0;
        op2_jump_o = 32'h0;

        case (opcode)
            7'b0010011: begin
                case (fun3)
                    3'b000, 3'b010, 3'b011, 3'b100,3'b110,3'b111,3'b001,3'b101: begin
                        reg_we_o = 1'b1;
                        reg_waddr_o = rd;
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = 5'h0;
                        op1_o = reg1_rdata_i;
                        op2_o = {{20{inst_i[31]}}, inst_i[31:20]};
                    end
                    default: begin
                        reg_we_o = 1'b0;
                        reg_waddr_o = 5'h0;
                        reg1_raddr_o = 5'h0;
                        reg2_raddr_o = 5'h0;
                    end
                endcase
            end
            7'b0110011: begin
                if ((fun7 == 7'b0000000) || (fun7 == 7'b0100000)) begin
                    case (fun3)
                        3'b000, 3'b001, 3'b010,3'b011,3'b100,3'b101,3'b110,3'b111: begin
                            reg_we_o = 1'b1;
                            reg_waddr_o = rd;
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = rs2;
                            op1_o = reg1_rdata_i;
                            op2_o = reg2_rdata_i;
                        end
                        default: begin
                            reg_we_o = 1'b0;
                            reg_waddr_o = 5'h0;
                            reg1_raddr_o = 5'h0;
                            reg2_raddr_o = 5'h0;
                        end
                    endcase
                end 
                else if (fun7 == 7'b0000001) begin
                    case (fun3)
                        3'b000, 3'b001, 3'b010,3'b011: begin
                            reg_we_o = 1'b1;
                            reg_waddr_o = rd;
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = rs2;
                            op1_o = reg1_rdata_i;
                            op2_o = reg2_rdata_i;
                        end
                        3'b100, 3'b101, 3'b110,3'b111: begin
                            reg_we_o = 1'b0;
                            reg_waddr_o = rd;
                            reg1_raddr_o = rs1;
                            reg2_raddr_o = rs2;
                            op1_o = reg1_rdata_i;
                            op2_o = reg2_rdata_i;
                            op1_jump_o = inst_addr_i;
                            op2_jump_o = 32'h4;
                        end
                        default: begin
                            reg_we_o = 1'b0;
                            reg_waddr_o = 5'h0;
                            reg1_raddr_o = 5'h0;
                            reg2_raddr_o = 5'h0;
                        end
                    endcase
                end 
                else begin
                    reg_we_o = 1'b0;
                    reg_waddr_o = 5'h0;
                    reg1_raddr_o = 5'h0;
                    reg2_raddr_o = 5'h0;
                end
            end
            7'b0000011: begin
                case (fun3)
                    3'b000, 3'b001,3'b010, 3'b100,3'b101: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = 5'h0;
                        reg_we_o = 1'b1;
                        reg_waddr_o = rd;
                        op1_o = reg1_rdata_i;
                        op2_o = {{20{inst_i[31]}}, inst_i[31:20]};
                    end
                    default: begin
                        reg1_raddr_o = 5'h0;
                        reg2_raddr_o = 5'h0;
                        reg_we_o = 1'b0;
                        reg_waddr_o = 5'h0;
                    end
                endcase
            end
            7'b0100011: begin
                case (fun3)
                    3'b000, 3'b001,3'b010: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = 1'b0;
                        reg_waddr_o = 5'h0;
                        op1_o = reg1_rdata_i;
                        op2_o = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                    end
                    default: begin
                        reg1_raddr_o = 5'h0;
                        reg2_raddr_o = 5'h0;
                        reg_we_o = 1'b0;
                        reg_waddr_o = 5'h0;
                    end
                endcase
            end
            7'b1100011: begin
                case (fun3)
                    3'b000, 3'b001, 3'b100, 3'b101, 3'b110,3'b111: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = rs2;
                        reg_we_o = 1'b0;
                        reg_waddr_o = 5'h0;
                        op1_o = reg1_rdata_i;
                        op2_o = reg2_rdata_i;
                        op1_jump_o = inst_addr_i;
                        op2_jump_o = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                    end
                    default: begin
                        reg1_raddr_o = 5'h0;
                        reg2_raddr_o = 5'h0;
                        reg_we_o = 1'b0;
                        reg_waddr_o = 5'h0;
                    end
                endcase
            end
            7'b1101111: begin
                reg_we_o = 1'b1;
                reg_waddr_o = rd;
                reg1_raddr_o = 5'h0;
                reg2_raddr_o = 5'h0;
                op1_o = inst_addr_i;
                op2_o = 32'h4;
                op1_jump_o = inst_addr_i;
                op2_jump_o = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
            end
            7'b1100111: begin
                reg_we_o = 1'b1;
                reg1_raddr_o = rs1;
                reg2_raddr_o = 5'h0;
                reg_waddr_o = rd;
                op1_o = inst_addr_i;
                op2_o = 32'h4;
                op1_jump_o = reg1_rdata_i;
                op2_jump_o = {{20{inst_i[31]}}, inst_i[31:20]};
            end
            7'b0110111: begin
                reg_we_o = 1'b1;
                reg_waddr_o = rd;
                reg1_raddr_o = 5'h0;
                reg2_raddr_o = 5'h0;
                op1_o = {inst_i[31:12], 12'b0};
                op2_o = 32'h0;
            end
            7'b0010111: begin
                reg_we_o = 1'b1;
                reg_waddr_o = rd;
                reg1_raddr_o = 5'h0;
                reg2_raddr_o = 5'h0;
                op1_o = inst_addr_i;
                op2_o = {inst_i[31:12], 12'b0};
            end
            7'b0000001: begin
                reg_we_o = 1'b0;
                reg_waddr_o = 5'h0;
                reg1_raddr_o = 5'h0;
                reg2_raddr_o = 5'h0;
            end
            7'b0001111: begin
                reg_we_o = 1'b0;
                reg_waddr_o = 5'h0;
                reg1_raddr_o = 5'h0;
                reg2_raddr_o = 5'h0;
                op1_jump_o = inst_addr_i;
                op2_jump_o = 32'h4;
            end
            7'b1110011: begin
                reg_we_o = 1'b0;
                reg_waddr_o = 5'h0;
                reg1_raddr_o = 5'h0;
                reg2_raddr_o = 5'h0;
                csr_raddr_o = {20'h0, inst_i[31:20]};
                csr_waddr_o = {20'h0, inst_i[31:20]};
                case (fun3)
                    3'b001, 3'b010, 3'b011: begin
                        reg1_raddr_o = rs1;
                        reg2_raddr_o = 5'h0;
                        reg_we_o = 1'b1;
                        reg_waddr_o = rd;
                        csr_we_o = 1'b1;
                    end
                    3'b101,3'b110, 3'b111: begin
                        reg1_raddr_o = 5'h0;
                        reg2_raddr_o = 5'h0;
                        reg_we_o = 1'b1;
                        reg_waddr_o = rd;
                        csr_we_o = 1'b1;
                    end
                    default: begin
                        reg_we_o = 1'b0;
                        reg_waddr_o = 5'h0;
                        reg1_raddr_o = 5'h0;
                        reg2_raddr_o = 5'h0;
                        csr_we_o = 1'b0;
                    end
                endcase
            end
            default: begin
                reg_we_o = 1'b0;
                reg_waddr_o = 5'h0;
                reg1_raddr_o = 5'h0;
                reg2_raddr_o = 5'h0;
            end
        endcase
    end

endmodule
