`timescale 1ns/1ps

module  test();
//激励信号
    reg        clk       ; // 20MHz时钟
    reg        rst_n     ; // 低电平有效复位
    reg        pulse_in_0; // 脉冲输入引脚0
    reg        pulse_in_1; // 脉冲输入引脚1
    reg        pulse_in_2; // 脉冲输入引脚2
    reg        pulse_in_3; // 脉冲输入引脚3

//输出信号定义
    wire [31:0]  freq_out_0; // 32位频率输出0
    wire [31:0]  freq_out_1; // 32位频率输出1
    wire [31:0]  freq_out_2; // 32位频率输出2
    wire [31:0]  freq_out_3; // 32位频率输出3

//时钟生成
//f=1/T,f=20MHz,T=50ns
/*初始时将clk置为0，然后使用forever循环，每25纳秒将clk取反一次，
这样就生成了周期为50纳秒、频率为20MHz的时钟信号*/
    initial begin
        clk = 0;
        forever #25 clk = ~clk; // 20MHz时钟，周期为50ns
    end

//模块例化
frequency_measurement u_frequency_measurement(
    .clk        (clk        ),
    .rst_n      (rst_n      ),
    .pulse_in_0 (pulse_in_0 ),
    .pulse_in_1 (pulse_in_1 ),
    .pulse_in_2 (pulse_in_2 ),
    .pulse_in_3 (pulse_in_3 ),
    .freq_out_0 (freq_out_0 ),
    .freq_out_1 (freq_out_1 ),
    .freq_out_2 (freq_out_2 ),
    .freq_out_3 (freq_out_3 )
);

//产生激励
initial begin
    //初始化信号
    rst_n = 0;
    pulse_in_0 = 0;
    pulse_in_1 = 0;
    pulse_in_2 = 0;
    pulse_in_3 = 0;

    #200; //复位一段时间

    /*将复位信号rst_n置为1，释放复位。
    使用fork - join语句并行执行4个进程，分别模拟4个不同频率的脉冲输入。
    对于每个进程，使用forever循环，根据不同的频率设置相应的时间间隔，
    然后将对应的脉冲输入信号取反，从而生成不同频率的脉冲信号*/

    //释放复位
    rst_n = 1;

  //模拟不同频率的脉冲输入 频率测量范围为1Hz-200KHz
        fork
            // 脉冲0，频率为100Hz
            begin
                forever begin
                    #5000000 pulse_in_0 = ~pulse_in_0;
                end
            end

            // 脉冲1，频率为1KHz
            begin
                forever begin
                    #500000 pulse_in_1 = ~pulse_in_1;
                end
            end

            // 脉冲2，频率为10KHz
            begin
                forever begin
                    #50000 pulse_in_2 = ~pulse_in_2;
                end
            end
            
            // 脉冲3，频率为100KHz
            begin
                forever begin
                    #5000 pulse_in_3 = ~pulse_in_3;
                end
            end

        join
        #100000000; // 运行一段时间
        $stop;
end

endmodule