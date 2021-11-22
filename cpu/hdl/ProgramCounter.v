`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Neal Crawford
// Create Date: 08/20/2018 11:25:16 PM
// Module Name: ProgramCounter
// Description: Basic counter with ability to branch to given address
// 
//////////////////////////////////////////////////////////////////////////////////

module ProgramCounter(CLK, SLOW_CLOCK_STRB, ACLR_L, BRANCH, PC_COUNT, BRANCH_ADDRESS, PC_VAL);

input CLK, SLOW_CLOCK_STRB, ACLR_L, BRANCH, PC_COUNT;

input [7:0] BRANCH_ADDRESS;
output [7:0] PC_VAL;

reg [7:0] pc_i;
reg [7:0] PC_VAL;

always @(posedge CLK, negedge ACLR_L)
    begin
        if (ACLR_L == 1'b0)
            pc_i <= 0;
        else if (SLOW_CLOCK_STRB == 1)
        begin
            if (PC_COUNT == 1'b1)
                pc_i <= pc_i + 1;
            else if (BRANCH == 1'b1)
                pc_i <= BRANCH_ADDRESS;
            else ;
        end
    end

always @(posedge CLK or negedge ACLR_L) begin : proc_PC_VAL
    if(~ACLR_L) begin
        PC_VAL <= 0;
    end else begin
        PC_VAL <= pc_i;
    end
end

endmodule