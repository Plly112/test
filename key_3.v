/**************************************************************
@File    :   key_3.v
@Time    :   2025/04/11 15:20:04
@Author  :   liyuanhao 
@EditTool:   VS Code 
@Font    :   UTF-8 
@Function:   频率检测
             采用等精度测量法实现频率检测。通过20MHz标准时钟生成一个固定的闸门时间，
             在该闸门时间内同时对输入脉冲信号的周期数和标准时钟的周期数进行计数，然后根据计数结果计算输入脉冲信号的频率。
**************************************************************/
module frequency(
/**************************************************************
                        端口及模块申明            
**************************************************************/
    input  wire       clk       , //20MHz时钟
    input  wire       rst_n     , //低电平有效复位
    input  wire       pulse_in_0, //脉冲接受引脚0
    input  wire       pulse_in_1, //脉冲接受引脚1
    input  wire       pulse_in_2, //脉冲接受引脚2
    input  wire       pulse_in_3, //脉冲接受引脚3
    output reg [31:0] freq_out_0, //32bit的脉冲频率值0
    output reg [31:0] freq_out_1, //32bit的脉冲频率值1
    output reg [31:0] freq_out_2, //32bit的脉冲频率值2
    output reg [31:0] freq_out_3  //32bit的脉冲频率值3
);

/**************************************************************
                            内部参数定义      
**************************************************************/
    //定义固定的闸门时间计数
    localparam GATE_TIME = 200000; // 20MHz时钟下，10ms的闸门时间

    reg [17:0] gate_counter; //对时钟周期进行计数，以生成闸门时间
    reg        gate_enable ; //作为闸门使能信号，用于控制计数的开始和停止

    //标准时钟计数器
    reg [31:0] std_clk_counter; //记录闸门时间内的时钟周期数

    //脉冲计数器
    reg [31:0] pulse_counter_0;
    reg [31:0] pulse_counter_1;
    reg [31:0] pulse_counter_2;
    reg [31:0] pulse_counter_3;

/**************************************************************
                        生成固定的闸门时间       
**************************************************************/
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gate_counter <= 18'd0;
            gate_enable <= 1'b0;
        end 
        
        else begin
            if (gate_counter < GATE_TIME - 1) begin
                gate_counter <= gate_counter + 1;
                gate_enable <= 1'b1;
            end 
            
            else begin
                gate_counter <= 18'd0;
                gate_enable <= 1'b0;
            end
        end
    end

/**************************************************************
                        标准时钟计数         
**************************************************************/
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            std_clk_counter <= 32'd0;
        end 
        
        else if (gate_enable) begin
            std_clk_counter <= std_clk_counter + 1;
        end 
        
        else if (gate_enable == 1'b0) begin
            //保持计数结果直到下一次闸门开启
            std_clk_counter <= std_clk_counter;
        end
    end

/**************************************************************
                        脉冲计数        
**************************************************************/
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_counter_0 <= 32'd0;
        end 
        
        else if (gate_enable) begin //gate_enable为高电平，表明闸门开启
            if (pulse_in_0) begin //此时pulse_in_0为高电平（即检测到一个脉冲）
                pulse_counter_0 <= pulse_counter_0 + 1; //则 pulse_counter_0 加 1
            end
        end 
        
        else if (gate_enable == 1'b0) begin
            //保持计数结果直到下一次闸门开启
            pulse_counter_0 <= pulse_counter_0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_counter_1 <= 32'd0;
        end 
        
        else if (gate_enable) begin
            if (pulse_in_1) begin
                pulse_counter_1 <= pulse_counter_1 + 1;
            end
        end 
        
        else if (gate_enable == 1'b0) begin
            //保持计数结果直到下一次闸门开启
            pulse_counter_1 <= pulse_counter_1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_counter_2 <= 32'd0;
        end
        
        else if (gate_enable) begin
            if (pulse_in_2) begin
                pulse_counter_2 <= pulse_counter_2 + 1;
            end
        end 
        
        else if (gate_enable == 1'b0) begin
            //保持计数结果直到下一次闸门开启
            pulse_counter_2 <= pulse_counter_2;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_counter_3 <= 32'd0;
        end 
        
        else if (gate_enable) begin
            if (pulse_in_3) begin
                pulse_counter_3 <= pulse_counter_3 + 1;
            end
        end 
        
        else if (gate_enable == 1'b0) begin
            //保持计数结果直到下一次闸门开启
            pulse_counter_3 <= pulse_counter_3;
        end
    end

/**************************************************************
                        计算频率        
**************************************************************/
//频率测量的基本原理是在一个固定的闸门时间内，统计输入脉冲的数量以及标准时钟的脉冲数量，然后通过这两个计数值来计算输入信号的频率
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            freq_out_0 <= 32'd0;
        end 
        
        else if (gate_enable == 1'b0 && gate_counter == 18'd0) begin //gate_enable为低电平且gate_counter为0，表明闸门关闭且一个测量周期结束
                                                                     //gate_counter回到0时，说明一个完整的闸门时间周期结束
            if (std_clk_counter > 0) begin
                freq_out_0 <= (pulse_counter_0 * 20000000) / std_clk_counter;
            end 
            
            else begin
                freq_out_0 <= 32'd0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            freq_out_1 <= 32'd0;
        end 
        
        else if (gate_enable == 1'b0 && gate_counter == 18'd0) begin
            if (std_clk_counter > 0) begin
                freq_out_1 <= (pulse_counter_1 * 20000000) / std_clk_counter;
            end 
            
            else begin
                freq_out_1 <= 32'd0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            freq_out_2 <= 32'd0;
        end 
        
        else if (gate_enable == 1'b0 && gate_counter == 18'd0) begin
            if (std_clk_counter > 0) begin
                freq_out_2 <= (pulse_counter_2 * 20000000) / std_clk_counter;
            end 
            
            else begin
                freq_out_2 <= 32'd0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            freq_out_3 <= 32'd0;
        end 
        
        else if (gate_enable == 1'b0 && gate_counter == 18'd0) begin
            if (std_clk_counter > 0) begin
                freq_out_3 <= (pulse_counter_3 * 20000000) / std_clk_counter;
            end 
            
            else begin
                freq_out_3 <= 32'd0;
            end
        end
    end

endmodule