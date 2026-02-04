module Reg4_Servo_Timer (
    input wire clk,              // 50MHz 시스템 클럭
    input wire rst_n,
    input wire timer_run,        // FSM에서 주는 타이머 동작 신호 (1: 동작, 0: 리셋)
    
    output reg time_up,          // 시간 종료 신호
    output reg pwm_servo         // 서보 모터 제어 PWM 신호
);

    // =============================================================
    // 1. 파라미터 설정 (50MHz 기준)
    // =============================================================
    // PWM 주기: 20ms (50Hz) -> 1,000,000 클럭
    parameter PWM_PERIOD = 1000000;
    
    // 서보 듀티비 범위 (0도 ~ 180도)
    // SG90 기준: 0.5ms(-90도) ~ 2.5ms(+90도)인 경우도 있고, 1ms~2ms인 경우도 있음.
    // 여기서는 일반적인 범위인 1ms(50,000) ~ 2ms(100,000) 사용
    // 만약 각도가 너무 좁다면 25000 ~ 125000 등으로 조정 필요
    parameter MIN_DUTY = 50000;   // 0도 (왼쪽 - 시작 위치)
    parameter MAX_DUTY = 100000;  // 180도 (오른쪽 - 끝 위치)

    // 게임 제한 시간: 10초 (500,000,000 클럭)
    parameter GAME_TIME_LIMIT = 500000000; 

    reg [31:0] main_counter;     // 남은 시간 카운터
    reg [19:0] pwm_counter;      // PWM 파형 생성용 카운터
    reg [19:0] current_duty;     // 현재 계산된 듀티비

    // =============================================================
    // 2. 타이머 로직 (Countdown)
    // =============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            main_counter <= GAME_TIME_LIMIT;
            time_up <= 0;
        end 
        else if (timer_run) begin
            // 게임 중: 시간 감소
            if (main_counter > 0) begin
                main_counter <= main_counter - 1;
                time_up <= 0;
            end else begin
                main_counter <= 0;
                time_up <= 1; // 시간 종료!
            end
        end 
        else begin
            // 대기/종료 상태: 시간을 가득 채워서 리셋 (서보를 원위치로)
            main_counter <= GAME_TIME_LIMIT;
            time_up <= 0;
        end
    end

    // =============================================================
    // 3. 듀티비 계산 (오버플로우 해결 버전)
    // =============================================================
    // 목표: 10초 동안 MIN(5만) -> MAX(10만)으로 5만 만큼 증가해야 함.
    // 500,000,000 클럭 / 50,000 듀티 = 10,000
    // 즉, 클럭이 10,000번 흐를 때마다 듀티를 1씩 올리면 됨.
    
    wire [31:0] elapsed_time;
    assign elapsed_time = GAME_TIME_LIMIT - main_counter; // 경과 시간

    always @(posedge clk) begin
        // 간단한 나눗셈으로 비례식 구현 (오버플로우 방지)
        // 경과시간 / 10000 = 추가해야 할 듀티값
        current_duty <= MIN_DUTY + (elapsed_time / 10000);
    end

    // =============================================================
    // 4. PWM 생성 로직
    // =============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_counter <= 0;
            pwm_servo <= 0;
        end else begin
            // 20ms 주기 카운터
            if (pwm_counter < PWM_PERIOD - 1)
                pwm_counter <= pwm_counter + 1;
            else
                pwm_counter <= 0;

            // 듀티비 비교하여 High/Low 출력
            if (pwm_counter < current_duty)
                pwm_servo <= 1;
            else
                pwm_servo <= 0;
        end
    end

endmodule
