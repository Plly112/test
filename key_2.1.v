/**************************************************************
@File    :   key_2.1.v
@Time    :   2025/04/09 10:31:47
@Author  :   liyuanhao 
@EditTool:   VS Code 
@Font    :   UTF-8 
@Function:   �����˲�ģ��
**************************************************************/
module pulse_fil #(
    parameter FILTER_COUNTER_WIDTH = 22 //���������λ��22λ��֧��200ns~200ms��
)(
    input  wire                             clk         , //20MHzʱ������
    input  wire                             rst_n       , //�͵�ƽ��λ���첽��λ�� 
    input  wire                             pulse_in    , //���������źţ����˲���
    input  wire [FILTER_COUNTER_WIDTH-1:0]  filter_coeff, //�˲�ϵ���������˲�ʱ�䣩
    output reg                              pulse_out     //�˲�����������
);

reg [1:0] state;  //2λ״̬�Ĵ���

localparam IDLE          = 2'b00; //����״̬
localparam COUNTING_UP   = 2'b01; //�������˲�����
localparam COUNTING_DOWN = 2'b10; //�½����˲�����

reg [FILTER_COUNTER_WIDTH-1:0] counter; //������

//����ͬ��(������̬)
reg sync0, sync1, sync_prev; // ����ͬ���Ĵ���

/**************************************************************
                        ����ͬ��         
**************************************************************/
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sync0 <= 1'b0;
        sync1 <= 1'b0;
        sync_prev <= 1'b0;
    end 

    else begin
        sync0 <= pulse_in;  //��һ��ͬ��
        sync1 <= sync0;     //�ڶ���ͬ��
        sync_prev <= sync1; //�洢ǰһ��״̬�����ڱ��ؼ�⣩
    end
end

/**************************************************************
                        ���ؼ��       
**************************************************************/
wire rising_edge = sync1 && !sync_prev;  //�����ؼ�� sync1�� 0��1 ʱ�� 1
wire falling_edge = !sync1 && sync_prev; //�½��ؼ�� sync1�� 1��0 ʱ�� 1

/**************************************************************
                        ״̬��       
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
                    state <= COUNTING_UP;    //��⵽�����أ�����COUNTING_UP
                    counter <= filter_coeff; //��ʼ������ֱ���ﵽ�˲�ϵ��ֵ
                end

                else if (falling_edge) begin
                    state <= COUNTING_DOWN;  //��⵽�½��أ�����COUNTING_DOWN
                    counter <= filter_coeff; //��ʼ������ֱ���ﵽ�˲�ϵ��ֵ
                end
            end
            
            //----------�ߵ�ƽ�˲�
            COUNTING_UP: begin
                if (!sync1) begin
                    state <= IDLE; //���������ǰ��ͣ�����IDLE
                end

                else if (counter == 0) begin
                    pulse_out <= 1'b1; //��������������ߵ�ƽ
                    state <= IDLE;
                end

                else begin
                    counter <= counter - 1;
                end
            end
            
            //----------�͵�ƽ�˲�
            COUNTING_DOWN: begin
                if (sync1) begin
                    state <= IDLE; //���������ǰ��ߣ�����IDLE
                end

                else if (counter == 0) begin
                    pulse_out <= 1'b0; //��������������͵�ƽ
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