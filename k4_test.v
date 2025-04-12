`timescale 1ns / 1ps

module k4_test();

    reg         clk               ;
    reg         rst_n             ;
    reg  [31:0] pulse_in          ;
    reg  [15:0] filter_coeff [9:0];  //假设滤波器阶数为10
    wire [31:0] pulse_out         ;

    //实例化被测试模块
    key4_test u_key4_test(
       .clk      (clk      ),
       .rst_n    (rst_n    ),
       .pulse_in (pulse_in ),
       .pulse_out(pulse_out)
    );

    //连接滤波系数
    genvar k;
    generate
        for (k = 0; k < 10; k = k + 1) begin : filter_coeff_conn
            assign u_key4_test.filter_coeff_gen[k].filter_coeff_wire = filter_coeff[k];
        end
    endgenerate

/*
借助generate语句，会生成10条assign语句，分别把filter_coeff数组的每个元素和被测试模块中对应的filter_coeff_wire信号连接起来。
例如，当k=0时，会把filter_coeff[0]的值赋给 u_key4_test.filter_coeff_gen[0].filter_coeff_wire；
当k=1时，会把filter_coeff[1]u_key4_test.filter_coeff_gen[1].filter_coeff_wire，依此类推
*/

    //时钟生成
    initial begin
        clk = 0;
        forever #25 clk = ~clk;  //20MHz时钟，周期为50ns
    end

    //初始化信号
    initial begin
        //初始化复位信号
        rst_n = 0;
        #100;
        rst_n = 1;

        //初始化滤波系数
        filter_coeff[0] = 16'd1;
        filter_coeff[1] = 16'd2;
        filter_coeff[2] = 16'd3;
        filter_coeff[3] = 16'd4;
        filter_coeff[4] = 16'd5;
        filter_coeff[5] = 16'd6;
        filter_coeff[6] = 16'd7;
        filter_coeff[7] = 16'd8;
        filter_coeff[8] = 16'd9;
        filter_coeff[9] = 16'd10;

        //初始化脉冲输入
        pulse_in = 32'h12345678;

        #1000;
        $stop;
    end

endmodule    