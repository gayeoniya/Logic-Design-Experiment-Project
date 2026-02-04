module LCD_Display_Controller (
    input wire clk,             // 50MHz Clock
    input wire rst_n,
    input wire [127:0] line_1,  // LCD 첫째 줄 데이터 (16글자)
    input wire [127:0] line_2,  // LCD 둘째 줄 데이터 (16글자)

    // 실제 LCD로 나가는 신호 (Top 모듈의 Output이 됨)
    output reg lcd_rs,          // 0: 명령, 1: 데이터
    output reg lcd_rw,          // 0: 쓰기 (항상 0)
    output reg lcd_en,          // Enable 신호
    output reg [7:0] lcd_data   // 8비트 데이터 버스
);

    // 상태 정의
    localparam S_IDLE       = 4'd0;
    localparam S_INIT       = 4'd1;  // 초기화
    localparam S_LINE1      = 4'd2;  // 첫째 줄 출력 중
    localparam S_LINE2      = 4'd3;  // 둘째 줄 출력 중
    localparam S_DELAY      = 4'd4;  // 명령 처리 대기

    reg [3:0] state;
    reg [3:0] next_state;
    
    // [수정] 합성 가능한 형태로 초기화 명령어 처리
    // initial 블록 제거하고 case문으로 처리
    
    reg [2:0] init_idx;      // 초기화 단계 카운터
    reg [3:0] char_idx;      // 글자 순서 카운터 (0~15)
    reg [19:0] delay_cnt;    // 딜레이 카운터
    
    // 50MHz 기준 딜레이 설정
    localparam DELAY_TIME = 100000; 

    // 초기화 명령어 매핑 함수 (Combinational)
    function [7:0] get_init_cmd;
        input [2:0] idx;
        begin
            case (idx)
                3'd0: get_init_cmd = 8'h38; // 8-bit mode, 2 lines
                3'd1: get_init_cmd = 8'h0C; // Display ON, Cursor OFF
                3'd2: get_init_cmd = 8'h06; // Auto Increment
                3'd3: get_init_cmd = 8'h01; // Clear Display
                3'd4: get_init_cmd = 8'h80; // Cursor Home
                default: get_init_cmd = 8'h00;
            endcase
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_INIT;
            init_idx <= 0;
            char_idx <= 0;
            lcd_en <= 0;
            lcd_rs <= 0;
            lcd_rw <= 0;
            lcd_data <= 0;
            delay_cnt <= 0;
        end else begin
            case (state)
                // 1. 초기화 단계
                S_INIT: begin
                    lcd_rs <= 0; // 명령 모드
                    lcd_rw <= 0;
                    lcd_data <= get_init_cmd(init_idx); // 함수 호출로 변경
                    
                    if (delay_cnt == 0) lcd_en <= 1; // Pulse High
                    if (delay_cnt == 5000) lcd_en <= 0; // Pulse Low (Enable 폭 확보)
                    
                    if (delay_cnt < DELAY_TIME) begin
                        delay_cnt <= delay_cnt + 1;
                    end else begin
                        delay_cnt <= 0;
                        if (init_idx < 4) begin
                            init_idx <= init_idx + 1;
                        end else begin
                            state <= S_LINE1; // 초기화 끝, 출력 시작
                            char_idx <= 0;
                        end
                    end
                end

                // 2. 첫 번째 줄 출력
                S_LINE1: begin
                    lcd_rs <= 1; // 데이터 모드 (글자 쓰기)
                    lcd_rw <= 0;
                    
                    // 128비트 데이터에서 해당 순서(char_idx)의 글자(8비트) 뽑아내기
                    lcd_data <= line_1[127 - (char_idx * 8) -: 8];

                    if (delay_cnt == 0) lcd_en <= 1;
                    if (delay_cnt == 2000) lcd_en <= 0;

                    if (delay_cnt < 5000) begin 
                        delay_cnt <= delay_cnt + 1;
                    end else begin
                        delay_cnt <= 0;
                        if (char_idx < 15) begin
                            char_idx <= char_idx + 1;
                        end else begin
                            // 줄 바꿈 준비 (커서를 두 번째 줄로 이동: 0xC0)
                            state <= S_DELAY;
                            next_state <= S_LINE2;
                            lcd_rs <= 0; // 명령
                            lcd_data <= 8'hC0; 
                        end
                    end
                end

                // 3. 줄 바꿈 등 중간 명령 처리
                S_DELAY: begin
                      if (delay_cnt == 0) lcd_en <= 1;
                      if (delay_cnt == 5000) lcd_en <= 0;
                      
                      if (delay_cnt < DELAY_TIME) delay_cnt <= delay_cnt + 1;
                      else begin
                          delay_cnt <= 0;
                          state <= next_state;
                          char_idx <= 0;
                      end
                end

                // 4. 두 번째 줄 출력
                S_LINE2: begin
                    lcd_rs <= 1; 
                    lcd_data <= line_2[127 - (char_idx * 8) -: 8];

                    if (delay_cnt == 0) lcd_en <= 1;
                    if (delay_cnt == 2000) lcd_en <= 0;

                    if (delay_cnt < 5000) begin
                        delay_cnt <= delay_cnt + 1;
                    end else begin
                        delay_cnt <= 0;
                        if (char_idx < 15) begin
                            char_idx <= char_idx + 1;
                        end else begin
                            // 다시 처음으로 (커서 홈: 0x80)
                            state <= S_DELAY;
                            next_state <= S_LINE1; // 계속 갱신
                            lcd_rs <= 0;
                            lcd_data <= 8'h80;
                        end
                    end
                end
            endcase
        end
    end
endmodule