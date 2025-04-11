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
    filter_coeff = 22'd4; //�˲�ʱ�� = 4��50ns = 200ns

    #200;
    
    // Test case 1: Pulse width < filter time ����1�������壨100ns < 200ns��Ӧ���˳���
    pulse_in[0] = 1;
    #100; //����100ns�ߵ�ƽ
    pulse_in[0] = 0;
    #500;
    
    // Test case 2: Pulse width = filter time ����2���պõ����˲�ʱ�䣨200ns��Ӧͨ����
    #200;
    pulse_in[0] = 1;
    #200;  //����200ns�ߵ�ƽ
    pulse_in[0] = 0;
    #1000;
    
    // Test case 3: Pulse width > filter time ����3�������壨300ns > 200ns��Ӧͨ����
    #200;
    pulse_in[1] = 1;
    #300; //����300ns�ߵ�ƽ
    pulse_in[1] = 0;
    #1000;
    
    #3000;
    $stop;
end

/*
initial begin
    $dumpfile("tb_pulse_filter_top.vcd"); //���沨�ε�tb_pulse_filter_top.vcd
    $dumpvars(0, tb_pulse_filter_top); //��¼�����ź�
end
*/

endmodule