`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Neal Crawford
// Create Date: 08/20/2018 06:50:49 PM
// Module Name: CPULogic
// Description: Opcodes are fetched and decoded here to control enable signals
//              for relevant modules addressed by the current instruction.
// 
//              This module employs two state machines:
//                  -One fetches new instructions after the previous instruction has executed
//
//                  -The other controls the timing of signal assertions, and takes care of instructions
//                   that take more than a single cycle to execute (currently the load and store instructions).
//                   This state machine enters a dormant state as the next instruction is fetched.
// 
//////////////////////////////////////////////////////////////////////////////////

module CPULogic(
                CLK, ARST_L, FULL_OPCODE, 
                ram_in, ram_out, ram_wr, 
                pc_out, pc_count, 
                ir_in, ir_out, 
                r0_in, r0_mov, r0_out, 
                r1_in, r1_mov,  r1_out,
                r2_in, r2_mov,  r2_out,
                r3_in, r3_mov,  r3_out,
                out_in,
                alu_en, alu_sel,
                branch,
                HALT
);

input CLK, ARST_L, HALT;
input [9:0] FULL_OPCODE;

output ram_in, ram_out, ram_wr;
output pc_out, pc_count;
output ir_in, ir_out;
output r0_in, r0_mov, r0_out;
output r1_in, r1_mov, r1_out;
output r2_in, r2_mov, r2_out;
output r3_in, r3_mov, r3_out;
output out_in;
output alu_en;
output [6:0] alu_sel;
output branch;

reg [1:0] fetch_step;
reg [1:0] next_fetch_step;
wire fetch_new;

wire [7:0] OPCODE;
assign OPCODE = FULL_OPCODE[9:2];

//---------------- INSTRUCTION FETCHING ----------------------------------------------

always @(posedge CLK, negedge ARST_L)
    begin
        if (ARST_L == 1'b0)
            fetch_step <= 2'b00;
        else 
            fetch_step <= next_fetch_step;
    end

always @(fetch_step, fetch_new, HALT)
    begin
        casez ({fetch_step, fetch_new, HALT})
            4'b00_?_0: next_fetch_step <= 2'b01;   // PC out, ram in
            4'b01_?_0: next_fetch_step <= 2'b11;   // ram out, ir in, pc count
            4'b11_0_0: next_fetch_step <= 2'b11;   // HOLD, no fetch assertions
            4'b11_1_0: next_fetch_step <= 2'b00;   // Begin fetching new instruction
            4'b??_?_1: next_fetch_step <= 2'b00;   // Processor HALT, only clock active
            default: next_fetch_step <= 2'b11;
        endcase
    end

// ---------------------------------------------------------------------------------

reg [1:0] op_step;
reg [1:0] next_op_step;

always @(posedge CLK, negedge ARST_L)
    begin
        if (ARST_L == 1'b0)
            op_step <= 2'b11; // No instruction loaded upon reset, so begin in dormant state
        else
            op_step <= next_op_step;
    end

always @(OPCODE, op_step, fetch_step)
    begin
        if (fetch_step == 2'b01)
            next_op_step <= 2'b00; // New instruction has been fetched, can now execute it
        else begin
            casez ({OPCODE, op_step})
                // ---------LDR----------------------
                11'b0000_????_00: next_op_step <= 2'b01; // REG out, RAM in (Access location in RAMs)
                11'b0000_????_01: next_op_step <= 2'b11; // RAM out, REG in
                // ----------------------------------
                
                // ---------STR----------------------
                11'b0001_????_00: next_op_step <= 2'b01; // REG (address) out, RAM in
                11'b0001_????_01: next_op_step <= 2'b11; // RAM wr, REG (contents) out
                // -----------------------------------
                
                // ---------MOV----------------------
                11'b0010_????_00: next_op_step <= 2'b11; // register mov en, IR out
                // ----------------------------------
                
                // ---------ADD----------------------
                11'b0100_????_00: next_op_step <= 2'b11; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------SUB----------------------
                11'b0101_????_00: next_op_step <= 2'b11; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------LSL----------------------
                11'b0110_????_00: next_op_step <= 2'b11; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------LSR----------------------
                11'b0111_????_00: next_op_step <= 2'b11; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------ASR----------------------
                11'b1000_????_00: next_op_step <= 2'b11; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------ASR----------------------
                11'b1001_????_00: next_op_step <= 2'b11; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // --------- B ----------------------
                11'b1110_0000_00: next_op_step <= 2'b11; // IR out, branch en
                // ----------------------------------
                
                // ---------OUT---------------------
                11'b1111_????_00: next_op_step <= 2'b11; // register out, output reg in
                // ----------------------------------
                
                11'b????_????_11: next_op_step <= 2'b11;
                default: next_op_step <= 2'b11;
            endcase
        end
    end

assign pc_out = (fetch_step == 2'b00 && HALT == 1'b0) ? 1'b1 : 1'b0;
assign ram_in = (fetch_step == 2'b00 && HALT == 1'b0) || ((OPCODE[7:4] == 4'h0 || OPCODE[7:4] == 4'h1) && op_step == 2'b00) ? 1'b1 : 1'b0;
assign ram_out = (fetch_step == 2'b01 || (OPCODE[7:4] == 4'h0 && op_step == 2'b01)) ? 1'b1 : 1'b0;
assign ir_in = (fetch_step == 2'b01) ? 1'b1 : 1'b0;
assign pc_count = (fetch_step == 2'b01) ? 1'b1 : 1'b0;

assign ir_out = ((OPCODE[7:4] == 4'h2 || OPCODE == 8'hE0) && op_step == 2'b00) ? 1'b1 : 1'b0;
assign r0_in = (OPCODE[7:2] == 6'b0000_00 && op_step == 2'b01) || ((OPCODE[7:4] >= 4'h4 && OPCODE[7:4] <= 4'h9) && FULL_OPCODE[1:0] == 2'b00 && op_step == 2'b00) ? 1'b1 : 1'b0;
assign r1_in = (OPCODE[7:2] == 6'b0000_01 && op_step == 2'b01) || ((OPCODE[7:4] >= 4'h4 && OPCODE[7:4] <= 4'h9) && FULL_OPCODE[1:0] == 2'b01 && op_step == 2'b00) ? 1'b1 : 1'b0;
assign r2_in = (OPCODE[7:2] == 6'b0000_10 && op_step == 2'b01) || ((OPCODE[7:4] >= 4'h4 && OPCODE[7:4] <= 4'h9) && FULL_OPCODE[1:0] == 2'b10 && op_step == 2'b00) ? 1'b1 : 1'b0;
assign r3_in = (OPCODE[7:2] == 6'b0000_11 && op_step == 2'b01) || ((OPCODE[7:4] >= 4'h4 && OPCODE[7:4] <= 4'h9) && FULL_OPCODE[1:0] == 2'b11 && op_step == 2'b00) ? 1'b1 : 1'b0;

assign ram_wr = (OPCODE[7:4] == 4'h1 && op_step == 2'b01) ? 1'b1 : 1'b0;

assign r0_out = ((OPCODE[7:4] == 4'h0 && OPCODE[1:0] == 2'b00 && op_step == 2'b00) || (OPCODE[7:4] == 4'h1 && OPCODE[1:0] == 2'b00 && op_step == 2'b00) || (OPCODE[7:2] == 6'b0001_00 && op_step == 2'b01) || (OPCODE == 8'hF0 && op_step == 2'b00)) ? 1'b1 : 1'b0;
assign r1_out = ((OPCODE[7:4] == 4'h0 && OPCODE[1:0] == 2'b01 && op_step == 2'b00) || (OPCODE[7:4] == 4'h1 && OPCODE[1:0] == 2'b01 && op_step == 2'b00) || (OPCODE[7:2] == 6'b0001_01 && op_step == 2'b01) || (OPCODE == 8'hF1 && op_step == 2'b00)) ? 1'b1 : 1'b0;
assign r2_out = ((OPCODE[7:4] == 4'h0 && OPCODE[1:0] == 2'b10 && op_step == 2'b00) || (OPCODE[7:4] == 4'h1 && OPCODE[1:0] == 2'b10 && op_step == 2'b00) || (OPCODE[7:2] == 6'b0001_10 && op_step == 2'b01) || (OPCODE == 8'hF2 && op_step == 2'b00)) ? 1'b1 : 1'b0;
assign r3_out = ((OPCODE[7:4] == 4'h0 && OPCODE[1:0] == 2'b11 && op_step == 2'b00) || (OPCODE[7:4] == 4'h1 && OPCODE[1:0] == 2'b11 && op_step == 2'b00) || (OPCODE[7:2] == 6'b0001_11 && op_step == 2'b01) || (OPCODE == 8'hF3 && op_step == 2'b00)) ? 1'b1 : 1'b0;

assign r0_mov = (OPCODE == 8'h20 && op_step == 2'b00) ? 1'b1 : 1'b0;
assign r1_mov = (OPCODE == 8'h21 && op_step == 2'b00) ? 1'b1 : 1'b0;
assign r2_mov = (OPCODE == 8'h22 && op_step == 2'b00) ? 1'b1 : 1'b0;
assign r3_mov = (OPCODE == 8'h23 && op_step == 2'b00) ? 1'b1 : 1'b0;

assign alu_en = (OPCODE[7:4] >= 4'h4 && OPCODE[7:4] <= 4'h9 && op_step == 2'b00) ? 1'b1 : 1'b0;
assign alu_sel[6:4] = (OPCODE[7:4] == 4'h4) ? 3'b000 : (OPCODE[7:4] == 4'h5) ? 3'b001 : (OPCODE[7:4] == 4'h6) ? 3'b010 : (OPCODE[7:4] == 4'h7) ? 3'b011 : (OPCODE[7:4] == 4'h8) ? 3'b100 : (OPCODE[7:4] == 4'h9) ? 3'b101 : 3'b000;
assign alu_sel[3:0] = (OPCODE[7:4] >= 4'h4 && OPCODE[7:4] <= 4'h9) ? OPCODE[3:0] : 4'h0;

assign branch = (OPCODE == 8'hE0 && op_step == 2'b00) ? 1'b1 : 1'b0;
assign out_in = (OPCODE[7:4] == 4'hF && op_step == 2'b00) ? 1'b1 : 1'b0;

assign fetch_new = (!(fetch_step == 2'b00 || fetch_step == 2'b01) && next_op_step == 2'b11);
               
endmodule
