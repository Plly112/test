`timescale 1ns / 1ps

module test_2();
//激励信号
    reg         clk         ; //20MHz时钟
    reg         rst_n       ; //低电平有效复位
    reg  [31:0] pulse_in    ; //32个脉冲输入
    reg  [31:0] filter_coeff; //滤波系数

//输出信号定义
    wire [31:0] pulse_out   ; //32个脉冲输出

//模块例化
pulse_filter u_pulse_filter(
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .pulse_in     (pulse_in     ),
    .filter_coeff (filter_coeff ),
    .pulse_out    (pulse_out    )
);

//产生激励
    initial begin
        clk = 0;
        forever #25 clk = ~clk; // 20MHz时钟，周期为50ns
    end

//测试序列
    initial begin
        //初始化信号
        rst_n = 0;
        pulse_in = 32'd0;
        filter_coeff = 32'd10;

        //复位一段时间
        #100;
        rst_n = 1;

        //模拟脉冲输入
        #200;
        pulse_in = 32'h00000001;
        #500;
        pulse_in = 32'd0;

        #5000;
        pulse_in = 32'd0; //模拟脉冲结束

        #10000;
        $stop;
    end

endmodule    