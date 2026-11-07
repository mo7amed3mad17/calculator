`timescale 1ns/1ps

module storage_tb;

    logic clk;
    logic reset;

    logic oprand_we;
    logic [1:0] oprand_write_addr;
    logic signed [7:0] oprand_data;

    logic [1:0] a_read_addr;
    logic [1:0] b_read_addr;
    logic signed [7:0] oprandA;
    logic signed [7:0] oprandB;

    logic result_we;
    logic [1:0] result_write_addr;
    logic signed [15:0] result_data;

    logic [1:0] result_read_addr;
    logic signed [15:0] result;

        storage dut (
        .clk(clk),
        .reset(reset),

        .oprand_we(oprand_we),
        .oprand_write_addr(oprand_write_addr),
        .oprand_data(oprand_data),

        .a_read_addr(a_read_addr),
        .b_read_addr(b_read_addr),
        .oprandA(oprandA),
        .oprandB(oprandB),

        .result_we(result_we),
        .result_write_addr(result_write_addr),
        .result_data(result_data),

        .result_read_addr(result_read_addr),
        .result(result)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

    // Initialize control signals
    reset = 0;

    oprand_we = 0;
    oprand_write_addr = 0;
    oprand_data = 0;

    a_read_addr = 0;
    b_read_addr = 0;

    result_we = 0;
    result_write_addr = 0;
    result_data = 0;

    result_read_addr = 0;

    #2;
    reset = 1;

    #10;
    reset = 0;

        #1;

    for (int i = 0; i < 4; i++) begin

        a_read_addr = i;
        #1;

        if (oprandA !== 8'sd0)
            $display("FAIL: Operand location %0d was not reset", i);
        else
            $display("PASS: Operand location %0d reset", i);

        result_read_addr = i;
        #1;

        if (result !== 16'sd0)
            $display("FAIL: Result location %0d was not reset", i);
        else
            $display("PASS: Result location %0d reset", i);

    end
        // Write operand location 0
        @(negedge clk);
        oprand_we = 1;
        oprand_write_addr = 0;
        oprand_data = 8'sd25;

        @(posedge clk);
        #1;

        // Write operand location 1
        @(negedge clk);
        oprand_write_addr = 1;
        oprand_data = -8'sd15;

        @(posedge clk);
        #1;

        oprand_we = 0;

        // Read operand locations
        a_read_addr = 0;
        b_read_addr = 1;
        #1;

        $display("Operand A = %0d", oprandA);
        $display("Operand B = %0d", oprandB);

        // Write result location 0
        @(negedge clk);
        result_we = 1;
        result_write_addr = 0;
        result_data = 16'sd1000;
        @(posedge clk);
        #1;

        // Write result location 1
        @(negedge clk);
        result_write_addr = 1;
        result_data = -16'sd2000;
        @(posedge clk);
        #1;

        // Write result location 2
        @(negedge clk);
        result_write_addr = 2;
        result_data = 16'sd30000;
        @(posedge clk);
        #1;

        // Write result location 3
        @(negedge clk);
        result_write_addr = 3;
        result_data = -16'sd30000;
        @(posedge clk);
        #1;

        result_we = 0;

        // Read result location 0
        result_read_addr = 0;
        #1;
        if (result !== 16'sd1000)
            $display("FAIL: Result[0], expected 1000, got %0d", result);
        else
            $display("PASS: Result[0] = %0d", result);

        // Read result location 1
        result_read_addr = 1;
        #1;
        if (result !== -16'sd2000)
            $display("FAIL: Result[1], expected -2000, got %0d", result);
        else
            $display("PASS: Result[1] = %0d", result);

        // Read result location 2
        result_read_addr = 2;
        #1;
        if (result !== 16'sd30000)
            $display("FAIL: Result[2], expected 30000, got %0d", result);
        else
            $display("PASS: Result[2] = %0d", result);

        // Read result location 3
        result_read_addr = 3;
        #1;
        if (result !== -16'sd30000)
            $display("FAIL: Result[3], expected -30000, got %0d", result);
        else
            $display("PASS: Result[3] = %0d", result);

            // Attempt to overwrite operand location 0
@(negedge clk);
oprand_we = 0;
oprand_write_addr = 0;
oprand_data = 8'sd99;

@(posedge clk);
#1;

// Read operand location 0
a_read_addr = 0;
#1;

if (oprandA !== 8'sd25)
    $display("FAIL: Operand write-enable test");
else
    $display("PASS: Operand retained its value = %0d", oprandA);

    // Write operand location 2 while reading location 0
@(negedge clk);
oprand_we = 1;
oprand_write_addr = 2;
oprand_data = 8'sd50;

a_read_addr = 0;
b_read_addr = 2;

@(posedge clk);
#1;

$display("Operand A = %0d", oprandA);
$display("Operand B = %0d", oprandB);

@(negedge clk);

oprand_we = 1;
oprand_write_addr = 3;
oprand_data = -8'sd40;

result_we = 1;
result_write_addr = 3;
result_data = 16'sd12000;

@(posedge clk);
#1;

oprand_we = 0;
result_we = 0;

a_read_addr = 3;
result_read_addr = 3;
#1;

if (oprandA === -8'sd40 && result === 16'sd12000)
    $display("PASS: Simultaneous operand and result writes");
else
    $display("FAIL: Simultaneous writes");

    $dumpfile("storage.vcd");
$dumpvars(0, storage_tb);
            $finish;

end



endmodule
