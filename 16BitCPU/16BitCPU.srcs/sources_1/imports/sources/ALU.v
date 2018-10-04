`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Engineer: Neal Crawford
// Create Date: 08/19/2018 01:01:06 PM
// Module Name: ALU
// Description: 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU(SELECT, R0_INPUT, R1_INPUT, R2_INPUT, R3_INPUT, OUT);

input [6:0] SELECT;
input [15:0] R0_INPUT;
input [15:0] R1_INPUT;
input [15:0] R2_INPUT;
input [15:0] R3_INPUT;
output reg [15:0] OUT;

reg [7:0] mul_in_a, mul_in_b;
wire [15:0] mul_out;

Multiplier multiplier(.IN_A(mul_in_a), .IN_B(mul_in_b), .OUT(mul_out));

always @(*)
    begin
        mul_in_a = 8'hzz;
        mul_in_b = 8'hzz;
        case (SELECT)
            7'b000_0000: OUT = R0_INPUT + R0_INPUT;
            7'b000_0001: OUT = R0_INPUT + R1_INPUT;
            7'b000_0010: OUT = R0_INPUT + R2_INPUT;
            7'b000_0011: OUT = R0_INPUT + R3_INPUT;
            7'b000_0101: OUT = R1_INPUT + R1_INPUT;
            7'b000_0110: OUT = R1_INPUT + R2_INPUT;
            7'b000_0111: OUT = R1_INPUT + R3_INPUT;
            7'b000_1010: OUT = R2_INPUT + R2_INPUT;
            7'b000_1011: OUT = R2_INPUT + R3_INPUT;
            7'b000_1111: OUT = R3_INPUT + R3_INPUT;
            
            7'b001_0000: OUT = R0_INPUT - R0_INPUT;
            7'b001_0001: OUT = R0_INPUT - R1_INPUT;
            7'b001_0100: OUT = R1_INPUT - R0_INPUT;
            7'b001_0010: OUT = R0_INPUT - R2_INPUT;
            7'b001_1000: OUT = R2_INPUT - R0_INPUT;
            7'b001_0011: OUT = R0_INPUT - R3_INPUT;
            7'b001_1100: OUT = R3_INPUT - R0_INPUT;
            7'b001_0101: OUT = R1_INPUT - R1_INPUT;
            7'b001_0110: OUT = R1_INPUT - R2_INPUT;
            7'b001_1001: OUT = R2_INPUT - R1_INPUT;
            7'b001_0111: OUT = R1_INPUT - R3_INPUT;
            7'b001_1101: OUT = R3_INPUT - R1_INPUT;
            7'b001_1010: OUT = R2_INPUT - R2_INPUT;
            7'b001_1011: OUT = R2_INPUT - R3_INPUT;
            7'b001_1110: OUT = R3_INPUT - R2_INPUT;
            7'b001_1111: OUT = R3_INPUT - R3_INPUT;

            7'b010_0000: OUT = R0_INPUT << R0_INPUT;
            7'b010_0001: OUT = R0_INPUT << R1_INPUT;
            7'b010_0100: OUT = R1_INPUT << R0_INPUT;
            7'b010_0010: OUT = R0_INPUT << R2_INPUT;
            7'b010_1000: OUT = R2_INPUT << R0_INPUT;
            7'b010_0011: OUT = R0_INPUT << R3_INPUT;
            7'b010_1100: OUT = R3_INPUT << R0_INPUT;
            7'b010_0101: OUT = R1_INPUT << R1_INPUT;
            7'b010_0110: OUT = R1_INPUT << R2_INPUT;
            7'b010_1001: OUT = R2_INPUT << R1_INPUT;
            7'b010_0111: OUT = R1_INPUT << R3_INPUT;
            7'b010_1101: OUT = R3_INPUT << R1_INPUT;
            7'b010_1010: OUT = R2_INPUT << R2_INPUT;
            7'b010_1011: OUT = R2_INPUT << R3_INPUT;
            7'b010_1110: OUT = R3_INPUT << R2_INPUT;
            7'b010_1111: OUT = R3_INPUT << R3_INPUT;
            
            7'b011_0000: OUT = R0_INPUT >> R0_INPUT;
            7'b011_0001: OUT = R0_INPUT >> R1_INPUT;
            7'b011_0100: OUT = R1_INPUT >> R0_INPUT;
            7'b011_0010: OUT = R0_INPUT >> R2_INPUT;
            7'b011_1000: OUT = R2_INPUT >> R0_INPUT;
            7'b011_0011: OUT = R0_INPUT >> R3_INPUT;
            7'b011_1100: OUT = R3_INPUT >> R0_INPUT;
            7'b011_0101: OUT = R1_INPUT >> R1_INPUT;
            7'b011_0110: OUT = R1_INPUT >> R2_INPUT;
            7'b011_1001: OUT = R2_INPUT >> R1_INPUT;
            7'b011_0111: OUT = R1_INPUT >> R3_INPUT;
            7'b011_1101: OUT = R3_INPUT >> R1_INPUT;
            7'b011_1010: OUT = R2_INPUT >> R2_INPUT;
            7'b011_1011: OUT = R2_INPUT >> R3_INPUT;
            7'b011_1110: OUT = R3_INPUT >> R2_INPUT;
            7'b011_1111: OUT = R3_INPUT >> R3_INPUT;
            
            7'b100_0000: OUT = R0_INPUT >>> R0_INPUT;
            7'b100_0001: OUT = R0_INPUT >>> R1_INPUT;
            7'b100_0100: OUT = R1_INPUT >>> R0_INPUT;
            7'b100_0010: OUT = R0_INPUT >>> R2_INPUT;
            7'b100_1000: OUT = R2_INPUT >>> R0_INPUT;
            7'b100_0011: OUT = R0_INPUT >>> R3_INPUT;
            7'b100_1100: OUT = R3_INPUT >>> R0_INPUT;
            7'b100_0101: OUT = R1_INPUT >>> R1_INPUT;
            7'b100_0110: OUT = R1_INPUT >>> R2_INPUT;
            7'b100_1001: OUT = R2_INPUT >>> R1_INPUT;
            7'b100_0111: OUT = R1_INPUT >>> R3_INPUT;
            7'b100_1101: OUT = R3_INPUT >>> R1_INPUT;
            7'b100_1010: OUT = R2_INPUT >>> R2_INPUT;
            7'b100_1011: OUT = R2_INPUT >>> R3_INPUT;
            7'b100_1110: OUT = R3_INPUT >>> R2_INPUT;
            7'b100_1111: OUT = R3_INPUT >>> R3_INPUT;
            
            7'b101_0000: begin
                mul_in_a = R0_INPUT;
                mul_in_b = R0_INPUT;
                OUT = mul_out;
            end
            7'b101_0001: begin
                mul_in_a = R0_INPUT;
                mul_in_b = R1_INPUT;
                OUT = mul_out;
            end
            7'b101_0100: begin
                mul_in_a = R1_INPUT;
                mul_in_b = R0_INPUT;
                OUT = mul_out;
            end
            7'b101_0010: begin
                mul_in_a = R0_INPUT;
                mul_in_b = R2_INPUT;
                OUT = mul_out;
            end
            7'b101_1000: begin
                mul_in_a = R2_INPUT;
                mul_in_b = R0_INPUT;
                OUT = mul_out;
            end
            7'b101_0011: begin
                mul_in_a = R0_INPUT;
                mul_in_b = R3_INPUT;
                OUT = mul_out;
            end
            7'b101_1100: begin
                mul_in_a = R3_INPUT;
                mul_in_b = R0_INPUT;
                OUT = mul_out;
            end
            7'b101_0101: begin
                mul_in_a = R1_INPUT;
                mul_in_b = R1_INPUT;
                OUT = mul_out;
            end
            7'b101_0110:  begin
                mul_in_a = R1_INPUT;
                mul_in_b = R2_INPUT;
                OUT = mul_out;
            end
            7'b101_1001:  begin
                mul_in_a = R2_INPUT;
                mul_in_b = R1_INPUT;
                OUT = mul_out;
            end
            7'b101_0111:  begin
                mul_in_a = R1_INPUT;
                mul_in_b = R3_INPUT;
                OUT = mul_out;
            end
            7'b101_1101:  begin
                mul_in_a = R3_INPUT;
                mul_in_b = R1_INPUT;
                OUT = mul_out;
            end
            7'b101_1010:  begin
                mul_in_a = R2_INPUT;
                mul_in_b = R2_INPUT;
                OUT = mul_out;
            end
            7'b101_1011:  begin
                mul_in_a = R2_INPUT;
                mul_in_b = R3_INPUT;
                OUT = mul_out;
            end
            7'b101_1110:  begin
                mul_in_a = R3_INPUT;
                mul_in_b = R2_INPUT;
                OUT = mul_out;
            end
            7'b101_1111:  begin
                mul_in_a = R3_INPUT;
                mul_in_b = R3_INPUT;
                OUT = mul_out;
            end
            
            default: OUT = 16'h0000;
            
        endcase
    end
    
endmodule
