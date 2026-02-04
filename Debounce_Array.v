// [새로 추가됨] 버튼 디바운싱 모듈 (Array 지원)
module Debounce_Array #(
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [WIDTH-1:0] btn_in,
    output reg [WIDTH-1:0] btn_out
);

    // 50MHz 클럭 기준, 약 20ms 디바운싱
    // 20ms / 20ns = 1,000,000 count
    localparam CNT_MAX = 1000000;

    reg [WIDTH-1:0] btn_prev;
    reg [19:0] cnt [WIDTH-1:0]; // 각 버튼별 카운터
    
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : db_loop
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    cnt[i] <= 0;
                    btn_out[i] <= 0;
                    btn_prev[i] <= 0;
                end else begin
                    // 입력 상태가 변했으면 카운터 리셋
                    if (btn_in[i] != btn_prev[i]) begin
                        cnt[i] <= 0;
                        btn_prev[i] <= btn_in[i];
                    end else if (cnt[i] < CNT_MAX) begin
                        cnt[i] <= cnt[i] + 1;
                    end else begin
                        // 일정 시간 유지되면 출력 업데이트
                        btn_out[i] <= btn_prev[i];
                    end
                end
            end
        end
    endgenerate

endmodule

// 단일 비트용 (Start 버튼용)
module Debounce (
    input wire clk,
    input wire rst_n,
    input wire btn_in,
    output reg btn_out
);
    localparam CNT_MAX = 1000000; // 20ms
    reg btn_prev;
    reg [19:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            btn_out <= 0;
            btn_prev <= 0;
        end else begin
            if (btn_in != btn_prev) begin
                cnt <= 0;
                btn_prev <= btn_in;
            end else if (cnt < CNT_MAX) begin
                cnt <= cnt + 1;
            end else begin
                btn_out <= btn_prev;
            end
        end
    end
endmodule