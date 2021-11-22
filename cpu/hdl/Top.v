`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Neal Crawford
// Create Date: 08/19/2018 12:58:55 PM
// Module Name: Top
// Description: Top level module of the 16 bit processor
//              Output handled by a register constantly pushing contents to SYS_OUT
//              
//              Supported instructions:
//              LDR - Load value from memory to register
//              STR - Store value from register to memory
//              MOV - Move immediate into register
//              ADD - Add two registers
//              SUB - Subtract two registers
//              LSL - Logical shift left
//              LSR - Logical shift right
//              ASR - Arithmetic shift right
//              MUL - Multiply two registers
//              B   - Branch to new instrcution
//              OUT - Output contents of register
//////////////////////////////////////////////////////////////////////////////////

module Top(CLK, SLOW_CLOCK_STRB, ARST_L, HALT, SYS_OUT);

input CLK, SLOW_CLOCK_STRB, ARST_L, HALT;

output [15:0] SYS_OUT;

wire [15:0] bus;

// CPU CONTROL SIGNALS ------------------------
//RAM
wire ram_in, ram_out, ram_wr; // RAM enable signals to input an address, output contents at given address, or write to given address

// Program Counter
wire branch, pc_out, pc_count;

// Registers 1, 2, IR, OUT
wire r0_in, r1_in, r2_in, r3_in;
wire r0_out, r1_out, r2_out, r3_out;
wire r0_mov, r1_mov, r2_mov, r3_mov;
wire ir_in, ir_out;
wire out_in;

// ALU
wire alu_en;
wire [6:0] alu_sel;
wire [3:0] condition_bus;



wire [15:0] r0_bus, r1_bus, r2_bus, r3_bus, ir_bus, ram_bus, alu_bus;
wire [7:0] pc_bus, ram_in_bus;

// ---------------------------------------------

// Data is passed between modules through this 16 bit bus
assign bus = (r0_out == 1'b1) ? r0_bus : (r1_out == 1'b1) ? r1_bus : (r2_out == 1'b1) ? r2_bus : (r3_out == 1'b1) ? r3_bus : (ir_out == 1'b1) ? ir_bus
 : (alu_en == 1'b1) ? alu_bus : (ram_out == 1'b1) ? ram_bus : (pc_out == 1'b1) ? {8'h00, pc_bus} : 16'h0000;

Register r0(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(r0_bus),
    .IN_EN(r0_in),
    .MOV_EN(r0_mov)
);

Register r1(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(r1_bus),
    .IN_EN(r1_in),
    .MOV_EN(r1_mov)
);

Register r2(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(r2_bus),
    .IN_EN(r2_in),
    .MOV_EN(r2_mov)
);

Register r3(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(r3_bus),
    .IN_EN(r3_in),
    .MOV_EN(r3_mov)
);

Register instruction_reg(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(ir_bus),
    .IN_EN(ir_in),
    .MOV_EN() // No current application for moving immediate into instruction register
);

ALU alu(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ARST_L(ARST_L),
    .SELECT(alu_sel),
    .EN(alu_en),
    .R0_INPUT(r0_bus),
    .R1_INPUT(r1_bus),
    .R2_INPUT(r2_bus),
    .R3_INPUT(r3_bus),
    .OUT(alu_bus),
    .CONDITION_REG(condition_bus)
);

RAM ram(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .RAM_IN(ram_in),
    .WRITE_EN(ram_wr),
    .DATA_IN(bus),
    .ADDRESS(bus[7:0]),
    .DATA_OUT(ram_bus)
);

ProgramCounter pc(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ACLR_L(ARST_L),
    .BRANCH(branch),
    .PC_COUNT(pc_count),
    .BRANCH_ADDRESS(bus[7:0]),
    .PC_VAL(pc_bus)
);

CPULogic cpu_logic(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ARST_L(ARST_L),
    .FULL_OPCODE(ir_bus[15:6]), 
    .ram_in(ram_in), 
    .ram_out(ram_out),
    .ram_wr(ram_wr),
    .pc_out(pc_out),
    .pc_count(pc_count),
    .ir_in(ir_in),
    .ir_out(ir_out),
    .r0_in(r0_in),
    .r1_in(r1_in),
    .r2_in(r2_in),
    .r3_in(r3_in),
    .r0_out(r0_out),
    .r1_out(r1_out),
    .r2_out(r2_out),
    .r3_out(r3_out),
    .r0_mov(r0_mov),
    .r1_mov(r1_mov),
    .r2_mov(r2_mov),
    .r3_mov(r3_mov),
    .out_in(out_in),
    .alu_en(alu_en),
    .alu_sel(alu_sel),
    .condition_flags(condition_bus),
    .branch(branch),
    .HALT(HALT)
);

Register out(
    .CLK(CLK),
    .SLOW_CLOCK_STRB(SLOW_CLOCK_STRB),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(SYS_OUT),
    .IN_EN(out_in),
    .MOV_EN() // No current application for moving immediate into output register
);
endmodule
