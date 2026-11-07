`timescale 1ns/1ps

module calculator (

// clock and reset
input logic clk,
input logic reset,

// control
input logic       start,
input logic [1:0] op_in,
input logic [1:0] batch_len,

// write oprands interface
input logic              oprand_we,
input logic [1:0]        oprand_write_addr,
input logic signed [7:0] oprand_data,

// read result interface
input logic [1:0] result_read_addr,

// outputs
output logic signed [15:0] result,
output logic busy,
output logic done,
output logic zero_err
);

// internal wires
logic signed [15:0] alu_result;
logic signed [7:0]  oprandA_val, oprandB_val;
logic        [1:0]  op;
logic        [1:0]  a_read_addr, b_read_addr, result_write_addr;
logic               result_we;
logic               zero_f;

control u_control (
    .clk(clk), .reset(reset),
    .start(start), .op_in(op_in), .batch_len(batch_len),
    .zero_f(zero_f),
    .op(op),
    .a_read_addr(a_read_addr), .b_read_addr(b_read_addr),
    .result_write_addr(result_write_addr), .result_we(result_we),
    .busy(busy), .done(done), .zero_err(zero_err)
);

storage u_storage (
    .clk(clk), .reset(reset),
    .oprand_we(oprand_we & ~busy),                 // block writes while running
    .oprand_write_addr(oprand_write_addr), .oprand_data(oprand_data),
    .a_read_addr(a_read_addr), .b_read_addr(b_read_addr),
    .oprandA(oprandA_val), .oprandB(oprandB_val),
    .result_we(result_we), .result_write_addr(result_write_addr),
    .result_data(alu_result),
    .result_read_addr(result_read_addr), .result(result)
);

alu u_alu (
    .oprandA(oprandA_val), .oprandB(oprandB_val),
    .op(op), .result(alu_result), .zero_f(zero_f)
);

endmodule
