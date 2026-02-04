module Reg1_Random_Gen (
    input clk,
    input rst_n,
    input en_gen,           
    input [3:0] difficulty_k,  
    output reg [31:0] answer_seq,
    output reg seq_ready      
);

    reg [15:0] lfsr_reg;
    wire feedback;
    assign feedback = lfsr_reg[15] ^ lfsr_reg[13] ^ lfsr_reg[12] ^ lfsr_reg[10];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) lfsr_reg <= 16'hACE1;
        else        lfsr_reg <= {lfsr_reg[14:0], feedback};
    end

    wire [3:0] random_val;      
    assign random_val = {1'b0, lfsr_reg[2:0]} + 4'd1;

    reg [3:0] gen_cnt;          
    reg [1:0] state;            
    reg [3:0] last_val;         
    reg [1:0] same_cnt;         

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            answer_seq <= 32'd0; seq_ready <= 1'b0; gen_cnt <= 4'd0;
            state <= 2'd0; last_val <= 4'd0; same_cnt <= 2'd0;  
        end else begin
            case (state)
                2'd0: begin
                    seq_ready <= 1'b0;
                    if (en_gen) begin
                        gen_cnt <= 4'd0; answer_seq <= 32'd0;
                        last_val <= 4'd0; same_cnt <= 2'd0;
                        state <= 2'd1;       
                    end
                end

                2'd1: begin
                    if (gen_cnt < difficulty_k) begin
                        if ((gen_cnt > 0) && (random_val == last_val) && (same_cnt >= 2'd2)) begin
                        end else begin
                            if (gen_cnt == 0) same_cnt <= 2'd1;
                            else if (random_val == last_val) same_cnt <= same_cnt + 1;
                            else same_cnt <= 2'd1;

                            last_val <= random_val;

                            case (gen_cnt)
                                4'd0: answer_seq[3:0]   <= random_val;
                                4'd1: answer_seq[7:4]   <= random_val;
                                4'd2: answer_seq[11:8]  <= random_val;
                                4'd3: answer_seq[15:12] <= random_val;
                                4'd4: answer_seq[19:16] <= random_val;
                                4'd5: answer_seq[23:20] <= random_val;
                                4'd6: answer_seq[27:24] <= random_val;
                                4'd7: answer_seq[31:28] <= random_val;
                            endcase
                            gen_cnt <= gen_cnt + 1;
                        end
                    end else begin
                        seq_ready <= 1'b1; state <= 2'd0; 
                    end
                end
            endcase
        end
    end
endmodule