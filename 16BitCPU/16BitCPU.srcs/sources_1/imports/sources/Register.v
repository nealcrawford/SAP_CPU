`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// Create Date: 08/19/2018 01:01:24 PM
// Module Name: Register
// Project Name: 
// Description: 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Register(CLK, ACLR_L, IN, OUT, IN_EN, MOV_EN);

input CLK, ACLR_L, IN_EN, MOV_EN;
input [15:0] IN;
output [15:0] OUT;
reg [15:0] q_i; // Constant output of register value to modules such as ALU

assign OUT = q_i;

always @(posedge CLK, negedge ACLR_L)
    begin
        if (ACLR_L == 1'b0)
            q_i <= 16'h0000;
        else if (IN_EN == 1'b1)
            q_i <= IN;
        else if (MOV_EN == 1'b1)
            q_i <= IN[7:0];
        else ;
    end

endmodule
