module Reg2_Input_Sync (
    input clk,
    input rst_n,
    input [7:0] btn_clean,
    input enable_input,
    input start_clear,         
    input [3:0] difficulty_k, 
    input time_up,
    output reg [3:0] current_key,
    output reg key_valid,
    output reg [31:0] user_seq,
    output reg input_done,
    output reg [3:0] input_cnt
);

    reg [7:0] btn_prev;
    wire [7:0] btn_posedge;
    assign btn_posedge = btn_clean & ~btn_prev;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) btn_prev <= 8'd0;
        else        btn_prev <= btn_clean;
    end

    // Enable 상승 엣지 감지
    reg enable_prev;
    wire enable_posedge;
    assign enable_posedge = enable_input & ~enable_prev;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) enable_prev <= 1'b0;
        else        enable_prev <= enable_input;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_key <= 4'd0; key_valid <= 1'b0;
            user_seq <= 32'd0; input_done <= 1'b0; input_cnt <= 4'd0;
        end else begin
            key_valid <= 1'b0;
            
            // 라운드 시작 또는 입력 모드 진입 시 초기화
            if (start_clear || enable_posedge) begin
                input_cnt <= 4'd0; 
                input_done <= 1'b0;
                user_seq <= 32'd0; 
                current_key <= 4'd0;
            end 
            else if (enable_input && !time_up && !input_done) begin
                // [중요] 아직 입력 개수를 다 채우지 않았을 때만 버튼 인식
                if ((btn_posedge != 8'd0) && (input_cnt < difficulty_k)) begin
                    key_valid <= 1'b1;
                    
                    // 버튼 값 저장
                    if (btn_posedge[0]) save_sequence(input_cnt, 4'd1);
                    else if (btn_posedge[1]) save_sequence(input_cnt, 4'd2);
                    else if (btn_posedge[2]) save_sequence(input_cnt, 4'd3);
                    else if (btn_posedge[3]) save_sequence(input_cnt, 4'd4);
                    else if (btn_posedge[4]) save_sequence(input_cnt, 4'd5);
                    else if (btn_posedge[5]) save_sequence(input_cnt, 4'd6);
                    else if (btn_posedge[6]) save_sequence(input_cnt, 4'd7);
                    else if (btn_posedge[7]) save_sequence(input_cnt, 4'd8);
                    
                    // 카운트 증가
                    input_cnt <= input_cnt + 1;

                    // [핵심 수정] 마지막 입력이었다면 즉시 완료 처리!
                    // (현재 입력으로 개수가 difficulty_k와 같아지면 끝)
                    if (input_cnt + 1 == difficulty_k) begin
                        input_done <= 1'b1; 
                    end
                end
            end 
            // 만약 입력 안 하고 시간만 다 흘렀다면 타임아웃 처리
            else if (enable_input && time_up) begin
                input_done <= 1'b1; // 이 경우 FSM에서 Fail로 처리됨
            end 
            else if (!enable_input) begin
                 input_done <= 1'b0;
            end
        end
    end

    task save_sequence;
        input [3:0] idx;
        input [3:0] val;
        begin
            case (idx)
                4'd0: user_seq[3:0]   <= val;
                4'd1: user_seq[7:4]   <= val;
                4'd2: user_seq[11:8]  <= val;
                4'd3: user_seq[15:12] <= val;
                4'd4: user_seq[19:16] <= val;
                4'd5: user_seq[23:20] <= val;
                4'd6: user_seq[27:24] <= val;
                4'd7: user_seq[31:28] <= val;
            endcase
        end
    endtask
endmodule