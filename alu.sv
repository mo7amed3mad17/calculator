module alu(

// Inputs
input logic signed [7:0] oprandA,
input logic signed [7:0] oprandB,
input logic        [1:0] op,

// Outputs
output logic signed [15:0] result,
output logic               zero_f
);

logic signed [15:0] extA;
logic signed [15:0] extB;

assign extA = {{8{oprandA[7]}}, oprandA};
assign extB = {{8{oprandB[7]}}, oprandB};

always_comb begin
    result = 16'sd0;
    zero_f = 1'b0;

    case (op)
        2'b00 : begin
        result = extA + extB;
        end

        2'b01 : begin
        result = extA - extB;
        end

        2'b10 : begin
        result = extA * extB;
        end

        2'b11 : begin
            if (extB == 16'd0) begin
                zero_f = 1'b1;
                result = 16'sd0;
            end
            else begin
                result = extA / extB;
            end
        end

        default: begin
           result = 16'sd0;
        end
    endcase
end


endmodule
