/**************************************************************
@File    :   key4_test.v
@Time    :   2025/04/12 10:29:19
@Author  :   liyuanhao 
@EditTool:   VS Code 
@Font    :   UTF-8 
@Function:   数字滤波
             采用有限长单位脉冲响应（FIR）滤波器实现数字滤波功能
             根据输入的滤波系数值，对32个脉冲输入信号进行卷积运算，得到滤波后的输出信号
**************************************************************/
module key4_test(
/**************************************************************
                        端口及模块申明          
**************************************************************/
    input  wire        clk      ,
    input  wire        rst_n    ,
    input  wire [31:0] pulse_in ,
    output reg  [31:0] pulse_out
);
/**************************************************************
                        内部参数定义          
**************************************************************/
    parameter N = 10;  //滤波器阶数

    wire [15:0] filter_coeff [N-1:0]; //存储FIR滤波器的系数

    integer i, j;

    reg [31:0] shift_reg [N-1:0]; //作为移位寄存器，用于存储输入脉冲信号的历史值

/**************************************************************
                        生成连接信号      
**************************************************************/
    genvar k;
    generate
        for (k = 0; k < N; k = k + 1) begin : filter_coeff_gen
            wire [15:0] filter_coeff_wire;
            assign filter_coeff[k] = filter_coeff_wire;
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < N; i = i + 1) begin
                shift_reg[i] <= 32'b0;
            end
            pulse_out <= 32'b0;
        end 
        
        else begin
            //移位寄存器更新
            for (i = N - 1; i > 0; i = i - 1) begin
                shift_reg[i] <= shift_reg[i - 1]; //将移位寄存器数组中的元素依次向后移动一位
            end                                   //把shift_reg[i - 1]的值赋给shift_reg[i]，相当于把移位寄存器数组中的元素依次向后移动一位

            shift_reg[0] <= pulse_in; //将当前输入的脉冲信号pulse_in存入移位寄存器的第一个位置

/*
假设N等于3，shift_reg数组的初始值为[1, 2, 3]，输入脉冲信号pulse_in为4。在时钟上升沿到来时，
经过for循环和shift_reg[0]<=pulse_in; 语句的执行，shift_reg数组的值会变为[4, 1, 2]。
这样，shift_reg数组就存储了最新的输入脉冲信号以及前两个历史输入值。
*/

            //FIR滤波卷积运算
            pulse_out <= 32'b0;
            for (j = 0; j < N; j = j + 1) begin
                pulse_out <= pulse_out + (shift_reg[j] * filter_coeff[j]); //将移位寄存器中的历史输入值与对应的滤波系数相乘并累加，得到最终的滤波输出
            end
        end
    end

endmodule    