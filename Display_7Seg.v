module Display_7Seg (
    input clk,
    input rst_n,
    input [31:0] user_seq,      
    input [3:0] input_cnt,      
    
    output reg [7:0] seg_data,
    output reg [7:0] seg_sel    
);
    reg [19:0] scan_cnt;
    wire [2:0] scan_idx;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) scan_cnt <= 20'd0;
        else        scan_cnt <= scan_cnt + 1;
    end
    
    // 스캔 속도 조절
    assign scan_idx = scan_cnt[19:17];

    reg [3:0] display_num;
    
    always @(*) begin
        // 기본적으로 모두 끔 (Active Low 기준 11111111)
        seg_sel = 8'hFF; 
        display_num = 4'd15; // 15 = Blank (Empty)

        // [수정됨] Digit 0(보통 오른쪽 끝)부터 1, 2, 3... 순서로 채워지도록 변경
        case (scan_idx)
            // 0번째 자리 (Digit 0) -> 첫 번째 입력값 표시
            3'd0: begin 
                seg_sel = ~8'b00000001; 
                if (input_cnt >= 1) display_num = user_seq[3:0];
            end
            
            // 1번째 자리 (Digit 1) -> 두 번째 입력값 표시
            3'd1: begin 
                seg_sel = ~8'b00000010;
                if (input_cnt >= 2) display_num = user_seq[7:4];
            end
            
            // 2번째 자리 (Digit 2) -> 세 번째 입력값 표시
            3'd2: begin 
                seg_sel = ~8'b00000100;
                if (input_cnt >= 3) display_num = user_seq[11:8];
            end
            
            // 3번째 자리 (Digit 3) -> 네 번째 입력값 표시
            3'd3: begin 
                seg_sel = ~8'b00001000;
                if (input_cnt >= 4) display_num = user_seq[15:12];
            end
            
            // 4번째 자리 (Digit 4) -> 다섯 번째 입력값 표시
            3'd4: begin 
                seg_sel = ~8'b00010000;
                if (input_cnt >= 5) display_num = user_seq[19:16];
            end
            
            // 5번째 자리 (Digit 5) -> 여섯 번째 입력값 표시
            3'd5: begin 
                seg_sel = ~8'b00100000;
                if (input_cnt >= 6) display_num = user_seq[23:20];
            end
            
            // 6번째 자리 (Digit 6) -> 일곱 번째 입력값 표시
            3'd6: begin 
                seg_sel = ~8'b01000000;
                if (input_cnt >= 7) display_num = user_seq[27:24];
            end
            
            // 7번째 자리 (Digit 7) -> 여덟 번째 입력값 표시
            3'd7: begin 
                seg_sel = ~8'b10000000;
                if (input_cnt >= 8) display_num = user_seq[31:28];
            end
        endcase
    end

    reg [7:0] decode_out;
    always @(*) begin
        case (display_num)
            // 숫자 패턴 정의 (0이 켜짐 기준)
            4'd0: decode_out = 8'b1100_0000; 
            4'd1: decode_out = 8'b1111_1001;
            4'd2: decode_out = 8'b1010_0100;
            4'd3: decode_out = 8'b1011_0000;
            4'd4: decode_out = 8'b1001_1001;
            4'd5: decode_out = 8'b1001_0010;
            4'd6: decode_out = 8'b1000_0010;
            4'd7: decode_out = 8'b1111_1000;
            4'd8: decode_out = 8'b1000_0000;
            4'd9: decode_out = 8'b1001_0000;
            default: decode_out = 8'b1111_1111; // OFF
        endcase
        
        // [수정됨] 획이 반대로 나온다면 데이터 신호를 반전시켜야 합니다.
        // 기존 코드에서 ~를 추가하여 반전시켰습니다.
        seg_data = ~decode_out; 
    end
endmodule