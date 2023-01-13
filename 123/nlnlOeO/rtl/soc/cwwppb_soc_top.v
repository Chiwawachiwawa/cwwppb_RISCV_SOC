module cwwppb_soc_top(

    input wire clk,
    input wire rst,

    output reg over,         
    output reg succ,        

    output wire halted_ind, 

    input wire uart_debug_pin,

    output wire uart_tx_pin, 
    input wire uart_rx_pin, 
    inout wire[1:0] gpio, 

    input wire jtag_TCK,   
    input wire jtag_TMS,   
    input wire jtag_TDI,  
    output wire jtag_TDO,  

    input wire spi_miso,  
    output wire spi_mosi,   
    output wire spi_ss,      
    output wire spi_clk      

    );


    // master 0 interface
    wire[31:0] m0_addr_i;
    wire[31:0] m0_data_i;
    wire[31:0] m0_data_o;
    wire m0_req_i;
    wire m0_we_i;

    // master 1 interface
    wire[31:0] m1_addr_i;
    wire[31:0] m1_data_i;
    wire[31:0] m1_data_o;
    wire m1_req_i;
    wire m1_we_i;

    // master 2 interface
    wire[31:0] m2_addr_i;
    wire[31:0] m2_data_i;
    wire[31:0] m2_data_o;
    wire m2_req_i;
    wire m2_we_i;

    // master 3 interface
    wire[31:0] m3_addr_i;
    wire[31:0] m3_data_i;
    wire[31:0] m3_data_o;
    wire m3_req_i;
    wire m3_we_i;

    // slave 0 interface
    wire[31:0] s0_addr_o;
    wire[31:0] s0_data_o;
    wire[31:0] s0_data_i;
    wire s0_we_o;

    // slave 1 interface
    wire[31:0] s1_addr_o;
    wire[31:0] s1_data_o;
    wire[31:0] s1_data_i;
    wire s1_we_o;

    // slave 2 interface
    wire[31:0] s2_addr_o;
    wire[31:0] s2_data_o;
    wire[31:0] s2_data_i;
    wire s2_we_o;

    // slave 3 interface
    wire[31:0] s3_addr_o;
    wire[31:0] s3_data_o;
    wire[31:0] s3_data_i;
    wire s3_we_o;

    // slave 4 interface
    wire[31:0] s4_addr_o;
    wire[31:0] s4_data_o;
    wire[31:0] s4_data_i;
    wire s4_we_o;

    // slave 5 interface
    wire[31:0] s5_addr_o;
    wire[31:0] s5_data_o;
    wire[31:0] s5_data_i;
    wire s5_we_o;

    // rib
    wire rib_hold_flag_o;

    // jtag
    wire jtag_halt_req_o;
    wire jtag_reset_req_o;
    wire[4:0] jtag_reg_addr_o;//reg addr==5bits
    wire[31:0] jtag_reg_data_o;
    wire jtag_reg_we_o;
    wire[31:0] jtag_reg_data_i;

    // cwwppb
    wire[7:0] int_flag;

    // timer0
    wire timer0_int;

    // gpio
    wire[1:0] io_in;
    wire[31:0] gpio_ctrl;
    wire[31:0] gpio_data;

    assign int_flag = {7'h0, timer0_int};
    assign halted_ind = ~jtag_halt_req_o;//led_tests


    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            over <= 1'b1;
            succ <= 1'b1;
        end 
        else begin
            over <= ~u_cwwppb.u_regs.regs[26];  // when = 1, run over
            succ <= ~u_cwwppb.u_regs.regs[27];  // when = 1, run succ, otherwise fail
        end
    end

    cwwppb u_cwwppb(
        .clk(clk),
        .rst(rst),
        .rib_ex_addr_o(m0_addr_i),
        .rib_ex_data_i(m0_data_o),
        .rib_ex_data_o(m0_data_i),
        .rib_ex_req_o(m0_req_i),
        .rib_ex_we_o(m0_we_i),

        .rib_pc_addr_o(m1_addr_i),
        .rib_pc_data_i(m1_data_o),

        .jtag_reg_addr_i(jtag_reg_addr_o),
        .jtag_reg_data_i(jtag_reg_data_o),
        .jtag_reg_we_i(jtag_reg_we_o),
        .jtag_reg_data_o(jtag_reg_data_i),

        .rib_hold_flag_i(rib_hold_flag_o),
        .jtag_halt_flag_i(jtag_halt_req_o),
        .jtag_reset_flag_i(jtag_reset_req_o),

        .int_i(int_flag)
    );


    rom u_rom(
        .clk(clk),
        .rst(rst),
        .we_i(s0_we_o),
        .addr_i(s0_addr_o),
        .data_i(s0_data_o),
        .data_o(s0_data_i)
    );

    ram u_ram(
        .clk(clk),
        .rst(rst),
        .we_i(s1_we_o),
        .addr_i(s1_addr_o),
        .data_i(s1_data_o),
        .data_o(s1_data_i)
    );

    timer timer_0(
        .clk(clk),
        .rst(rst),
        .data_i(s2_data_o),
        .addr_i(s2_addr_o),
        .we_i(s2_we_o),
        .data_o(s2_data_i),
        .int_sig_o(timer0_int)
    );

    uart uart_0(
        .clk(clk),
        .rst(rst),
        .we_i(s3_we_o),
        .addr_i(s3_addr_o),
        .data_i(s3_data_o),
        .data_o(s3_data_i),
        .tx_pin(uart_tx_pin),
        .rx_pin(uart_rx_pin)
    );

    // io0
    assign gpio[0] = (gpio_ctrl[1:0] == 2'b01)? gpio_data[0]: 1'bz;
    assign io_in[0] = gpio[0];
    // io1
    assign gpio[1] = (gpio_ctrl[3:2] == 2'b01)? gpio_data[1]: 1'bz;
    assign io_in[1] = gpio[1];

    gpio gpio_0(
        .clk(clk),
        .rst(rst),
        .we_i(s4_we_o),
        .addr_i(s4_addr_o),
        .data_i(s4_data_o),
        .data_o(s4_data_i),
        .io_pin_i(io_in),
        .reg_ctrl(gpio_ctrl),
        .reg_data(gpio_data)
    );

    spi spi_0(
        .clk(clk),
        .rst(rst),
        .data_i(s5_data_o),
        .addr_i(s5_addr_o),
        .we_i(s5_we_o),
        .data_o(s5_data_i),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_ss(spi_ss),
        .spi_clk(spi_clk)
    );

    rib u_rib(
        .clk(clk),
        .rst(rst),

        // master 0 interface
        .m0_addr_i(m0_addr_i),
        .m0_data_i(m0_data_i),
        .m0_data_o(m0_data_o),
        .m0_req_i(m0_req_i),
        .m0_we_i(m0_we_i),

        // master 1 interface
        .m1_addr_i(m1_addr_i),
        .m1_data_i(32'h0),
        .m1_data_o(m1_data_o),
        .m1_req_i(1'b1),
        .m1_we_i(1'b0),

        // master 2 interface
        .m2_addr_i(m2_addr_i),
        .m2_data_i(m2_data_i),
        .m2_data_o(m2_data_o),
        .m2_req_i(m2_req_i),
        .m2_we_i(m2_we_i),

        // master 3 interface
        .m3_addr_i(m3_addr_i),
        .m3_data_i(m3_data_i),
        .m3_data_o(m3_data_o),
        .m3_req_i(m3_req_i),
        .m3_we_i(m3_we_i),

        // slave 0 interface
        .s0_addr_o(s0_addr_o),
        .s0_data_o(s0_data_o),
        .s0_data_i(s0_data_i),
        .s0_we_o(s0_we_o),

        // slave 1 interface
        .s1_addr_o(s1_addr_o),
        .s1_data_o(s1_data_o),
        .s1_data_i(s1_data_i),
        .s1_we_o(s1_we_o),

        // slave 2 interface
        .s2_addr_o(s2_addr_o),
        .s2_data_o(s2_data_o),
        .s2_data_i(s2_data_i),
        .s2_we_o(s2_we_o),

        // slave 3 interface
        .s3_addr_o(s3_addr_o),
        .s3_data_o(s3_data_o),
        .s3_data_i(s3_data_i),
        .s3_we_o(s3_we_o),

        // slave 4 interface
        .s4_addr_o(s4_addr_o),
        .s4_data_o(s4_data_o),
        .s4_data_i(s4_data_i),
        .s4_we_o(s4_we_o),

        // slave 5 interface
        .s5_addr_o(s5_addr_o),
        .s5_data_o(s5_data_o),
        .s5_data_i(s5_data_i),
        .s5_we_o(s5_we_o),

        .hold_flag_o(rib_hold_flag_o)
    );

    uart_debug u_uart_debug(
        .clk(clk),
        .rst(rst),
        .debug_en_i(uart_debug_pin),
        .req_o(m3_req_i),
        .mem_we_o(m3_we_i),
        .mem_addr_o(m3_addr_i),
        .mem_wdata_o(m3_data_i),
        .mem_rdata_i(m3_data_o)
    );

    jtag_top #(
        .DMI_ADDR_BITS(6),
        .DMI_DATA_BITS(32),
        .DMI_OP_BITS(2)
    ) u_jtag_top(
        .clk(clk),
        .jtag_rst_n(rst),
        .jtag_pin_TCK(jtag_TCK),
        .jtag_pin_TMS(jtag_TMS),
        .jtag_pin_TDI(jtag_TDI),
        .jtag_pin_TDO(jtag_TDO),
        .reg_we_o(jtag_reg_we_o),
        .reg_addr_o(jtag_reg_addr_o),
        .reg_wdata_o(jtag_reg_data_o),
        .reg_rdata_i(jtag_reg_data_i),
        .mem_we_o(m2_we_i),
        .mem_addr_o(m2_addr_i),
        .mem_wdata_o(m2_data_i),
        .mem_rdata_i(m2_data_o),
        .op_req_o(m2_req_i),
        .halt_req_o(jtag_halt_req_o),
        .reset_req_o(jtag_reset_req_o)
    );

endmodule
