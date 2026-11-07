`timescale 1ns/1ps

module control(

// clock and reset
input logic clk,
input logic reset,

// host controls
input logic       start,
input logic [1:0] op_in,
input logic [1:0] batch_len,      // 1 = one pair, 2 = two pairs

// status from the alu
input logic zero_f,

// controls to alu and storage
output logic [1:0] op,
output logic [1:0] a_read_addr,
output logic [1:0] b_read_addr,
output logic [1:0] result_write_addr,
output logic       result_we,

// status to host
output logic busy,
output logic done,
output logic zero_err
);

typedef enum logic [1:0] {IDLE, RUN, DONE} state_t;
state_t state;

logic pair_idx;     // which operand pair is being processed (0 or 1)
logic last_pair;    // index of the final pair in this batch

always_ff @(posedge clk) begin
    if (reset) begin
        state     <= IDLE;
        pair_idx  <= 1'b0;
        last_pair <= 1'b0;
        op        <= 2'b00;
        zero_err  <= 1'b0;
    end
    else begin
        case (state)
            IDLE, DONE: begin
                if (start) begin
                    op        <= op_in;                 // latch the operation
                    last_pair <= (batch_len >= 2'd2);
                    pair_idx  <= 1'b0;
                    zero_err  <= 1'b0;
                    state     <= RUN;
                end
            end

            RUN: begin
                if (zero_f) zero_err <= 1'b1;           // sticky error flag
                if (pair_idx == last_pair) state <= DONE;
                else                       pair_idx <= pair_idx + 1'b1;
            end

            default: state <= IDLE;
        endcase
    end
end

// addresses come from the pair counter: pair 0 = entries 0,1; pair 1 = entries 2,3
assign a_read_addr       = {pair_idx, 1'b0};
assign b_read_addr       = {pair_idx, 1'b1};
assign result_write_addr = {1'b0, pair_idx};

assign result_we = (state == RUN);
assign busy      = (state == RUN);
assign done      = (state == DONE);

endmodule
