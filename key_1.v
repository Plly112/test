/**************************************************************
@File    :   key_1.v
@Time    :   2025/04/08 09:59:51
@Author  :   liyuanhao 
@EditTool:   VS Code 
@Font    :   UTF-8 
@Function:   频率测量
             设计一个RTL模块，RTL模块的输入为时钟引脚（20MHz）、复位引脚（低电平有效）、4个脉冲接受引脚；
             输出为4个相对应的32bit的脉冲频率值，频率测量范围为1Hz~200KHz,LMXO2-7000HC-4TG144I
**************************************************************/

module frequency_measurement (
/**************************************************************
                    端口及模块申明    
**************************************************************/
    input   wire        clk       , // 20MHz时钟
    input   wire        rst_n     , // 低电平有效复位

    //4个脉冲接受引脚
    input   wire        pulse_in_0, // 脉冲输入引脚0
    input   wire        pulse_in_1, // 脉冲输入引脚1
    input   wire        pulse_in_2, // 脉冲输入引脚2
    input   wire        pulse_in_3, // 脉冲输入引脚3

    //输出为4个相对应的32bit的脉冲频率值
    output  reg [31:0]  freq_out_0, // 32位频率输出0
    output  reg [31:0]  freq_out_1, // 32位频率输出1
    output  reg [31:0]  freq_out_2, // 32位频率输出2
    output  reg [31:0]  freq_out_3  // 32位频率输出3
);

/**************************************************************
                        内部信号定义          
**************************************************************/
    reg [31:0] counter_0  ;   // 计数器0
    reg [31:0] counter_1  ;   // 计数器1
    reg [31:0] counter_2  ;   // 计数器2
    reg [31:0] counter_3  ;   // 计数器3

    reg [31:0] sample_count;  // 采样计数器

    localparam SAMPLE_TIME = 20_000_000; // 采样时间为1s(20MHz时钟，20M个周期) 20_000_000/1 = 20_000_000

// 异步复位,同步逻辑
//当rst_n为低电平时，将所有计数器和频率输出信号都清零，同时将采样计数器也清零，使模块恢复到初始状态
always @(posedge clk or negedge rst_n)begin
    if (!rst_n) begin
        counter_0 <= 32'b0;
        counter_1 <= 32'b0;
        counter_2 <= 32'b0;
        counter_3 <= 32'b0;

        freq_out_0 <= 32'b0;
        freq_out_1 <= 32'b0;
        freq_out_2 <= 32'b0;
        freq_out_3 <= 32'b0;

        sample_count <= 32'b0;
    end
        
    else begin
        //--------采样计数器--------//
        /*在复位信号无效时，对采样计数器sample_count进行操作。
        如果sample_count小于SAMPLE_TIME - 1，则将sample_count加1；
        当sample_count达到SAMPLE_TIME - 1时，说明1秒的采样时间结束，将sample_count清零，
        同时将每个计数器的值赋给对应的频率输出信号，并将计数器清零，为下一次采样做准备*/
        if (sample_count < SAMPLE_TIME - 1) begin
            sample_count <= sample_count + 1;
        end 
            
        else begin
            sample_count <= 32'b0;

            //-----更新频率输出
            freq_out_0 <= counter_0;
            counter_0 <= 32'b0;

            freq_out_1 <= counter_1;
            counter_1 <= 32'b0;

            freq_out_2 <= counter_2;
            counter_2 <= 32'b0;

            freq_out_3 <= counter_3;
            counter_3 <= 32'b0;
        end

        //--------脉冲计数器--------//
        /*每个时钟上升沿检查4个脉冲输入信号。
        如果某个脉冲输入信号为高电平，说明检测到一个脉冲，将对应的计数器加 1。
        这样在一个采样周期内，计数器记录的就是该脉冲输入信号的脉冲数，也就是该信号的频率(因为采样时间是1秒)*/
        if (pulse_in_0) begin
            counter_0 <= counter_0 + 1;
        end

        if (pulse_in_1) begin
            counter_1 <= counter_1 + 1;
        end

        if (pulse_in_2) begin
            counter_2 <= counter_2 + 1;
        end

        if (pulse_in_3) begin
            counter_3 <= counter_3 + 1;
        end
    end
end

endmodule    