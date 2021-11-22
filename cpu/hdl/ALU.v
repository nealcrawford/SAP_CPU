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

input [6:0] SELECT;
input CLK, SLOW_CLOCK_STRB, ARST_L;
input EN;
input [15:0] R0_INPUT;
input [15:0] R1_INPUT;
input [15:0] R2_INPUT;
input [15:0] R3_INPUT;
output reg [15:0] OUT;

reg [6:0] select_0;
reg [7:0] mul_in_a, mul_in_b;
wire [15:0] mul_out;
reg [15:0] out_0;

Multiplier multiplier(.IN_A(mul_in_a), .IN_B(mul_in_b), .OUT(mul_out));

always @(posedge CLK or negedge ARST_L) begin : proc_select_0
    if(~ARST_L) begin
        select_0 <= 0;
    end else begin
        select_0 <= SELECT;
    end
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
    else if (SLOW_CLOCK_STRB == 1)
    begin
        if (EN == 1'b1) begin
            if (out_0[15] == 1'b1) // N: Set to MSB, (value of OUT[15], but cannot set directly equal to OUT[15]
                CONDITION_REG[3] <= 1'b1;
            else
                CONDITION_REG[3] <= 1'b0;
            if (out_0 == 16'h0000) // Z: Zero check
                CONDITION_REG[2] <= 1'b1;
            else
                CONDITION_REG[2] <= 1'b0;
            if (select_0[6:4] == 3'b000 || select_0[6:4] == 3'b010 || select_0[6:4] == 3'b101) begin // C: Unsigned overflow check
                if ((select_0[3:0] == 4'b0000) && out_0 < R0_INPUT)
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b0001) && (out_0 < R0_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b0010) && (out_0 < R0_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b0011) && (out_0 < R0_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b0100) && (out_0 < R1_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b0101) && (out_0 < R1_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b0110) && (out_0 < R1_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b0111) && (out_0 < R1_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b1000) && (out_0 < R2_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b1001) && (out_0 < R2_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b1010) && (out_0 < R2_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b1011) && (out_0 < R2_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b1100) && (out_0 < R3_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b1101) && (out_0 < R3_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b1110) && (out_0 < R3_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else if ((select_0[3:0] == 4'b1111) && (out_0 < R3_INPUT))
                    CONDITION_REG[1] <= 1'b1;
                else
                    CONDITION_REG[1] <= 1'b0;
            end else
                CONDITION_REG[1] <= 1'b0;
            if (select_0[6:4] == 3'b000 || select_0[6:4] == 3'b010 || select_0[6:4] == 3'b101) begin // V: Signed overflow check
                if ((select_0[3:0] == 4'b0000) && (R0_INPUT[15] ^ R0_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b0001) && (R0_INPUT[15] ^ R1_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b0010) && (R0_INPUT[15] ^ R2_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b0011) && (R0_INPUT[15] ^ R3_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b0100) && (R1_INPUT[15] ^ R0_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b0101) && (R1_INPUT[15] ^ R1_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b0110) && (R1_INPUT[15] ^ R2_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b0111) && (R1_INPUT[15] ^ R3_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b1000) && (R2_INPUT[15] ^ R0_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b1001) && (R2_INPUT[15] ^ R1_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b1010) && (R2_INPUT[15] ^ R2_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b1011) && (R2_INPUT[15] ^ R3_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b1100) && (R3_INPUT[15] ^ R0_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b1101) && (R3_INPUT[15] ^ R1_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b1110) && (R3_INPUT[15] ^ R2_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else if ((select_0[3:0] == 4'b1111) && (R3_INPUT[15] ^ R3_INPUT[15] != out_0[15]))
                    CONDITION_REG[0] <= 1'b1;
                else
                    CONDITION_REG[0] <= 1'b0;
            end else
                CONDITION_REG[0] <= 1'b0;
        end
    end
end

always @(posedge CLK, negedge ARST_L)
begin
    if (~ARST_L)
        OUT <= 0;
    else
        OUT <= out_0;
end

always @(posedge CLK, negedge ARST_L)
    begin
        if (~ARST_L)
            out_0 <= 16'h0000;
        else begin
            case (select_0)
                7'b000_0000: out_0 <= R0_INPUT + R0_INPUT;
                7'b000_0001: out_0 <= R0_INPUT + R1_INPUT;
                7'b000_0100: out_0 <= R0_INPUT + R1_INPUT; // Code in both combinations of addition here to avoid handling in compiler
                7'b000_0010: out_0 <= R0_INPUT + R2_INPUT;
                7'b000_1000: out_0 <= R0_INPUT + R2_INPUT;
                7'b000_0011: out_0 <= R0_INPUT + R3_INPUT;
                7'b000_1100: out_0 <= R0_INPUT + R3_INPUT;
                7'b000_0101: out_0 <= R1_INPUT + R1_INPUT;
                7'b000_0110: out_0 <= R1_INPUT + R2_INPUT;
                7'b000_1001: out_0 <= R1_INPUT + R2_INPUT;
                7'b000_0111: out_0 <= R1_INPUT + R3_INPUT;
                7'b000_1101: out_0 <= R1_INPUT + R3_INPUT;
                7'b000_1010: out_0 <= R2_INPUT + R2_INPUT;
                7'b000_1011: out_0 <= R2_INPUT + R3_INPUT;
                7'b000_1110: out_0 <= R2_INPUT + R3_INPUT;
                7'b000_1111: out_0 <= R3_INPUT + R3_INPUT;
             
                7'b001_0000: out_0 <= R0_INPUT - R0_INPUT;
                7'b001_0001: out_0 <= R0_INPUT - R1_INPUT;
                7'b001_0100: out_0 <= R1_INPUT - R0_INPUT;
                7'b001_0010: out_0 <= R0_INPUT - R2_INPUT;
                7'b001_1000: out_0 <= R2_INPUT - R0_INPUT;
                7'b001_0011: out_0 <= R0_INPUT - R3_INPUT;
                7'b001_1100: out_0 <= R3_INPUT - R0_INPUT;
                7'b001_0101: out_0 <= R1_INPUT - R1_INPUT;
                7'b001_0110: out_0 <= R1_INPUT - R2_INPUT;
                7'b001_1001: out_0 <= R2_INPUT - R1_INPUT;
                7'b001_0111: out_0 <= R1_INPUT - R3_INPUT;
                7'b001_1101: out_0 <= R3_INPUT - R1_INPUT;
                7'b001_1010: out_0 <= R2_INPUT - R2_INPUT;
                7'b001_1011: out_0 <= R2_INPUT - R3_INPUT;
                7'b001_1110: out_0 <= R3_INPUT - R2_INPUT;
                7'b001_1111: out_0 <= R3_INPUT - R3_INPUT;
            
                7'b010_0000: out_0 <= R0_INPUT << R0_INPUT;
                7'b010_0001: out_0 <= R0_INPUT << R1_INPUT;
                7'b010_0100: out_0 <= R1_INPUT << R0_INPUT;
                7'b010_0010: out_0 <= R0_INPUT << R2_INPUT;
                7'b010_1000: out_0 <= R2_INPUT << R0_INPUT;
                7'b010_0011: out_0 <= R0_INPUT << R3_INPUT;
                7'b010_1100: out_0 <= R3_INPUT << R0_INPUT;
                7'b010_0101: out_0 <= R1_INPUT << R1_INPUT;
                7'b010_0110: out_0 <= R1_INPUT << R2_INPUT;
                7'b010_1001: out_0 <= R2_INPUT << R1_INPUT;
                7'b010_0111: out_0 <= R1_INPUT << R3_INPUT;
                7'b010_1101: out_0 <= R3_INPUT << R1_INPUT;
                7'b010_1010: out_0 <= R2_INPUT << R2_INPUT;
                7'b010_1011: out_0 <= R2_INPUT << R3_INPUT;
                7'b010_1110: out_0 <= R3_INPUT << R2_INPUT;
                7'b010_1111: out_0 <= R3_INPUT << R3_INPUT;
             
                7'b011_0000: out_0 <= R0_INPUT >> R0_INPUT;
                7'b011_0001: out_0 <= R0_INPUT >> R1_INPUT;
                7'b011_0100: out_0 <= R1_INPUT >> R0_INPUT;
                7'b011_0010: out_0 <= R0_INPUT >> R2_INPUT;
                7'b011_1000: out_0 <= R2_INPUT >> R0_INPUT;
                7'b011_0011: out_0 <= R0_INPUT >> R3_INPUT;
                7'b011_1100: out_0 <= R3_INPUT >> R0_INPUT;
                7'b011_0101: out_0 <= R1_INPUT >> R1_INPUT;
                7'b011_0110: out_0 <= R1_INPUT >> R2_INPUT;
                7'b011_1001: out_0 <= R2_INPUT >> R1_INPUT;
                7'b011_0111: out_0 <= R1_INPUT >> R3_INPUT;
                7'b011_1101: out_0 <= R3_INPUT >> R1_INPUT;
                7'b011_1010: out_0 <= R2_INPUT >> R2_INPUT;
                7'b011_1011: out_0 <= R2_INPUT >> R3_INPUT;
                7'b011_1110: out_0 <= R3_INPUT >> R2_INPUT;
                7'b011_1111: out_0 <= R3_INPUT >> R3_INPUT;
                
                7'b100_0000: out_0 <= R0_INPUT >>> R0_INPUT;
                7'b100_0001: out_0 <= R0_INPUT >>> R1_INPUT;
                7'b100_0100: out_0 <= R1_INPUT >>> R0_INPUT;
                7'b100_0010: out_0 <= R0_INPUT >>> R2_INPUT;
                7'b100_1000: out_0 <= R2_INPUT >>> R0_INPUT;
                7'b100_0011: out_0 <= R0_INPUT >>> R3_INPUT;
                7'b100_1100: out_0 <= R3_INPUT >>> R0_INPUT;
                7'b100_0101: out_0 <= R1_INPUT >>> R1_INPUT;
                7'b100_0110: out_0 <= R1_INPUT >>> R2_INPUT;
                7'b100_1001: out_0 <= R2_INPUT >>> R1_INPUT;
                7'b100_0111: out_0 <= R1_INPUT >>> R3_INPUT;
                7'b100_1101: out_0 <= R3_INPUT >>> R1_INPUT;
                7'b100_1010: out_0 <= R2_INPUT >>> R2_INPUT;
                7'b100_1011: out_0 <= R2_INPUT >>> R3_INPUT;
                7'b100_1110: out_0 <= R3_INPUT >>> R2_INPUT;
                7'b100_1111: out_0 <= R3_INPUT >>> R3_INPUT;

                7'b101_0000: out_0 <= mul_out;
                7'b101_0001: out_0 <= mul_out;
                7'b101_0100: out_0 <= mul_out;
                7'b101_0010: out_0 <= mul_out;
                7'b101_1000: out_0 <= mul_out;
                7'b101_0011: out_0 <= mul_out;
                7'b101_1100: out_0 <= mul_out;
                7'b101_0101: out_0 <= mul_out;
                7'b101_0110: out_0 <= mul_out;
                7'b101_1001: out_0 <= mul_out;
                7'b101_0111: out_0 <= mul_out;
                7'b101_1101: out_0 <= mul_out;
                7'b101_1010: out_0 <= mul_out;
                7'b101_1011: out_0 <= mul_out;
                7'b101_1110: out_0 <= mul_out;
                7'b101_1111: out_0 <= mul_out;
                default: out_0 <= 16'h0000;
            endcase // SELECT
        end
    end

always @(*) begin : proc_mul_in
    case(select_0)
        7'b101_0000: begin
            mul_in_a = R0_INPUT;
            mul_in_b = R0_INPUT;
        end
        7'b101_0001: begin
            mul_in_a = R0_INPUT;
            mul_in_b = R1_INPUT;
        end
        7'b101_0100: begin
            mul_in_a = R1_INPUT;
            mul_in_b = R0_INPUT;
        end
        7'b101_0010: begin
            mul_in_a = R0_INPUT;
            mul_in_b = R2_INPUT;
        end
        7'b101_1000: begin
            mul_in_a = R2_INPUT;
            mul_in_b = R0_INPUT;
        end
        7'b101_0011: begin
            mul_in_a = R0_INPUT;
            mul_in_b = R3_INPUT;
        end
        7'b101_1100: begin
            mul_in_a = R3_INPUT;
            mul_in_b = R0_INPUT;
        end
        7'b101_0101: begin
            mul_in_a = R1_INPUT;
            mul_in_b = R1_INPUT;
        end
        7'b101_0110:  begin
            mul_in_a = R1_INPUT;
            mul_in_b = R2_INPUT;
        end
        7'b101_1001:  begin
            mul_in_a = R2_INPUT;
            mul_in_b = R1_INPUT;
        end
        7'b101_0111:  begin
            mul_in_a = R1_INPUT;
            mul_in_b = R3_INPUT;
        end
        7'b101_1101:  begin
            mul_in_a = R3_INPUT;
            mul_in_b = R1_INPUT;
        end
        7'b101_1010:  begin
            mul_in_a = R2_INPUT;
            mul_in_b = R2_INPUT;
        end
        7'b101_1011:  begin
            mul_in_a = R2_INPUT;
            mul_in_b = R3_INPUT;
        end
        7'b101_1110:  begin
            mul_in_a = R3_INPUT;
            mul_in_b = R2_INPUT;
        end
        7'b101_1111:  begin
            mul_in_a = R3_INPUT;
            mul_in_b = R3_INPUT;
        end
        default: begin
            mul_in_a = 16'h0000;
            mul_in_b = 16'h0000;
        end
    endcase // SELECT
end
endmodule
