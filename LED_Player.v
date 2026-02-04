module LED_Player (
    input clk,
    input rst_n,
    input start_play,           
    input [3:0] difficulty_k,   
    input [31:0] answer_seq,    
    input [2:0] current_round,  
    output reg [7:0] led_out,   
    output reg play_done        
);
    reg [25:0] blink_period; 
    reg [25:0] on_duration;  

    always @(*) begin
        case (current_round)
            3'd1: blink_period = 26'd50000000; // 1초
            3'd2: blink_period = 26'd40000000; 
            3'd3: blink_period = 26'd30000000; 
            3'd4: blink_period = 26'd20000000; 
            3'd5: blink_period = 26'd10000000; 
            default: blink_period = 26'd50000000;
        endcase
        on_duration = blink_period - (blink_period >> 2); // 75% 켜짐, 25% 꺼짐
    end

    reg [25:0] timer; 
    reg [3:0] play_cnt; 
    reg is_running;
    reg [3:0] target_num;

    // 현재 순서(play_cnt)에 맞는 정답 숫자 추출
    always @(*) begin
        case (play_cnt)
            4'd0: target_num = answer_seq[3:0];
            4'd1: target_num = answer_seq[7:4];
            4'd2: target_num = answer_seq[11:8];
            4'd3: target_num = answer_seq[15:12];
            4'd4: target_num = answer_seq[19:16];
            4'd5: target_num = answer_seq[23:20];
            4'd6: target_num = answer_seq[27:24];
            4'd7: target_num = answer_seq[31:28];
            default: target_num = 4'd0;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_out <= 8'd0; 
            play_done <= 1'b0; timer <= 26'd0;
            play_cnt <= 4'd0; is_running <= 1'b0;
        end else begin
            if (start_play) begin
                is_running <= 1'b1; play_cnt <= 4'd0;
                timer <= 26'd0; play_done <= 1'b0;
                led_out <= 8'd0; // 시작 시 초기화
            end
            
            if (is_running) begin
                if (timer < blink_period) begin
                    timer <= timer + 1;
                    if (timer < on_duration) begin
                        // 해당 번호의 LED만 켬
                        if (target_num != 0) led_out <= (1 << (target_num - 1));
                        else led_out <= 8'd0;
                    end else begin
                        // 깜빡임 효과를 위해 잠시 끔
                        led_out <= 8'd0;
                    end
                end else begin
                    // 주기 끝
                    timer <= 26'd0;
                    // difficulty_k 개수만큼만 플레이
                    if (play_cnt < difficulty_k - 1) begin
                        play_cnt <= play_cnt + 1;
                    end else begin
                        // 종료
                        is_running <= 1'b0; 
                        play_done <= 1'b1; 
                        led_out <= 8'd0; // [중요] 끝나면 확실하게 끔
                    end
                end
            end else begin
                // 실행 중이 아닐 때는 항상 꺼둠 (잔상 방지)
                led_out <= 8'd0;
            end
        end
    end
endmodule