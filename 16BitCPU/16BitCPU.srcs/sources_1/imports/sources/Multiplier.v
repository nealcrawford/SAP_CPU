`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Neal Crawford
// Create Date: 07/16/2018 03:26:47 PM
// Module Name: Multiplier
// Description: Multiplies two 8-bit terms using shift and add method
//              yields 16-bit result. An operand over 255 will not yield a valid result!
// 
//////////////////////////////////////////////////////////////////////////////////


module Multiplier(IN_A, IN_B, OUT);

input [7:0] IN_A, IN_B;
output [15:0] OUT;

assign OUT = ((IN_B[0] * IN_A)) + 
               ((IN_B[1] * IN_A) << 1) +
               ((IN_B[2] * IN_A) << 2) +
               ((IN_B[3] * IN_A) << 3) +
               ((IN_B[4] * IN_A) << 4) +
               ((IN_B[5] * IN_A) << 5) +
               ((IN_B[6] * IN_A) << 6) +
               ((IN_B[7] * IN_A) << 7);

endmodule
