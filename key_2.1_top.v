/**************************************************************
@File    :   key_2.1_top.v
@Time    :   2025/04/09 10:52:33
@Author  :   liyuanhao 
@EditTool:   VS Code 
@Font    :   UTF-8 
@Function:   ����ģ�飬32ͨ�������˲�
**************************************************************/
module pulse_filter_top (
    input wire         clk         ,
    input wire         rst_n       ,
    input wire [31:0]  pulse_in    , // 32λ��������
    input wire [21:0]  filter_coeff, // 22λ�˲�ϵ��
    output wire [31:0] pulse_out     // 32λ�˲������
);

genvar i; //���ɱ���i������������ѭ��

generate //�ڱ���ʱչ��ѭ��������32��������pulse_filterʵ��
    for (i=0; i<32; i=i+1) begin : gen_filter //ѭ��32�Σ�����32��ʵ��
        pulse_fil #( //ʵ����pulse_filterģ��
            .FILTER_COUNTER_WIDTH(22) //��ʽ���ݲ���(���ü�����λ��Ϊ22),ȷ��ÿ��ʵ���ļ�����λ��Ϊ22λ
        ) u_filter ( //ʵ��������Ϊu_filter
            .clk           (clk)         , //����ʱ���ź�
            .rst_n         (rst_n)       , //���Ӹ�λ�ź�
            .pulse_in      (pulse_in[i]) , //ÿ��ͨ�������˲�
            .filter_coeff  (filter_coeff), //�˲�ϵ��
            .pulse_out     (pulse_out[i])  //�����������
        );
    end
endgenerate

endmodule