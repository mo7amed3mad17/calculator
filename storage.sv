`timescale 1ns/1ps

module storage(

// inputs
input logic clk,
input logic reset,

// write oprands interface
input logic oprand_we,
input logic [1:0]  oprand_write_addr,
input logic signed [7:0]  oprand_data,

// read oprands interface
input logic [1:0]  a_read_addr,
input logic [1:0]  b_read_addr,
output logic signed [7:0] oprandA,
output logic signed [7:0] oprandB,

// write result interface
input logic        result_we,
input logic [1:0]  result_write_addr,
input logic signed [15:0] result_data,


// read result interface
input logic [1:0]  result_read_addr,
output logic signed [15:0] result
);


logic signed [7:0] oprand_mem [4];
logic signed [15:0] result_mem [4];

always_ff @( posedge clk) begin

    if (reset) begin
        for (int i = 0; i < 4; i++) begin
            oprand_mem[i] <= 8'sd0;
            result_mem[i] <= 16'sd0;
        end
    end

    else begin
        if (oprand_we) begin
            oprand_mem[oprand_write_addr] <= oprand_data;
       end

        if (result_we) begin
            result_mem[result_write_addr] <= result_data;
        end
    end
end

always_comb begin
    oprandA = oprand_mem[a_read_addr];
    oprandB = oprand_mem[b_read_addr];

    result = result_mem[result_read_addr];
end

endmodule
