`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Neal Crawford
// Create Date: 08/19/2018 12:58:55 PM
// Module Name: Top
// Description: 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Top(CLK, ARST_L, HALT, SYS_OUT);

input CLK, ARST_L, HALT;

output [15:0] SYS_OUT;

wire [15:0] bus;

// CPU CONTROL SIGNALS ------------------------
//RAM
wire ram_in, ram_out, ram_wr; // (ram_wr - which means enable ability to program ram)

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

wire [15:0] r0_bus, r1_bus, r2_bus, r3_bus, ir_bus, ram_bus, alu_bus;
wire [7:0] pc_bus, ram_in_bus;

// ---------------------------------------------

assign bus = (r0_out == 1'b1) ? r0_bus : (r1_out == 1'b1) ? r1_bus : (r2_out == 1'b1) ? r2_bus : (r3_out == 1'b1) ? r3_bus : (ir_out == 1'b1) ? ir_bus
 : (alu_en == 1'b1) ? alu_bus : (ram_out == 1'b1) ? ram_bus : (pc_out == 1'b1) ? {8'h00, pc_bus} : 16'bzzzz;

Register r0(
    .CLK(CLK),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(r0_bus),
    .IN_EN(r0_in),
    .MOV_EN(r0_mov)
);

Register r1(
    .CLK(CLK),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(r1_bus),
    .IN_EN(r1_in),
    .MOV_EN(r1_mov)
);

Register r2(
    .CLK(CLK),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(r2_bus),
    .IN_EN(r2_in),
    .MOV_EN(r2_mov)
);

Register r3(
    .CLK(CLK),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(r3_bus),
    .IN_EN(r3_in),
    .MOV_EN(r3_mov)
);

Register instruction_reg(
    .CLK(CLK),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(ir_bus),
    .IN_EN(ir_in),
    .MOV_EN()
);

ALU alu(
    .SELECT(alu_sel),
    .R0_INPUT(r0_bus),
    .R1_INPUT(r1_bus),
    .R2_INPUT(r2_bus),
    .R3_INPUT(r3_bus),
    .OUT(alu_bus)
);

RAM ram(
    .CLK(CLK),
    .RAM_IN(ram_in),
    .WRITE_EN(ram_wr),
    .DATA_IN(bus),
    .ADDRESS(bus[7:0]),
    .DATA_OUT(ram_bus)
);

ProgramCounter pc(
    .CLK(CLK),
    .ACLR_L(ARST_L),
    .BRANCH(branch),
    .PC_COUNT(pc_count),
    .BRANCH_ADDRESS(bus[7:0]),
    .PC_VAL(pc_bus)
);

CPULogic cpu_logic(
    .CLK(CLK),
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
    .branch(branch),
    .HALT(HALT)
);

Register out(
    .CLK(CLK),
    .ACLR_L(ARST_L),
    .IN(bus),
    .OUT(SYS_OUT),
    .IN_EN(out_in),
    .MOV_EN()
);
endmodule