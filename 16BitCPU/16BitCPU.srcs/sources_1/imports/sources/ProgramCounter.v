`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Neal Crawford
// Create Date: 08/20/2018 11:25:16 PM
// Module Name: ProgramCounter
// Description: 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ProgramCounter(CLK, ACLR_L, BRANCH, PC_COUNT, BRANCH_ADDRESS, PC_VAL);

input CLK, ACLR_L, BRANCH, PC_COUNT;

input [7:0] BRANCH_ADDRESS;
output [7:0] PC_VAL;

reg [7:0] pc_i;

assign PC_VAL = pc_i;

always @(posedge CLK, negedge ACLR_L)
    begin
        if (ACLR_L == 1'b0)
            pc_i <= 0;
        else if (PC_COUNT == 1'b1)
            pc_i <= pc_i + 1;
        else if (BRANCH == 1'b1)
            pc_i <= BRANCH_ADDRESS;
        else ;
    end

endmodule