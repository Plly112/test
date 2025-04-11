/**************************************************************
@File    :   key_2.1.v
@Time    :   2025/04/09 10:31:47
@Author  :   liyuanhao 
@EditTool:   VS Code 
@Font    :   UTF-8 
@Function:   核心滤波模块
**************************************************************/
module pulse_fil #(
    parameter FILTER_COUNTER_WIDTH = 22 //定义计数器位宽（22位可支持200ns~200ms）
)(
    input  wire                             clk         , //20MHz时钟输入
    input  wire                             rst_n       , //低电平复位（异步复位） 
    input  wire                             pulse_in    , //输入脉冲信号（待滤波）
    input  wire [FILTER_COUNTER_WIDTH-1:0]  filter_coeff, //滤波系数（决定滤波时间）
    output reg                              pulse_out     //滤波后的输出脉冲
);

reg [1:0] state;  //2位状态寄存器

localparam IDLE          = 2'b00; //空闲状态
localparam COUNTING_UP   = 2'b01; //上升沿滤波计数
localparam COUNTING_DOWN = 2'b10; //下降沿滤波计数

reg [FILTER_COUNTER_WIDTH-1:0] counter; //计数器

//输入同步(防亚稳态)
reg sync0, sync1, sync_prev; // 三级同步寄存器

/**************************************************************
                        三级同步         
**************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync0 <= 1'b0;
        sync1 <= 1'b0;
        sync_prev <= 1'b0;
    end 

    else begin
        sync0 <= pulse_in;  //第一级同步
        sync1 <= sync0;     //第二级同步
        sync_prev <= sync1; //存储前一个状态（用于边沿检测）
    end
end

/**************************************************************
                        边沿检测       
**************************************************************/
wire rising_edge = sync1 && !sync_prev;  //上升沿检测 sync1从 0→1 时置 1
wire falling_edge = !sync1 && sync_prev; //下降沿检测 sync1从 1→0 时置 1

/**************************************************************
                        状态机       
**************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        counter <= 0;
        pulse_out <= 1'b0;
    end

    else begin
        case (state)
            IDLE: begin
                if (rising_edge) begin
                    state <= COUNTING_UP;    //检测到上升沿，进入COUNTING_UP
                    counter <= filter_coeff; //开始计数，直到达到滤波系数值
                end

                else if (falling_edge) begin
                    state <= COUNTING_DOWN;  //检测到下降沿，进入COUNTING_DOWN
                    counter <= filter_coeff; //开始计数，直到达到滤波系数值
                end
            end
            
            //----------高电平滤波
            COUNTING_UP: begin
                if (!sync1) begin
                    state <= IDLE; //如果输入提前变低，返回IDLE
                end

                else if (counter == 0) begin
                    pulse_out <= 1'b1; //计数结束，输出高电平
                    state <= IDLE;
                end

                else begin
                    counter <= counter - 1;
                end
            end
            
            //----------低电平滤波
            COUNTING_DOWN: begin
                if (sync1) begin
                    state <= IDLE; //如果输入提前变高，返回IDLE
                end

                else if (counter == 0) begin
                    pulse_out <= 1'b0; //计数结束，输出低电平
                    state <= IDLE;
                end

                else begin
                    counter <= counter - 1;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule