module Game_FSM (
    input wire clk,
    input wire rst_n,
    input wire seq_ready,
    input wire [31:0] answer_seq,
    input wire input_done,
    input wire [31:0] user_seq,
    input wire play_done,
    input wire time_up,
    input wire [2:0] current_round,

    output reg en_gen,
    output reg start_play,
    output reg enable_input,
    output reg timer_run,
    output wire [2:0] state_out,
    output reg round_clear,
    output reg game_fail,
    output reg game_clear,
    output reg is_correct
);
    localparam S_IDLE       = 3'd0;
    localparam S_GEN_SEQ    = 3'd1; 
    localparam S_SHOW_SEQ   = 3'd2; 
    localparam S_WAIT_INPUT = 3'd3;
    localparam S_CHECK      = 3'd4; 
    localparam S_PASS       = 3'd5;
    localparam S_FAIL       = 3'd6; 
    localparam S_DONE       = 3'd7;

    reg [2:0] state, next_state;
    assign state_out = state;

    reg [27:0] auto_timer;
    
    // 50MHz 기준
    localparam TIME_3SEC = 150000000;      // 3초
    localparam TIME_DELAY_CHECK = 25000000; // 0.5초 (정답 확인 전 보여줄 시간)

    // Timer Logic (수정됨)
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) auto_timer <= 0;
        else begin
            // [수정] S_CHECK 상태도 타이머가 동작하도록 추가
            if (state == S_IDLE || state == S_FAIL || state == S_PASS || state == S_CHECK) begin
                // 타이머가 오버플로우 되지 않도록 넉넉한 값까지만 증가
                if (auto_timer < TIME_3SEC) auto_timer <= auto_timer + 1;
            end else begin
                auto_timer <= 0;
            end
        end
    end

    // State Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_IDLE;
        else        state <= next_state;
    end

    // Next State Logic (수정됨)
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (auto_timer >= TIME_3SEC) next_state = S_GEN_SEQ;
            end
            S_GEN_SEQ: begin
                if (seq_ready) next_state = S_SHOW_SEQ;
            end
            S_SHOW_SEQ: begin
                if (play_done && !start_play) next_state = S_WAIT_INPUT;
            end
            S_WAIT_INPUT: begin
                if (time_up)         next_state = S_FAIL;
                else if (input_done) next_state = S_CHECK;
            end
            
            // ★★★ [여기가 핵심 수정 부분] ★★★
            S_CHECK: begin
                // 즉시 판단하지 않고, 0.5초 동안 대기 (마지막 입력 숫자를 보여주기 위해)
                if (auto_timer >= TIME_DELAY_CHECK) begin
                    if (answer_seq == user_seq) next_state = S_PASS;
                    else                        next_state = S_FAIL;
                end
                // 시간이 안 됐으면 S_CHECK 상태 유지 (이때 7-Seg는 마지막 숫자를 계속 표시함)
            end

            S_PASS: begin
                if (auto_timer >= TIME_3SEC) begin
                    if (current_round >= 6) next_state = S_DONE;
                    else                    next_state = S_GEN_SEQ;
                end
            end
            S_FAIL: begin
                if (auto_timer >= TIME_3SEC) begin
                    if (current_round <= 5) next_state = S_GEN_SEQ;
                    else                    next_state = S_DONE; 
                end
            end
            S_DONE: begin
                next_state = S_DONE; 
            end
        endcase
    end

    // Output Logic (수정됨)
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            en_gen <= 0; start_play <= 0; enable_input <= 0;
            timer_run <= 0; round_clear <= 0; game_fail <= 0;
            game_clear <= 0; is_correct <= 0;
        end else begin
            // 기본값 0으로 초기화
            en_gen <= 0; start_play <= 0; 
            round_clear <= 0; 
            game_fail <= 0; 
            game_clear <= 0;
            
            case (next_state) 
                S_GEN_SEQ: begin
                    if(state == S_IDLE || state == S_PASS || state == S_FAIL) en_gen <= 1;
                end
                S_SHOW_SEQ: begin
                    if(state == S_GEN_SEQ) start_play <= 1;
                end
                S_WAIT_INPUT: begin
                    enable_input <= 1; timer_run <= 1;
                end
                
                S_CHECK: begin
                    enable_input <= 0; timer_run <= 0;
                    // 여기서 아무것도 하지 않고 대기하면, 
                    // 7-Seg는 Reg2의 user_seq 값을 계속 출력하고 있음.
                end
                
                S_PASS: begin
                    is_correct <= 1;
                    // S_CHECK에서 S_PASS로 넘어가는 순간에만 신호 발생
                    if (state == S_CHECK) round_clear <= 1;
                    else                  round_clear <= 0;
                end
                
                S_FAIL: begin
                    is_correct <= 0; 
                    if (state == S_CHECK || state == S_WAIT_INPUT) game_fail <= 1;
                    else                                           game_fail <= 0;
                end
                
                S_DONE: begin
                    is_correct <= 1; 
                    game_clear <= 1;
                end
                S_IDLE: begin
                    game_fail <= 0; game_clear <= 0; is_correct <= 0;
                end
            endcase
        end
    end
endmodule
