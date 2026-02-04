module Reg3_Game_State (
    input wire clk,
    input wire rst_n,
    input wire round_clear, 
    input wire game_fail,   
    input wire game_reset,  

    output reg [2:0] current_round,
    output reg [3:0] difficulty_k,
    output reg [15:0] total_score
);
    reg game_fail_prev;
    wire game_fail_posedge;
    assign game_fail_posedge = game_fail & ~game_fail_prev;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) game_fail_prev <= 0;
        else        game_fail_prev <= game_fail;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_round <= 3'd1;
            total_score <= 16'd0;
            difficulty_k <= 4'd4; 
        end 
        else if (game_reset) begin
            current_round <= 3'd1;
            total_score <= 16'd0;
            difficulty_k <= 4'd4;
        end
        else begin
            // 1. 정답인 경우 (라운드 클리어)
            if (round_clear) begin
                // 다음 라운드 준비
                if (current_round <= 5) begin
                    current_round <= current_round + 1;
                    difficulty_k <= difficulty_k + 1; 
                end
                
                // ★★★ [점수 계산 로직 수정됨] ★★★
                // 현재 라운드(current_round)가 몇 단계인지에 따라 점수를 차등 지급
                // (Non-blocking 할당이므로 여기서 current_round는 '방금 깬 라운드'를 의미함)
                case (current_round)
                    3'd1: total_score <= total_score + 16'd10; // 1단계: +10
                    3'd2: total_score <= total_score + 16'd15; // 2단계: +15
                    3'd3: total_score <= total_score + 16'd20; // 3단계: +20
                    3'd4: total_score <= total_score + 16'd25; // 4단계: +25
                    3'd5: total_score <= total_score + 16'd30; // 5단계: +30
                    default: total_score <= total_score + 16'd10;
                endcase
            end
            
            // 2. 오답인 경우 (게임 실패)
            else if (game_fail_posedge) begin
                if (current_round <= 5) begin
                    current_round <= current_round + 1;
                    difficulty_k <= difficulty_k + 1; 
                end
                // 점수 변경 없음
            end
        end
    end
endmodule
