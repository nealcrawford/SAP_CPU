`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Neal Crawford
// Create Date: 08/20/2018 04:28:35 PM
// Module Name: RAM
//////////////////////////////////////////////////////////////////////////////////


module RAM(CLK, SLOW_CLOCK_STRB, WRITE_EN, DATA_IN, ADDRESS, DATA_OUT);

input CLK, SLOW_CLOCK_STRB, WRITE_EN;
input [7:0] ADDRESS;
input [15:0] DATA_IN;

output reg [15:0] DATA_OUT;

reg [15:0] memory[255:0];

initial begin
    $readmemh("C:/Users/ncraw/OneDrive/Documents/CodingProjects/CPUExample/srcs/Example_program.mem", memory, 0);//
end

always @(posedge CLK)
    begin
        if (SLOW_CLOCK_STRB == 1) begin
            if (WRITE_EN == 1'b1)
                memory[ADDRESS] <= DATA_IN;
            else
                DATA_OUT <= memory[ADDRESS];
        end
        else ;
    end

endmodule
