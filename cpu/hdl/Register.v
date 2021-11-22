`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Neal Crawford
// Create Date: 08/19/2018 01:01:24 PM
// Module Name: Register
// Description: Model for general purpose registers, 'output' register, and instruction register
// 
//////////////////////////////////////////////////////////////////////////////////


module Register(CLK, SLOW_CLOCK_STRB, ACLR_L, IN, OUT, IN_EN, MOV_EN);

input CLK, SLOW_CLOCK_STRB, ACLR_L, IN_EN, MOV_EN;
input [15:0] IN;
output reg [15:0] OUT;
reg [15:0] q_i;

always @(posedge CLK, negedge ACLR_L)
    begin
        if (ACLR_L == 1'b0)
            q_i <= 16'h0000;
        else if (SLOW_CLOCK_STRB == 1)
        begin
            if (IN_EN == 1'b1)
                q_i <= IN;
            else if (MOV_EN == 1'b1)
                q_i <= IN[7:0];
            else ;
        end
    end

always @(posedge CLK or negedge ACLR_L) begin : proc_OUT
    if(~ACLR_L) begin
        OUT <= 0;
    end else begin
        OUT <= q_i;
    end
end

endmodule
