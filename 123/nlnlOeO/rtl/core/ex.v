
module ex(

    input wire rst,

    // from id
    input wire[31:0] inst_i,            
    input wire[31:0] inst_addr_i,   
    input wire reg_we_i,                    
    input wire[4:0] reg_waddr_i,    
    input wire[31:0] reg1_rdata_i,       
    input wire[31:0] reg2_rdata_i,       
    input wire csr_we_i,                    
    input wire[31:0] csr_waddr_i,    
    input wire[31:0] csr_rdata_i,        
    input wire int_assert_i,                
    input wire[31:0] int_addr_i,    
    input wire[31:0] op1_i,
    input wire[31:0] op2_i,
    input wire[31:0] op1_jump_i,
    input wire[31:0] op2_jump_i,

    // from mem
    input wire[31:0] mem_rdata_i,        

    // from div
    input wire div_ready_i,                 
    input wire[31:0] div_result_i,       
    input wire div_busy_i,                  
    input wire[4:0] div_reg_waddr_i,

    // to mem
    output reg[31:0] mem_wdata_o,        
    output reg[31:0] mem_raddr_o,    
    output reg[31:0] mem_waddr_o,    
    output wire mem_we_o,                   
    output wire mem_req_o,                  

    // to regs
    output wire[31:0] reg_wdata_o,       
    output wire reg_we_o,                   
    output wire[4:0] reg_waddr_o,   

    // to csr reg
    output reg[31:0] csr_wdata_o,        
    output wire csr_we_o,                   
    output wire[31:0] csr_waddr_o,   

    // to div
    output wire div_start_o,                
    output reg[31:0] div_dividend_o,     
    output reg[31:0] div_divisor_o,      
    output reg[2:0] div_op_o,               
    output reg[4:0] div_reg_waddr_o,

    // to ctrl
    output wire hold_flag_o,                
    output wire jump_flag_o,                
    output wire[31:0] jump_addr_o    
    );

    wire[1:0]          m_raddr_id;
    wire[1:0]          m_waddr_id;
    wire[63:0]           mul_temp;
    wire[63:0]    mul_temp_invert;
    wire[31:0]           sr_shift;
    wire[31:0]          sri_shift;
    wire[31:0]        sr_shift_mk;
    wire[31:0]       sri_shift_mk;
    wire[31:0]    op1_add_op2_res;
    wire[31:0]op1_j_add_op2_j_res;
    wire[31:0]      reg1_data_neg;
    wire[31:0]      reg2_data_neg;
    wire        op1_gt_op2_signed;
    wire      op1_gt_op2_unsigned;
    wire               op1_eq_op2;

    reg[31:0] mul_op1;
    reg[31:0] mul_op2;
     
    wire[6:0] opcode;
    wire[2:0]   fun3;
    wire[6:0]   fun7;
    wire[4:0]     rd;
    wire[4:0]   uimm;

    reg[31:0]  reg_wdata;
    reg      reg_wenable;
    reg[4:0]   reg_waddr;
    reg[31:0]  div_wdata;
    reg      div_wenable;
    reg[4:0]   div_waddr; 
    reg       div_h_flag;
    reg       div_j_flag;
    reg[31:0] div_j_addr;
    reg           h_flag;
    reg           j_flag;
    reg[31:0]     j_addr;
    reg      mem_wenable; 
    reg          mem_req;
    reg        div_start;

    assign opcode=inst_i[6:0];
    assign  fun3=inst_i[14:12];
    assign  fun7=inst_i[31:25];
    assign    rd=inst_i[11:7];
    assign  uimm=inst_i[19:15];

    assign     sr_shift=reg1_rdata_i >> reg2_rdata_i[4:0];
    assign    sri_shift=reg1_rdata_i >> inst_i[24:20];
    assign  sr_shift_mk=32'hffffffff >> reg2_rdata_i[4:0];
    assign sri_shift_mk=32'hffffffff >> inst_i[24:20];

    assign     op1_add_op2_res=op1_i + op2_i;
    assign op1_j_add_op2_j_res=op1_jump_i + op2_jump_i;

    assign reg1_data_neg= ~reg1_rdata_i + 1;
    assign reg2_data_neg= ~reg2_rdata_i + 1;

    assign op1_gt_op2_signed=$signed(op1_i) >= $signed(op2_i);

    assign op1_gt_op2_unsigned= op1_i >= op2_i;
    assign op1_eq_op2=(op1_i == op2_i);

    assign mul_temp=mul_op1 * mul_op2;
    assign mul_temp_invert=~mul_temp + 1;

    assign m_raddr_id=(reg1_rdata_i + {{20{inst_i[31]}}, inst_i[31:20]}) & 2'b11;
    assign m_waddr_id=(reg1_rdata_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]}) & 2'b11;


    assign div_start_o= (int_assert_i == 1'b1)? 1'b0: div_start;

    assign reg_wdata_o= reg_wdata | div_wdata;

    assign reg_we_o=(int_assert_i == 1'b1)? 1'b0: (reg_wenable || div_wenable);
    assign reg_waddr_o= reg_waddr | div_waddr;


    assign mem_we_o =(int_assert_i == 1'b1)? 1'b0: mem_wenable;

    assign mem_req_o =(int_assert_i == 1'b1)? 1'b0: mem_req;

    assign hold_flag_o= h_flag || div_h_flag;
    assign jump_flag_o =j_flag || div_j_flag || ((int_assert_i == 1'b1)? 1'b1: 1'b0);
    assign jump_addr_o =(int_assert_i == 1'b1)? int_addr_i: (j_addr | div_j_addr);

    assign csr_we_o =(int_assert_i == 1'b1)? 1'b0: csr_we_i;
    assign csr_waddr_o=csr_waddr_i;

    always @ (*) begin
        if ((opcode == 7'b0110011) && (fun7 == 7'b0000001)) begin
            case (fun3)
                3'b000, 3'b011: begin
                    mul_op1 = reg1_rdata_i;
                    mul_op2 = reg2_rdata_i;
                end
                3'b010: begin
                    mul_op1 = (reg1_rdata_i[31] == 1'b1)? (reg1_data_neg): reg1_rdata_i;
                    mul_op2 = reg2_rdata_i;
                end
                3'b001: begin
                    mul_op1 = (reg1_rdata_i[31] == 1'b1)? (reg1_data_neg): reg1_rdata_i;
                    mul_op2 = (reg2_rdata_i[31] == 1'b1)? (reg2_data_neg): reg2_rdata_i;
                end
                default: begin
                    mul_op1 = reg1_rdata_i;
                    mul_op2 = reg2_rdata_i;
                end
            endcase
        end 
        else begin
            mul_op1 = reg1_rdata_i;
            mul_op2 = reg2_rdata_i;
        end
    end

    always @ (*) begin//deal div inst
        div_dividend_o = reg1_rdata_i;
        div_divisor_o = reg2_rdata_i;
        div_op_o = fun3;
        div_reg_waddr_o = reg_waddr_i;
        if ((opcode == 7'b0110011) && (fun7 == 7'b0000001)) begin
            div_wenable = 1'b0;
            div_wdata = 32'h0;
            div_waddr = 32'h0;
            case (fun3)
                3'b100, 3'b101, 3'b110, 3'b111: begin
                    div_start = 1'b1;
                    div_j_flag = 1'b1;
                    div_h_flag = 1'b1;
                    div_j_addr = op1_j_add_op2_j_res;
                end
                default: begin
                    div_start = 1'b0;
                    div_j_flag = 1'b0;
                    div_h_flag = 1'b0;
                    div_j_addr = 32'h0;
                end
            endcase
        end 
        else begin
            div_j_flag = 1'b0;
            div_j_addr = 32'h0;
            if (div_busy_i == 1'b1) begin
                div_start = 1'b1;
                div_wenable = 1'b0;
                div_wdata = 32'h0;
                div_waddr = 32'h0;
                div_h_flag = 1'b1;
            end else begin
                div_start = 1'b0;
                div_h_flag = 1'b0;
                if (div_ready_i == 1'b1) begin
                    div_wdata = div_result_i;
                    div_waddr = div_reg_waddr_i;
                    div_wenable = 1'b1;
                end else begin
                    div_wenable = 1'b0;
                    div_wdata = 32'h0;
                    div_waddr = 32'h0;
                end
            end
        end
    end

    always @ (*) begin
        reg_wenable = reg_we_i;
        reg_waddr = reg_waddr_i;
        mem_req = 1'b0;
        csr_wdata_o = 32'h0;

        case (opcode)
            7'b0010011: begin//I_type
                case (fun3)
                    3'b000: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = op1_add_op2_res;
                    end
                    3'b010: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = {32{(~op1_gt_op2_signed)}} & 32'h1;
                    end
                    3'b011: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = {32{(~op1_gt_op2_unsigned)}} & 32'h1;
                    end
                    3'b100: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = op1_i ^ op2_i;
                    end
                    3'b110: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = op1_i | op2_i;
                    end
                    3'b111: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = op1_i & op2_i;
                    end
                    3'b001: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = reg1_rdata_i << inst_i[24:20];
                    end
                    3'b101: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        if (inst_i[30] == 1'b1) begin
                            reg_wdata = (sri_shift & sri_shift_mk) | ({32{reg1_rdata_i[31]}} & (~sri_shift_mk));
                        end else begin
                            reg_wdata = reg1_rdata_i >> inst_i[24:20];
                        end
                    end
                    default: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                    end
                endcase
            end
            7'b0110011: begin
                if ((fun7 == 7'b0000000) || (fun7 == 7'b0100000)) begin
                    case (fun3)
                        3'b000: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            if (inst_i[30] == 1'b0) begin
                                reg_wdata = op1_add_op2_res;
                            end else begin
                                reg_wdata = op1_i - op2_i;
                            end
                        end
                        3'b001: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = op1_i << op2_i[4:0];
                        end
                        3'b010: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = {32{(~op1_gt_op2_signed)}} & 32'h1;
                        end
                        3'b011: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = {32{(~op1_gt_op2_unsigned)}} & 32'h1;
                        end
                        3'b100: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = op1_i ^ op2_i;
                        end
                        3'b101: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            if (inst_i[30] == 1'b1) begin
                                reg_wdata = (sr_shift & sr_shift_mk) | ({32{reg1_rdata_i[31]}} & (~sr_shift_mk));
                            end else begin
                                reg_wdata = reg1_rdata_i >> reg2_rdata_i[4:0];
                            end
                        end
                        3'b110: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = op1_i | op2_i;
                        end
                        3'b111: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = op1_i & op2_i;
                        end
                        default: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = 32'h0;
                        end
                    endcase
                end else if (fun7 == 7'b0000001) begin//M_type
                    case (fun3)
                        3'b000: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = mul_temp[31:0];
                        end
                        3'b001: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = mul_temp[63:32];
                        end
                        3'b011: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            case ({reg1_rdata_i[31], reg2_rdata_i[31]})
                                2'b00: begin
                                    reg_wdata = mul_temp[63:32];
                                end
                                2'b11: begin
                                    reg_wdata = mul_temp[63:32];
                                end
                                2'b10: begin
                                    reg_wdata = mul_temp_invert[63:32];
                                end
                                default: begin
                                    reg_wdata = mul_temp_invert[63:32];
                                end
                            endcase
                        end
                        3'b010: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            if (reg1_rdata_i[31] == 1'b1) begin
                                reg_wdata = mul_temp_invert[63:32];
                            end else begin
                                reg_wdata = mul_temp[63:32];
                            end
                        end
                        default: begin
                            j_flag = 1'b0;
                            h_flag = 1'b0;
                            j_addr = 32'h0;
                            mem_wdata_o = 32'h0;
                            mem_raddr_o = 32'h0;
                            mem_waddr_o = 32'h0;
                            mem_wenable = 1'b0;
                            reg_wdata = 32'h0;
                        end
                    endcase
                end else begin
                    j_flag = 1'b0;
                    h_flag = 1'b0;
                    j_addr = 32'h0;
                    mem_wdata_o = 32'h0;
                    mem_raddr_o = 32'h0;
                    mem_waddr_o = 32'h0;
                    mem_wenable = 1'b0;
                    reg_wdata = 32'h0;
                end
            end
            7'b0000011: begin//L_type
                case (fun3)
                    3'b000: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        mem_req = 1'b1;
                        mem_raddr_o = op1_add_op2_res;
                        case (m_raddr_id)
                            2'b00: begin
                                reg_wdata = {{24{mem_rdata_i[7]}}, mem_rdata_i[7:0]};
                            end
                            2'b01: begin
                                reg_wdata = {{24{mem_rdata_i[15]}}, mem_rdata_i[15:8]};
                            end
                            2'b10: begin
                                reg_wdata = {{24{mem_rdata_i[23]}}, mem_rdata_i[23:16]};
                            end
                            default: begin
                                reg_wdata = {{24{mem_rdata_i[31]}}, mem_rdata_i[31:24]};
                            end
                        endcase
                    end
                    3'b001: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        mem_req = 1'b1;
                        mem_raddr_o = op1_add_op2_res;
                        if (m_raddr_id == 2'b0) begin
                            reg_wdata = {{16{mem_rdata_i[15]}}, mem_rdata_i[15:0]};
                        end else begin
                            reg_wdata = {{16{mem_rdata_i[31]}}, mem_rdata_i[31:16]};
                        end
                    end
                    3'b010: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        mem_req = 1'b1;
                        mem_raddr_o = op1_add_op2_res;
                        reg_wdata = mem_rdata_i;
                    end
                    3'b100: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        mem_req = 1'b1;
                        mem_raddr_o = op1_add_op2_res;
                        case (m_raddr_id)
                            2'b00: begin
                                reg_wdata = {24'h0, mem_rdata_i[7:0]};
                            end
                            2'b01: begin
                                reg_wdata = {24'h0, mem_rdata_i[15:8]};
                            end
                            2'b10: begin
                                reg_wdata = {24'h0, mem_rdata_i[23:16]};
                            end
                            default: begin
                                reg_wdata = {24'h0, mem_rdata_i[31:24]};
                            end
                        endcase
                    end
                    3'b101: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        mem_req = 1'b1;
                        mem_raddr_o = op1_add_op2_res;
                        if (m_raddr_id == 2'b0) begin
                            reg_wdata = {16'h0, mem_rdata_i[15:0]};
                        end else begin
                            reg_wdata = {16'h0, mem_rdata_i[31:16]};
                        end
                    end
                    default: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                    end
                endcase
            end
            7'b0100011: begin//S_type
                case (fun3)
                    3'b000: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        reg_wdata = 32'h0;
                        mem_wenable = 1'b1;
                        mem_req = 1'b1;
                        mem_waddr_o = op1_add_op2_res;
                        mem_raddr_o = op1_add_op2_res;
                        case (m_waddr_id)
                            2'b00: begin
                                mem_wdata_o = {mem_rdata_i[31:8], reg2_rdata_i[7:0]};
                            end
                            2'b01: begin
                                mem_wdata_o = {mem_rdata_i[31:16], reg2_rdata_i[7:0], mem_rdata_i[7:0]};
                            end
                            2'b10: begin
                                mem_wdata_o = {mem_rdata_i[31:24], reg2_rdata_i[7:0], mem_rdata_i[15:0]};
                            end
                            default: begin
                                mem_wdata_o = {reg2_rdata_i[7:0], mem_rdata_i[23:0]};
                            end
                        endcase
                    end
                    3'b001: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        reg_wdata = 32'h0;
                        mem_wenable = 1'b1;
                        mem_req = 1'b1;
                        mem_waddr_o = op1_add_op2_res;
                        mem_raddr_o = op1_add_op2_res;
                        if (m_waddr_id == 2'b00) begin
                            mem_wdata_o = {mem_rdata_i[31:16], reg2_rdata_i[15:0]};
                        end else begin
                            mem_wdata_o = {reg2_rdata_i[15:0], mem_rdata_i[15:0]};
                        end
                    end
                    3'b010: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        reg_wdata = 32'h0;
                        mem_wenable = 1'b1;
                        mem_req = 1'b1;
                        mem_waddr_o = op1_add_op2_res;
                        mem_raddr_o = op1_add_op2_res;
                        mem_wdata_o = reg2_rdata_i;
                    end
                    default: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                    end
                endcase
            end
            7'b1100011: begin//B_type
                case (fun3)
                    3'b000: begin
                        h_flag = 1'b0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                        j_flag = op1_eq_op2 & 1'b1;
                        j_addr = {32{op1_eq_op2}} & op1_j_add_op2_j_res;
                    end
                    3'b001: begin
                        h_flag = 1'b0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                        j_flag = (~op1_eq_op2) & 1'b1;
                        j_addr = {32{(~op1_eq_op2)}} & op1_j_add_op2_j_res;
                    end
                    3'b100: begin
                        h_flag = 1'b0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                        j_flag = (~op1_gt_op2_signed) & 1'b1;
                        j_addr = {32{(~op1_gt_op2_signed)}} & op1_j_add_op2_j_res;
                    end
                    3'b101: begin
                        h_flag = 1'b0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                        j_flag = (op1_gt_op2_signed) & 1'b1;
                        j_addr = {32{(op1_gt_op2_signed)}} & op1_j_add_op2_j_res;
                    end
                    3'b110: begin
                        h_flag = 1'b0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                        j_flag = (~op1_gt_op2_unsigned) & 1'b1;
                        j_addr = {32{(~op1_gt_op2_unsigned)}} & op1_j_add_op2_j_res;
                    end
                    3'b111: begin
                        h_flag = 1'b0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                        j_flag = (op1_gt_op2_unsigned) & 1'b1;
                        j_addr = {32{(op1_gt_op2_unsigned)}} & op1_j_add_op2_j_res;
                    end
                    default: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                    end
                endcase
            end
            7'b1101111, 7'b1100111: begin//jal&jalr
                h_flag = 1'b0;
                mem_wdata_o = 32'h0;
                mem_raddr_o = 32'h0;
                mem_waddr_o = 32'h0;
                mem_wenable = 1'b0;
                j_flag = 1'b1;
                j_addr = op1_j_add_op2_j_res;
                reg_wdata = op1_add_op2_res;
            end
            7'b0110111, 7'b0010111: begin//INST_LUI&INST_AUIPC
                h_flag = 1'b0;
                mem_wdata_o = 32'h0;
                mem_raddr_o = 32'h0;
                mem_waddr_o = 32'h0;
                mem_wenable = 1'b0;
                j_addr = 32'h0;
                j_flag = 1'b0;
                reg_wdata = op1_add_op2_res;
            end
            7'b0000001: begin
                j_flag = 1'b0;
                h_flag = 1'b0;
                j_addr = 32'h0;
                mem_wdata_o = 32'h0;
                mem_raddr_o = 32'h0;
                mem_waddr_o = 32'h0;
                mem_wenable = 1'b0;
                reg_wdata = 32'h0;
            end
            7'b0001111: begin
                h_flag = 1'b0;
                mem_wdata_o = 32'h0;
                mem_raddr_o = 32'h0;
                mem_waddr_o = 32'h0;
                mem_wenable = 1'b0;
                reg_wdata = 32'h0;
                j_flag = 1'b1;
                j_addr = op1_j_add_op2_j_res;
            end
            7'b1110011: begin//csr
                j_flag = 1'b0;
                h_flag = 1'b0;
                j_addr = 32'h0;
                mem_wdata_o = 32'h0;
                mem_raddr_o = 32'h0;
                mem_waddr_o = 32'h0;
                mem_wenable = 1'b0;
                case (fun3)
                    3'b001: begin
                        csr_wdata_o = reg1_rdata_i;
                        reg_wdata = csr_rdata_i;
                    end
                    3'b010: begin
                        csr_wdata_o = reg1_rdata_i | csr_rdata_i;
                        reg_wdata = csr_rdata_i;
                    end
                    3'b011: begin
                        csr_wdata_o = csr_rdata_i & (~reg1_rdata_i);
                        reg_wdata = csr_rdata_i;
                    end
                    3'b101: begin
                        csr_wdata_o = {27'h0, uimm};
                        reg_wdata = csr_rdata_i;
                    end
                    3'b110: begin
                        csr_wdata_o = {27'h0, uimm} | csr_rdata_i;
                        reg_wdata = csr_rdata_i;
                    end
                    3'b111: begin
                        csr_wdata_o = (~{27'h0, uimm}) & csr_rdata_i;
                        reg_wdata = csr_rdata_i;
                    end
                    default: begin
                        j_flag = 1'b0;
                        h_flag = 1'b0;
                        j_addr = 32'h0;
                        mem_wdata_o = 32'h0;
                        mem_raddr_o = 32'h0;
                        mem_waddr_o = 32'h0;
                        mem_wenable = 1'b0;
                        reg_wdata = 32'h0;
                    end
                endcase
            end
            default: begin
                j_flag = 1'b0;
                h_flag = 1'b0;
                j_addr = 32'h0;
                mem_wdata_o = 32'h0;
                mem_raddr_o = 32'h0;
                mem_waddr_o = 32'h0;
                mem_wenable = 1'b0;
                reg_wdata = 32'h0;
            end
        endcase
    end
endmodule
