module LCD_Text_Gen (
    input [2:0] state,            // FSM 상태
    input [2:0] current_round,    // 현재 라운드
    input [15:0] total_score,     // 현재 점수
    input is_success,             // 성공 여부 (S_PASS 시 1)

    // LCD로 보낼 데이터 (16글자 * 8비트 = 128비트)
    output reg [127:0] line_1,    
    output reg [127:0] line_2     
);

    // ====================================================
    // 1. 숫자를 ASCII 코드로 변환 (0~9 -> '0'~'9')
    // ====================================================
    wire [7:0] ascii_round;
    wire [7:0] ascii_score_100, ascii_score_10, ascii_score_1;

    // 라운드 변환
    assign ascii_round = {5'd0, current_round} + 8'h30;
    
    // 점수 변환 (100의 자리, 10의 자리, 1의 자리)
    assign ascii_score_100 = ((total_score / 100) % 10) + 8'h30;
    assign ascii_score_10  = ((total_score / 10) % 10)  + 8'h30;
    assign ascii_score_1   = (total_score % 10)         + 8'h30;

    // ====================================================
    // 2. FSM 상태값 정의 (Game_FSM과 동일)
    // ====================================================
    localparam S_IDLE       = 3'd0;
    localparam S_GEN_SEQ    = 3'd1; 
    localparam S_SHOW_SEQ   = 3'd2; 
    localparam S_WAIT_INPUT = 3'd3;
    localparam S_CHECK      = 3'd4; 
    localparam S_PASS       = 3'd5;
    localparam S_FAIL       = 3'd6; 
    localparam S_DONE       = 3'd7;

    // ====================================================
    // 3. LCD 출력 텍스트 생성 로직
    // ====================================================
    always @(*) begin
        // [중요] Latch 방지를 위한 기본 초기화 (모두 공백)
        line_1 = "                "; 
        line_2 = "                ";

        case (state)
            // ---------------------------------------------------------
            // [화면 1] 게임 대기 화면
            // ---------------------------------------------------------
            S_IDLE: begin
                line_1 = "   Game Start   "; 
                line_2 = "                ";
            end

            // ---------------------------------------------------------
            // [화면 2] 게임 플레이 화면 (라운드 / 점수 표시)
            // ★ 수정됨: S_CHECK 상태를 여기에 포함시켰습니다.
            // 정답 확인 대기 시간(0.5초) 동안 점수 화면을 유지하여
            // 결과가 나오기 전에 "Fail..."이 깜빡이는 현상을 막습니다.
            // ---------------------------------------------------------
            S_GEN_SEQ, S_SHOW_SEQ, S_WAIT_INPUT, S_CHECK: begin
                // Line 1: "Lv. 1           "
                line_1[127:96] = "Lv. ";  
                line_1[95:88]  = ascii_round; 

                // Line 2: "Score: 000      "
                line_2[127:72] = "Score: "; 
                line_2[71:64]  = ascii_score_100;
                line_2[63:56]  = ascii_score_10; 
                line_2[55:48]  = ascii_score_1;  
            end

            // ---------------------------------------------------------
            // [화면 3] 라운드 결과 화면 (성공/실패)
            // 이제 결과가 확정된 S_PASS, S_FAIL에서만 문구를 띄웁니다.
            // ---------------------------------------------------------
            S_PASS, S_FAIL: begin
                if (state == S_FAIL) begin
                    // 실패 시
                    line_1 = "     Fail...    ";
                    line_2 = "  Try Again...  ";
                end else begin
                    // 성공 시 (S_PASS)
                    line_1 = "    Success!    ";
                    line_2 = " Next Level...  ";
                end
            end

            // ---------------------------------------------------------
            // [화면 4] 최종 게임 클리어 (모든 라운드 종료)
            // ---------------------------------------------------------
            S_DONE: begin
                line_1 = "  FINAL SCORE   ";
                // Line 2: "  Total: 100    "
                line_2[127:72] = "    Total: ";
                line_2[71:64]  = ascii_score_100;
                line_2[63:56]  = ascii_score_10;
                line_2[55:48]  = ascii_score_1;
            end
            
            // ---------------------------------------------------------
            // 예외 처리
            // ---------------------------------------------------------
            default: begin
                line_1 = "   System Err   ";
                line_2 = "  Check State   ";
            end
        endcase
    end

endmodule