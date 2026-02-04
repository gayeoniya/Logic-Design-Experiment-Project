module Top_Memory_Game (
    input wire clk,
    input wire rst_n,
    input wire [7:0] btn_raw,

    output wire [7:0] led_out,
    output wire [7:0] seg_data,
    output wire [7:0] seg_sel,    
    output wire pwm_servo,
    output wire lcd_rs,
    output wire lcd_rw,
    output wire lcd_en,
    output wire [7:0] lcd_data
);
    // ... (기존 와이어 선언들) ...
    wire [7:0] btn_clean;
    wire en_gen, start_play, enable_input, timer_run;
    wire [2:0] state;
    wire round_clear, game_fail, game_clear, is_correct;
    // ... (나머지 와이어들 동일) ...
    wire [31:0] answer_seq, user_seq;
    wire seq_ready, input_done, key_valid, time_up, play_done;
    wire [3:0] input_cnt, current_key, difficulty_k;
    wire [2:0] current_round;
    wire [15:0] total_score;
    wire [127:0] w_line_1, w_line_2;

    // ... (Debounce, Reg1, Reg2 등 다른 모듈 인스턴스 동일) ...
    Debounce_Array #(.WIDTH(8)) u_Debounce_Keys (
        .clk(clk), .rst_n(rst_n), .btn_in(~btn_raw), .btn_out(btn_clean)
    );
    
    // FSM (수정된 모듈)
    Game_FSM u_FSM (
        .clk(clk), .rst_n(rst_n), 
        .seq_ready(seq_ready), .answer_seq(answer_seq),
        .input_done(input_done), .user_seq(user_seq),
        .play_done(play_done), .time_up(time_up),
        .current_round(current_round),
        
        .en_gen(en_gen), .start_play(start_play), .enable_input(enable_input),
        .timer_run(timer_run), .state_out(state),
        .round_clear(round_clear), .game_fail(game_fail),
        .game_clear(game_clear), .is_correct(is_correct)
    );

    Reg1_Random_Gen u_Reg1 (
        .clk(clk), .rst_n(rst_n), .en_gen(en_gen),
        .difficulty_k(difficulty_k),
        .answer_seq(answer_seq), .seq_ready(seq_ready)
    );

    // Reg2 (이전 단계에서 수정한 완료 로직 포함된 버전 사용)
    Reg2_Input_Sync u_Reg2 (
        .clk(clk), .rst_n(rst_n), .btn_clean(btn_clean), 
        .enable_input(enable_input), .start_clear(en_gen),
        .difficulty_k(difficulty_k), .time_up(time_up),
        .user_seq(user_seq), .current_key(current_key),
        .input_done(input_done), .key_valid(key_valid), .input_cnt(input_cnt) 
    );

    // ★★★ [수정됨] Reg3 연결 (game_fail 포트 추가) ★★★
    Reg3_Game_State u_Reg3 (
        .clk(clk), .rst_n(rst_n), 
        .round_clear(round_clear),
        .game_fail(game_fail),       // [연결 추가]
        .game_reset(state == 3'd0), 
        .current_round(current_round), 
        .difficulty_k(difficulty_k),
        .total_score(total_score)
    );

    // ... (나머지 모듈들 Reg4, LED, 7Seg, LCD 등 그대로 연결) ...
    Reg4_Servo_Timer u_Reg4 (
        .clk(clk), .rst_n(rst_n), .timer_run(timer_run),
        .time_up(time_up), .pwm_servo(pwm_servo)
    );

    LED_Player u_LED_Player (
        .clk(clk), .rst_n(rst_n), .start_play(start_play),
        .difficulty_k(difficulty_k), .current_round(current_round),
        .answer_seq(answer_seq), .led_out(led_out), .play_done(play_done)
    );

    Display_7Seg u_Disp_7Seg (
        .clk(clk), .rst_n(rst_n), .user_seq(user_seq),
        .input_cnt(input_cnt), 
        .seg_data(seg_data), .seg_sel(seg_sel)
    );

    LCD_Text_Gen u_LCD_Gen (
        .state(state), .current_round(current_round),
        .total_score(total_score), .is_success(is_correct),
        .line_1(w_line_1), .line_2(w_line_2)
    );

    LCD_Display_Controller u_LCD_Driver (
        .clk(clk), .rst_n(rst_n), .line_1(w_line_1), .line_2(w_line_2),
        .lcd_rs(lcd_rs), .lcd_rw(lcd_rw), .lcd_en(lcd_en), .lcd_data(lcd_data)
    );

endmodule
