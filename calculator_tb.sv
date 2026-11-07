`timescale 1ns/1ps

module calculator_tb;

logic clk = 0, reset, start;
logic [1:0] op_in, batch_len, result_read_addr, oprand_write_addr;
logic oprand_we;
logic signed [7:0]  oprand_data;
logic signed [15:0] result;
logic busy, done, zero_err;

int errors = 0;

calculator dut (.*);

always #5 clk = ~clk;

task automatic load(input logic [1:0] addr, input logic signed [7:0] d);
    @(negedge clk);
    oprand_we = 1; oprand_write_addr = addr; oprand_data = d;
    @(negedge clk);
    oprand_we = 0;
endtask

task automatic run(input logic [1:0] o, input logic [1:0] n);
    @(negedge clk);
    op_in = o; batch_len = n; start = 1;
    @(negedge clk);
    start = 0;
    wait (done);
    @(negedge clk);
endtask

task automatic check(input string name, input logic [1:0] addr,
                     input logic signed [15:0] exp);
    result_read_addr = addr;
    #1;
    if (result === exp) $display("PASS  %-20s result[%0d] = %0d", name, addr, result);
    else begin
        $display("FAIL  %-20s result[%0d] = %0d, expected %0d", name, addr, result, exp);
        errors++;
    end
endtask

task automatic check_err(input string name, input logic exp);
    if (zero_err === exp) $display("PASS  %-20s zero_err = %b", name, zero_err);
    else begin
        $display("FAIL  %-20s zero_err = %b, expected %b", name, zero_err, exp);
        errors++;
    end
endtask

initial begin
    $dumpfile("calculator_tb.vcd");
    $dumpvars(0, calculator_tb);

    reset = 1; start = 0; op_in = 0; batch_len = 1; oprand_we = 0;
    oprand_write_addr = 0; oprand_data = 0; result_read_addr = 0;
    repeat (2) @(negedge clk);
    reset = 0;

    // pairs (5,7) and (-3,10)
    load(0, 5); load(1, 7); load(2, -3); load(3, 10);
    run(2'b00, 2); check("add pair0", 0, 12);   check("add pair1", 1, 7);
    run(2'b01, 2); check("sub pair0", 0, -2);   check("sub pair1", 1, -13);
    run(2'b10, 2); check("mul pair0", 0, 35);   check("mul pair1", 1, -30);

    // single pair: pair 1 result must stay unchanged
    run(2'b00, 1); check("add 1 pair", 0, 12);  check("pair1 untouched", 1, -30);

    // extremes
    load(0, -128); load(1, -128); load(2, 127); load(3, 127);
    run(2'b10, 2); check("mul -128*-128", 0, 16384); check("mul 127*127", 1, 16129);

    // division: (100,7) and (-100,7)
    load(0, 100); load(1, 7); load(2, -100); load(3, 7);
    run(2'b11, 2); check("div 100/7", 0, 14);  check("div -100/7", 1, -14);
    check_err("no error", 0);

    // divide by zero in pair 0
    load(0, 9); load(1, 0); load(2, 8); load(3, 2);
    run(2'b11, 2); check("div by zero", 0, 0); check("div 8/2", 1, 4);
    check_err("error flagged", 1);

    // flag clears on the next run
    run(2'b00, 2); check_err("error cleared", 0);

    if (errors == 0) $display("ALL TESTS PASSED");
    else             $display("%0d TEST(S) FAILED", errors);
    $finish;
end

endmodule
