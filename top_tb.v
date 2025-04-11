`timescale 1ns/1ps

module tb_pulse_filter_top();

reg         clk         ;
reg         rst_n       ;
reg  [31:0] pulse_in    ;
reg  [21:0] filter_coeff;
wire [31:0] pulse_out   ;

pulse_filter_top u_pulse_filter_top(
    .clk          (clk          ),
    .rst_n        (rst_n        ),
    .pulse_in     (pulse_in     ),
    .filter_coeff (filter_coeff ),
    .pulse_out    (pulse_out    )
);

initial begin
    clk = 0;
    forever #25 clk = ~clk;
end

initial begin
    rst_n = 0;
    #100;
    rst_n = 1;
end

initial begin
    pulse_in = 0;
    filter_coeff = 22'd4; //滤波时间 = 4×50ns = 200ns

    #200;
    
    // Test case 1: Pulse width < filter time 测试1：短脉冲（100ns < 200ns，应被滤除）
    pulse_in[0] = 1;
    #100; //保持100ns高电平
    pulse_in[0] = 0;
    #500;
    
    // Test case 2: Pulse width = filter time 测试2：刚好等于滤波时间（200ns，应通过）
    #200;
    pulse_in[0] = 1;
    #200;  //保持200ns高电平
    pulse_in[0] = 0;
    #1000;
    
    // Test case 3: Pulse width > filter time 测试3：长脉冲（300ns > 200ns，应通过）
    #200;
    pulse_in[1] = 1;
    #300; //保持300ns高电平
    pulse_in[1] = 0;
    #1000;
    
    #3000;
    $stop;
end

/*
initial begin
    $dumpfile("tb_pulse_filter_top.vcd"); //保存波形到tb_pulse_filter_top.vcd
    $dumpvars(0, tb_pulse_filter_top); //记录所有信号
end
*/

endmodule