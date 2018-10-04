`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2018 06:49:43 PM
// Design Name: 
// Module Name: CPUTestBench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module CPUTestBench();

reg CLK, ARST_L, HALT;

wire [15:0] bus;

wire [15:0] SYS_OUT;

Top DUT(.CLK(CLK), .ARST_L(ARST_L), .HALT(HALT), .SYS_OUT(SYS_OUT));

initial begin
    HALT = 1;
    ARST_L = 1'b0;
    CLK = 1'b0;
    forever #15 CLK = ~CLK;
end

initial begin 
    #10;
    HALT = 0;
    ARST_L =  1'b1;
end



endmodule
