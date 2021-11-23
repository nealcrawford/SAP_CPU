`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////// 
// Author: Neal Crawford
// Create Date: 08/19/2018 01:01:06 PM
// Module Name: ALU
// Description: Current support for
//              add, subtract, multiply, logical left and right shifts, arithmetic right shifts
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU(CLK, SLOW_CLOCK_STRB, ARST_L, SELECT, EN, R0_INPUT, R1_INPUT, R2_INPUT, R3_INPUT, OUT, CONDITION_REG);

input [7:0] SELECT;
input CLK, SLOW_CLOCK_STRB, ARST_L;
input EN;
input [15:0] R0_INPUT;
input [15:0] R1_INPUT;
input [15:0] R2_INPUT;
input [15:0] R3_INPUT;
output reg [15:0] OUT;

wire [15:0] mul_out;
reg [15:0] in_a;
reg [15:0] in_b;
wire [3:0] reg_sel = SELECT[3:0];

Multiplier multiplier(.IN_A(in_a), .IN_B(in_b), .OUT(mul_out));

always @(*) begin
    case (reg_sel[3:2])
        2'b00:
            in_a = R0_INPUT;
        2'b01:
            in_a = R1_INPUT;
        2'b10:
            in_a = R2_INPUT;
        2'b11:
            in_a = R3_INPUT;
        default : in_a = 16'h0000;
    endcase
    case (reg_sel[1:0])
        2'b00:
            in_b = R0_INPUT;
        2'b01:
            in_b = R1_INPUT;
        2'b10:
            in_b = R2_INPUT;
        2'b11:
            in_b = R3_INPUT;
        default : in_b = 16'h0000;
    endcase
end

// N: If MSB is set, N is set
// Z: If result is zero, Z is set
// C: If adding, and result is smaller than one of the operands, C is set
// V: If product of signs of operands do not match sign of result, V is set
output reg [3:0] CONDITION_REG; // N,Z,C,V

always @(posedge CLK, negedge ARST_L)
begin
    if (ARST_L == 1'b0)
        CONDITION_REG <= 4'h0;
    else if (SLOW_CLOCK_STRB == 1) begin
        if (EN == 1'b1) begin
            if (OUT[15] == 1'b1) // N: Set to MSB, (value of OUT[15], but cannot set directly equal to OUT[15]
                CONDITION_REG[3] <= 1'b1;
            else
                CONDITION_REG[3] <= 1'b0;
            if (OUT == 16'h0000) // Z: Zero check
                CONDITION_REG[2] <= 1'b1;
            else
                CONDITION_REG[2] <= 1'b0;
            if (SELECT[7:4] == 4'b0100 || SELECT[7:4] == 4'b0110 || SELECT[7:4] == 4'b1001) begin // C: Unsigned overflow check on add, lsl, mul
                if (OUT < in_a)
                    CONDITION_REG[1] <= 1'b1;
                else if (OUT < in_b)
                    CONDITION_REG[1] <= 1'b1;
                else
                    CONDITION_REG[1] <= 1'b0;
            end else
                CONDITION_REG[1] <= 1'b0;
            if (SELECT[7:4] == 4'b0100 || SELECT[7:4] == 4'b0110 || SELECT[7:4] == 4'b1001) begin // V: Signed overflow check on add, lsl, mul
                if (in_a[15] ^ in_b[15] != OUT[15])
                    CONDITION_REG[0] <= 1'b1;
                else
                    CONDITION_REG[0] <= 1'b0;
            end else
                CONDITION_REG[0] <= 1'b0;
        end
    end
end

// always @(posedge CLK, negedge ARST_L)
// begin
//     if (~ARST_L)
//         OUT <= 0;
//     else
//         OUT <= OUT;
// end

always @(*) begin
    if (EN == 1'b1) begin
        case (SELECT[7:4])
            4'b0100: OUT = in_a + in_b;
            4'b0101: OUT = in_a - in_b;
            4'b0110: OUT = in_a << in_b;
            4'b0111: OUT = in_a >> in_b;
            4'b1000: OUT = in_a >>> in_b;
            4'b1001: OUT = mul_out;
            default: OUT = 16'h0000;
        endcase // SELECT
    end
    else
        OUT = 16'h0000;
end

endmodule
