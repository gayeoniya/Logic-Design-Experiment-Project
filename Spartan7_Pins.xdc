## ----------------------------------------------------------------------------
## 1. System Clock (50MHz)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { clk }]; 
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports { clk }];

## ----------------------------------------------------------------------------
## 2. Control Buttons (Push Buttons)
## ----------------------------------------------------------------------------
# Reset (Button 0) -> Dip switch first
set_property -dict { PACKAGE_PIN Y1    IOSTANDARD LVCMOS33 } [get_ports { rst_n }]; 

# Game Start (Button 1) -> Dip switch second
#set_property -dict { PACKAGE_PIN K6    IOSTANDARD LVCMOS33 } [get_ports { start_btn }];

## ----------------------------------------------------------------------------
## 3. User Input -> kEYPAD
## 기존 코드에서 에러가 났던 SW5, SW6, SW7을 CSV 파일 기반으로 수정함 (R1->T1 등)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN K4    IOSTANDARD LVCMOS33 } [get_ports { btn_raw[0] }]; # SW0
set_property -dict { PACKAGE_PIN N8    IOSTANDARD LVCMOS33 } [get_ports { btn_raw[1] }]; # SW1
set_property -dict { PACKAGE_PIN N4    IOSTANDARD LVCMOS33 } [get_ports { btn_raw[2] }]; # SW2
set_property -dict { PACKAGE_PIN N1    IOSTANDARD LVCMOS33 } [get_ports { btn_raw[3] }]; # SW3
set_property -dict { PACKAGE_PIN P6    IOSTANDARD LVCMOS33 } [get_ports { btn_raw[4] }]; # SW4
set_property -dict { PACKAGE_PIN N6    IOSTANDARD LVCMOS33 } [get_ports { btn_raw[5] }]; # SW5 (Corrected)
set_property -dict { PACKAGE_PIN L5    IOSTANDARD LVCMOS33 } [get_ports { btn_raw[6] }]; # SW6 (Corrected)
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { btn_raw[7] }]; # SW7 (Corrected)

## ----------------------------------------------------------------------------
## 4. LED Output (LED 0 ~ 7) - 정답 패턴 표시용
## 기존 핀(L4~N4)은 유효하지 않으므로 DLD-Spartan7-Peripheral.csv의 LED 핀으로 전면 교체
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN L4   IOSTANDARD LVCMOS33 } [get_ports { led_out[0] }]; # LD0
set_property -dict { PACKAGE_PIN M4   IOSTANDARD LVCMOS33 } [get_ports { led_out[1] }]; # LD1
set_property -dict { PACKAGE_PIN M2   IOSTANDARD LVCMOS33 } [get_ports { led_out[2] }]; # LD2
set_property -dict { PACKAGE_PIN N7   IOSTANDARD LVCMOS33 } [get_ports { led_out[3] }]; # LD3
set_property -dict { PACKAGE_PIN M7   IOSTANDARD LVCMOS33 } [get_ports { led_out[4] }]; # LD4
set_property -dict { PACKAGE_PIN M3   IOSTANDARD LVCMOS33 } [get_ports { led_out[5] }]; # LD5
set_property -dict { PACKAGE_PIN M1   IOSTANDARD LVCMOS33 } [get_ports { led_out[6] }]; # LD6
set_property -dict { PACKAGE_PIN N5   IOSTANDARD LVCMOS33 } [get_ports { led_out[7] }]; # LD7

## ----------------------------------------------------------------------------
## 5. 7-Segment Display
## 기존 핀(F1~H2)은 유효하지 않으므로 Peripheral.csv의 Segment 핀으로 전면 교체
## ----------------------------------------------------------------------------
# Segment Data (a, b, c, d, e, f, g, dp)
set_property -dict { PACKAGE_PIN F1   IOSTANDARD LVCMOS33 } [get_ports { seg_data[0] }]; # CA
set_property -dict { PACKAGE_PIN F5   IOSTANDARD LVCMOS33 } [get_ports { seg_data[1] }]; # CB
set_property -dict { PACKAGE_PIN E2   IOSTANDARD LVCMOS33 } [get_ports { seg_data[2] }]; # CC
set_property -dict { PACKAGE_PIN E4   IOSTANDARD LVCMOS33 } [get_ports { seg_data[3] }]; # CD
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports { seg_data[4] }]; # CE
set_property -dict { PACKAGE_PIN J3   IOSTANDARD LVCMOS33 } [get_ports { seg_data[5] }]; # CF
set_property -dict { PACKAGE_PIN J7  IOSTANDARD LVCMOS33 } [get_ports { seg_data[6] }]; # CG
set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports { seg_data[7] }];

# Digit Select (Common Anode 0 ~ 3)
set_property -dict { PACKAGE_PIN H4  IOSTANDARD LVCMOS33 } [get_ports { seg_sel[0] }]; # AN0
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [get_ports { seg_sel[1] }]; # AN1
set_property -dict { PACKAGE_PIN G1  IOSTANDARD LVCMOS33 } [get_ports { seg_sel[2] }]; # AN2
set_property -dict { PACKAGE_PIN G3  IOSTANDARD LVCMOS33 } [get_ports { seg_sel[3] }]; # AN3
set_property -dict { PACKAGE_PIN L6  IOSTANDARD LVCMOS33 } [get_ports { seg_sel[4] }]; # AN3
set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS33 } [get_ports { seg_sel[5] }]; # AN3
set_property -dict { PACKAGE_PIN K3  IOSTANDARD LVCMOS33 } [get_ports { seg_sel[6] }]; # AN3
set_property -dict { PACKAGE_PIN K5  IOSTANDARD LVCMOS33 } [get_ports { seg_sel[7] }]; # AN3

## ----------------------------------------------------------------------------
## 6. Servo Motor (Connector J1 - Pin 4)
## Connector.csv 확인 결과 J1_4 핀은 A4가 맞습니다.
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN AA22    IOSTANDARD LVCMOS33 } [get_ports { pwm_servo }];

## ----------------------------------------------------------------------------
## 7. LCD Module (16x2 Character LCD) - Connector J1
## J1 커넥터 핀맵은 기존 설정(Y11, AA11...)이 Connector.csv와 일치하여 유지합니다.
## ----------------------------------------------------------------------------
# Control Signals
set_property -dict { PACKAGE_PIN G6   IOSTANDARD LVCMOS33 } [get_ports { lcd_rs }];      # J1_1
set_property -dict { PACKAGE_PIN D6  IOSTANDARD LVCMOS33 } [get_ports { lcd_rw }];      # J1_3
set_property -dict { PACKAGE_PIN A6   IOSTANDARD LVCMOS33 } [get_ports { lcd_en }];      # J1_5

# Data Signals (D0 ~ D7)
set_property -dict { PACKAGE_PIN A4   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[0] }]; # J1_7
set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 } [get_ports { lcd_data[1] }]; # J1_9
set_property -dict { PACKAGE_PIN C3   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[2] }]; # J1_11
set_property -dict { PACKAGE_PIN D4   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[3] }]; # J1_13
set_property -dict { PACKAGE_PIN A2   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[4] }]; # J1_15
set_property -dict { PACKAGE_PIN C5  IOSTANDARD LVCMOS33 } [get_ports { lcd_data[5] }]; # J1_17
set_property -dict { PACKAGE_PIN C1   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[6] }]; # J1_19
set_property -dict { PACKAGE_PIN D1   IOSTANDARD LVCMOS33 } [get_ports { lcd_data[7] }]; # J1_21