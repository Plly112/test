/**************************************************************
@File    :   key_2.v
@Time    :   2025/04/08 16:21:05
@Author  :   liyuanhao 
@EditTool:   VS Code 
@Font    :   UTF-8 
@Function:   数字滤波
             设计一个RTL模块，RTL模块的输入为时钟引脚（20MHz）、复位引脚（低电平有效）、32个脉冲接受引脚和滤波系数值等；
             输出为32个脉冲发送引脚，滤波范围为200ns~200ms,LMXO2-7000HC-4TG144I
**************************************************************/
module pulse_filter (
/**************************************************************
                        端口及模块申明 
**************************************************************/
    input  wire         clk         , //20MHz时钟
    input  wire         rst_n       , //低电平有效复位
    input  wire [31:0]  pulse_in    , //32个脉冲输入
    input  wire [31:0]  filter_coeff, //滤波系数
    output reg  [31:0]  pulse_out     //32个脉冲输出
);

/**************************************************************
                        内部信号定义        
**************************************************************/
    //200ns对应的时钟周期数(20MHz时钟，周期为50ns)
    localparam CLK_CYCLES_200NS = 4;

    //200ms对应的时钟周期数
    localparam CLK_CYCLES_200MS = 4_000_000;

    reg [31:0] counter [31:0]; //32个计数器 32个32位计数器的数组

    integer i; //声明一个整数类型的变量i

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 32; i = i + 1) begin
                counter[i]   <= 32'b0;
                pulse_out[i] <= 1'b0;
            end
        end

        /*当rst_n为高电平时，针对每个输入脉冲：
          若pulse_in[i]为高电平，且计数器的值小于滤波系数和200ms对应的时钟周期数，就对计数器进行加1操作
          若计数器的值大于等于200ns对应的时钟周期数，将pulse_out[i]置为高电平
          若pulse_in[i]为低电平，将计数器和输出信号清零*/
        else begin
            for (i = 0; i < 32; i = i + 1) begin
                if (pulse_in[i]) begin //判断第i个输入脉冲是否为高电平
                    if (counter[i] < CLK_CYCLES_200MS) begin //如果计数器的值小于对应的滤波系数且计数器的值小于200ms对应的时钟周期数
                        counter[i] <= counter[i] + 1; //条件满足，就会将第i个计数器counter[i]的值加1，以此记录脉冲的持续时间
                    end

                    if (counter[i] >= CLK_CYCLES_200NS && counter[i] <= CLK_CYCLES_200MS) begin
                        pulse_out[i] <= 1'b1; //将第i个输出信号置为高电平，表示该输入脉冲经过滤波后有效
                    end

                    else begin
                        pulse_out[i] <= 1'b0; //第i个输出信号置为低电平，表示该输入脉冲结束，输出无效
                    end
                end

                else begin
                    counter[i]   <= 32'b0; //第i个计数器的值清零
                end
            end
        end
    end

endmodule    