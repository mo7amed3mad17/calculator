`timescale 1ns/1ps

module alu_tb;

    // Testbench inputs
    logic signed [7:0] oprandA;
    logic signed [7:0] oprandB;
    logic        [1:0] op;

    // Testbench outputs
    logic signed [15:0] result;
    logic               zero_f;

    integer passed = 0;
    integer failed = 0;

    // Instantiate the ALU
    alu dut (
        .oprandA(oprandA),
        .oprandB(oprandB),
        .op(op),
        .result(result),
        .zero_f(zero_f)
    );

    // Test task
    task automatic check_case(
        input logic signed [7:0] a,
        input logic signed [7:0] b,
        input logic [1:0] opcode,
        input logic signed [15:0] expected,
        input logic expected_zero
    );

        begin
            oprandA = a;
            oprandB = b;
            op = opcode;

            #1;

            if (result === expected && zero_f === expected_zero) begin
                $display("PASS: A=%0d B=%0d OP=%b RESULT=%0d",
                         a, b, opcode, result);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: A=%0d B=%0d OP=%b EXPECTED=%0d ACTUAL=%0d ZERO=%b",
                         a, b, opcode, expected, result, zero_f);
                failed = failed + 1;
            end
        end

    endtask

    initial begin

        $display("Starting ALU tests...");
        $display("----------------------------");

        // Addition
        check_case(10, 5, 2'b00, 15, 0);

        // Subtraction
        check_case(10, 15, 2'b01, -5, 0);

        // Multiplication
        check_case(-10, 5, 2'b10, -50, 0);

        // Division
        check_case(-20, 4, 2'b11, -5, 0);

        // Division overflow edge case
        check_case(-128, -1, 2'b11, 128, 0);

        // Division by zero
        check_case(10, 0, 2'b11, 0, 1);

        // Addition beyond signed 8-bit range
        check_case(100, 50, 2'b00, 150, 0);

        // Signed division truncation
        check_case(-7, 2, 2'b11, -3, 0);

        $display("----------------------------");
        $display("Tests passed: %0d", passed);
        $display("Tests failed: %0d", failed);

        if (failed == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");

        $finish;

    end

endmodule
