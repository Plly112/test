`timescale 1ns / 1ps

module key3_tb();

    reg               clk_20m      ;
    reg               rst_n        ;
    reg        [31:0] pulse_in     ;
    reg signed [15:0] filter_coeff ;
    reg               coeff_load   ;
    wire       [31:0] pulse_out    ;

    // 实例化被测试模块
    key3_test u_key3_test(
      .clk_20m     (clk_20m     ), 
      .rst_n       (rst_n       ), 
      .pulse_in    (pulse_in    ), 
      .filter_coeff(filter_coeff),
      .coeff_load  (coeff_load  ),
      .pulse_out   (pulse_out   )
    );

    // 时钟生成
    initial begin
        clk_20m = 0;
        forever #25 clk_20m = ~clk_20m; // 20MHz时钟
    end

    // 测试序列
    initial begin
        // 初始化信号
        rst_n = 0;
        pulse_in = 32'd0;
        filter_coeff = 16'd0;
        coeff_load = 1'b0;
        #100;
        rst_n = 1;

        // 加载滤波系数
        coeff_load = 1'b1;
        #50; filter_coeff = 16'd1;
        #50; filter_coeff = 16'd1;
        #50; filter_coeff = 16'd1;
        #50; filter_coeff = 16'd1;
        #50; filter_coeff = 16'd1;
        #50; filter_coeff = 16'd1;
        #50; filter_coeff = 16'd1;
        #50; filter_coeff = 16'd1;
        coeff_load = 1'b0;

        // 模拟输入脉冲信号
        pulse_in = 32'hAAAAAAAA;
        #100000;

        #100000; // 等待一段时间
        $finish;
    end

endmodule    