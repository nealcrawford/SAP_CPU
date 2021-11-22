`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Neal Crawford
// Create Date: 08/20/2018 04:28:35 PM
// Module Name: RAM
//////////////////////////////////////////////////////////////////////////////////


module RAM(CLK, SLOW_CLOCK_STRB, RAM_IN, WRITE_EN, DATA_IN, ADDRESS, DATA_OUT);

input CLK, SLOW_CLOCK_STRB, RAM_IN, WRITE_EN;
input [7:0] ADDRESS;
input [15:0] DATA_IN;

output [15:0] DATA_OUT;

reg [7:0] address_reg_i;

reg [15:0] memory[255:0];

//Change to absolute path if vivado isn't able to open
initial begin
    $readmemh("../../../../../../../../srcs/Example_program.mem", memory, 0);
end

always @(posedge CLK)
    begin
        if (SLOW_CLOCK_STRB == 1)
        begin
            if (RAM_IN == 1'b1)
                address_reg_i <= ADDRESS;
        end
        else ;
    end

assign DATA_OUT = memory[address_reg_i];

always @(posedge CLK)
    begin
        if (SLOW_CLOCK_STRB == 1)
        begin  
            if (WRITE_EN == 1'b1)
                memory[address_reg_i] <= DATA_IN;
            else ;
        end
    end


endmodule
