/**************************************************************
@File    :   key_2.1_top.v
@Time    :   2025/04/09 10:52:33
@Author  :   liyuanhao 
@EditTool:   VS Code 
@Font    :   UTF-8 
@Function:   顶层模块，32通道并行滤波
**************************************************************/
module pulse_filter_top (
    input wire         clk         ,
    input wire         rst_n       ,
    input wire [31:0]  pulse_in    , // 32位输入脉冲
    input wire [21:0]  filter_coeff, // 22位滤波系数
    output wire [31:0] pulse_out     // 32位滤波后输出
);

genvar i; //生成变量i，仅用于生成循环

generate //在编译时展开循环，生成32个独立的pulse_filter实例
    for (i=0; i<32; i=i+1) begin : gen_filter //循环32次，生成32个实例
        pulse_fil #( //实例化pulse_filter模块
            .FILTER_COUNTER_WIDTH(22) //显式传递参数(设置计数器位宽为22),确保每个实例的计数器位宽为22位
        ) u_filter ( //实例化名称为u_filter
            .clk           (clk)         , //连接时钟信号
            .rst_n         (rst_n)       , //连接复位信号
            .pulse_in      (pulse_in[i]) , //每个通道独立滤波
            .filter_coeff  (filter_coeff), //滤波系数
            .pulse_out     (pulse_out[i])  //输出脉冲连接
        );
    end
endgenerate

endmodule