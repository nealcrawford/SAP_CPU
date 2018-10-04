`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Neal Crawford
// Create Date: 08/20/2018 06:50:49 PM
// Module Name: CPULogic
// Description: 
// Revision:
// Additional Comments:
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

reg [1:0] f_step;
reg [1:0] next_f_step;
wire fetch_new;
wire fetching; // Fetching active signal. 

wire [7:0] OPCODE;
assign OPCODE = FULL_OPCODE[9:2];

//---------------- INSTRUCTION FETCHING -----------------------------------------------------------------

always @(posedge CLK, negedge ARST_L)
    begin
        if (ARST_L == 1'b0)
            f_step <= 2'b00; // fetch step
        else 
            f_step <= next_f_step;
    end

always @(f_step, fetch_new, HALT)
    begin
        casez ({f_step, fetch_new, HALT})
            4'b00?_0: next_f_step <= 2'b01;
            4'b01?_0: next_f_step <= 2'b10;
            4'b10?_0: next_f_step <= 2'b11;
            4'b110_0: next_f_step <= 2'b11;   // HOLD, no fetch assertions
            4'b111_0: next_f_step <= 2'b00;   // Begin fetching new instruction
            4'b???_1: next_f_step <= 2'b00;
            default: next_f_step <= 2'b00;
        endcase
    end

assign fetching = (f_step == 2'b00 || f_step == 2'b01) ? 1'b1 : 1'b0;

/*
// PC out, ram in
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (f_step == 2'b00 && HALT == 1'b0) ? 29'b10010000000000000000000000000 : 29'hzzzzzzzz;

// ram out, ir in
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (f_step == 2'b01) ? 29'b01000100000000000000000000000 : 29'hzzzzzzzz;

// pc count
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (f_step == 2'b10) ? 29'b00001000000000000000000000000 : 29'hzzzzzzzz;
*/

// ---------------------------------------------------------------------------------

reg [2:0] op_step;
reg [2:0] next_op_step;

always @(posedge CLK, negedge ARST_L)
    begin
        if (ARST_L == 1'b0)
            op_step <= 3'b111;
        else
            op_step <= next_op_step;
    end

always @(OPCODE, op_step, f_step)
    begin
        if (f_step == 2'b10)
            next_op_step <= 3'b000;
        else begin
            casez ({OPCODE, op_step})
                // ---------LDR----------------------
                11'b0000_????_000: next_op_step <= 3'b001; // IR out, RAM in (Access location in RAMs)
                11'b0000_????_001: next_op_step <= 3'b111; // RAM out, register in (put value into r0)
                // ----------------------------------
                
                
                // ---------STR----------------------
                11'b0001_????_000: next_op_step <= 3'b001; // IR out, RAM in
                11'b0001_????_001: next_op_step <= 3'b111; // RAM wr, register out
                // -----------------------------------
                
                // ---------MOV----------------------
                11'b0010_????_000: next_op_step <= 3'b111;
                // ----------------------------------
                
                // ---------ADD----------------------
                11'b0100_????_000: next_op_step <= 3'b111; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------SUB----------------------
                11'b0101_????_000: next_op_step <= 3'b111; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------LSL----------------------
                11'b0110_????_000: next_op_step <= 3'b111; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------LSR----------------------
                11'b0111_????_000: next_op_step <= 3'b111; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------ASR----------------------
                11'b1000_????_000: next_op_step <= 3'b111; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // ---------ASR----------------------
                11'b1001_????_000: next_op_step <= 3'b111; // ALU en, ALU sel, register in
                // ----------------------------------
                
                // --------- B ----------------------
                11'b1110_0000_000: next_op_step <= 3'b111; // ir out, branch en
                // ----------------------------------
                
                // ---------OUT---------------------
                11'b1111_????_000: next_op_step <= 3'b111; // register out, output reg in
                // ----------------------------------
                
                11'b????_????_111: next_op_step <= 3'b111; // By now, new instruction has been fetched, can now be operated on
                default: next_op_step <= 3'b111;
            endcase
        end
    end

assign pc_out = (f_step == 2'b00 && HALT == 1'b0) ? 1'b1 : 1'b0;
assign ram_in = (f_step == 2'b00 && HALT == 1'b0) || ((OPCODE[7:4] == 4'h0 || OPCODE[7:4] == 4'h1) && op_step == 3'b000) ? 1'b1 : 1'b0;
assign ram_out = (f_step == 2'b01 || (OPCODE[7:4] == 4'h0 && op_step == 3'b001)) ? 1'b1 : 1'b0;
assign ir_in = (f_step == 2'b01) ? 1'b1 : 1'b0;
assign pc_count = (f_step == 2'b10) ? 1'b1 : 1'b0;

assign ir_out = ((OPCODE[7:4] == 4'h0 || OPCODE[7:4] == 4'h1 || OPCODE[7:4] == 4'h2 || OPCODE == 8'hE0) && op_step == 3'b000) ? 1'b1 : 1'b0;
assign r0_in = (OPCODE == 8'h00 && op_step == 3'b001) || ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b00 && op_step == 3'b000) ? 1'b1 : 1'b0;
assign r1_in = (OPCODE == 8'h01 && op_step == 3'b001) || ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b01 && op_step == 3'b000) ? 1'b1 : 1'b0;
assign r2_in = (OPCODE == 8'h02 && op_step == 3'b001) || ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b10 && op_step == 3'b000) ? 1'b1 : 1'b0;
assign r3_in = (OPCODE == 8'h03 && op_step == 3'b001) || ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b11 && op_step == 3'b000) ? 1'b1 : 1'b0;

assign ram_wr = (OPCODE[7:4] == 4'h1 && op_step == 3'b001) ? 1'b1 : 1'b0;

assign r0_out = ((OPCODE == 8'h10 && op_step == 3'b001) || (OPCODE == 8'hF0 && op_step == 3'b000)) ? 1'b1 : 1'b0;
assign r1_out = ((OPCODE == 8'h11 && op_step == 3'b001) || (OPCODE == 8'hF1 && op_step == 3'b000)) ? 1'b1 : 1'b0;
assign r2_out = ((OPCODE == 8'h12 && op_step == 3'b001) || (OPCODE == 8'hF2 && op_step == 3'b000)) ? 1'b1 : 1'b0;
assign r3_out = ((OPCODE == 8'h13 && op_step == 3'b001) || (OPCODE == 8'hF3 && op_step == 3'b000)) ? 1'b1 : 1'b0;

assign r0_mov = (OPCODE == 8'h20 && op_step == 3'b000) ? 1'b1 : 1'b0;
assign r1_mov = (OPCODE == 8'h21 && op_step == 3'b000) ? 1'b1 : 1'b0;
assign r2_mov = (OPCODE == 8'h22 && op_step == 3'b000) ? 1'b1 : 1'b0;
assign r3_mov = (OPCODE == 8'h23 && op_step == 3'b000) ? 1'b1 : 1'b0;

assign alu_en = (OPCODE[7:4] >= 4'h4 && OPCODE[7:4] <= 4'h9 && op_step == 3'b000) ? 1'b1 : 1'b0;
assign alu_sel[6:4] = (OPCODE[7:4] == 4'h4) ? 3'b000 : (OPCODE[7:4] == 4'h5) ? 3'b001 : (OPCODE[7:4] == 4'h6) ? 3'b010 : (OPCODE[7:4] == 4'h7) ? 3'b011 : (OPCODE[7:4] == 4'h8) ? 3'b100 : (OPCODE[7:4] == 4'h9) ? 3'b101 : 3'b000;
assign alu_sel[3:0] = (OPCODE[7:4] >= 4'h4 && OPCODE[7:4] <= 4'h9) ? OPCODE[3:0] : 4'h0;

assign branch = (OPCODE == 8'hE0 && op_step == 3'b000) ? 1'b1 : 1'b0;
assign out_in = (OPCODE[7:4] == 4'hF && op_step == 3'b000) ? 1'b1 : 1'b0;

/*
// ------------------------ LD0 ------------------------------------------------
// ram in, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h00 && op_step == 3'b000) ? 29'b10000010000000000000000000000 : 29'hzzzzzzzz;

// ram out, r0 in
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h00 && op_step == 3'b001) ? 29'b01000001000000000000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------


// ------------------------ LD1 ------------------------------------------------
// ram in, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h01 && op_step == 3'b000) ? 29'b10000010000000000000000000000 : 29'hzzzzzzzz;

// ram out, r1 in
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h01 && op_step == 3'b001) ? 29'b01000000001000000000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------


// ------------------------ LD2 ------------------------------------------------
// ram in, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h02 && op_step == 3'b000) ? 29'b10000010000000000000000000000 : 29'hzzzzzzzz;

// ram out, r2 in
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h02 && op_step == 3'b001) ? 29'b01000000000001000000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------


// ------------------------ LD3 ------------------------------------------------
// ram in, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h03 && op_step == 3'b000) ? 29'b10000010000000000000000000000 : 29'hzzzzzzzz;
// ram out, r3 in
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h03 && op_step == 3'b001) ? 29'b01000000000000001000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------


// ------------------------ STR0 -----------------------------------------------
// ram in, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h10 && op_step == 3'b000) ? 29'b10000010000000000000000000000 : 29'hzzzzzzzz;
// ram wr, r0 out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h10 && op_step == 3'b001) ? 29'b00100000100000000000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------


// ------------------------ STR1 -----------------------------------------------
// ram in, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h11 && op_step == 3'b000) ? 29'b10000010000000000000000000000 : 29'hzzzzzzz;
// ram wr, r1 out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h11 && op_step == 3'b001) ? 29'b00100000000100000000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------

// ------------------------ STR2 -----------------------------------------------
// ram in, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h12 && op_step == 3'b000) ? 29'b10000010000000000000000000000 : 29'hzzzzzzzz;
// ram wr, r2 out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h12 && op_step == 3'b001) ? 29'b00100000000000100000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------

// ------------------------ STR3 -----------------------------------------------
// ram in, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h13 && op_step == 3'b000) ? 29'b10000010000000000000000000000 : 29'hzzzzzzzz;
// ram wr, r3 out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h13 && op_step == 3'b001) ? 29'b00100000000000000100000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------

// ------------------------ MOV0 -----------------------------------------------
// r0 mov en, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h20 && op_step == 3'b000) ? 29'b00000010100000000000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------

// ------------------------ MOV1 -----------------------------------------------
// r1 mov en, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h21 && op_step == 3'b000) ? 29'b00000010000100000000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------

// ------------------------ MOV2 -----------------------------------------------
// r2 mov en, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h22 && op_step == 3'b000) ? 29'b00000010000000100000000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------

// ------------------------ MOV3 -----------------------------------------------
// r3 mov en, ir out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h23 && op_step == 3'b000) ? 29'b00000010000000000100000000000 : 29'hzzzzzzzz;
// -----------------------------------------------------------------------------

// ------------------------ ADD ------------------------------------------------
// alu en, alu sel
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h40 && op_step == 3'b000) ? 25'b00000000000000001_000_0000_0 : 25'hzzzzzzz; // r0 + r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h41 && op_step == 3'b000) ? 25'b00000000000000001_000_0001_0 : 25'hzzzzzzz; // r0 + r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h42 && op_step == 3'b000) ? 25'b00000000000000001_000_0010_0 : 25'hzzzzzzz; // r0 + r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h43 && op_step == 3'b000) ? 25'b00000000000000001_000_0011_0 : 25'hzzzzzzz; // r0 + r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h45 && op_step == 3'b000) ? 25'b00000000000000001_000_0101_0 : 25'hzzzzzzz; // r1 + r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h46 && op_step == 3'b000) ? 25'b00000000000000001_000_0110_0 : 25'hzzzzzzz; // r1 + r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h47 && op_step == 3'b000) ? 25'b00000000000000001_000_0111_0 : 25'hzzzzzzz; // r1 + r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h4A && op_step == 3'b000) ? 25'b00000000000000001_000_1010_0 : 25'hzzzzzzz; // r2 + r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h4B && op_step == 3'b000) ? 25'b00000000000000001_000_1011_0 : 25'hzzzzzzz; // r2 + r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h4F && op_step == 3'b000) ? 25'b00000000000000001_000_1111_0 : 25'hzzzzzzz; // r3 + r3

// ------------------------ SUB ------------------------------------------------
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h50 && op_step == 3'b000) ? 25'b00000000000000001_001_0000_0 : 25'hzzzzzzz; // r0 - r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h51 && op_step == 3'b000) ? 25'b00000000000000001_001_0001_0 : 25'hzzzzzzz; // r0 - r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h54 && op_step == 3'b000) ? 25'b00000000000000001_001_0100_0 : 25'hzzzzzzz; // r1 - r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h52 && op_step == 3'b000) ? 25'b00000000000000001_001_0010_0 : 25'hzzzzzzz; // r0 - r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h58 && op_step == 3'b000) ? 25'b00000000000000001_001_1000_0 : 25'hzzzzzzz; // r2 - r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h53 && op_step == 3'b000) ? 25'b00000000000000001_001_0011_0 : 25'hzzzzzzz; // r0 - r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h5C && op_step == 3'b000) ? 25'b00000000000000001_001_1100_0 : 25'hzzzzzzz; // r3 - r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h55 && op_step == 3'b000) ? 25'b00000000000000001_001_0101_0 : 25'hzzzzzzz; // r1 - r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h56 && op_step == 3'b000) ? 25'b00000000000000001_001_0110_0 : 25'hzzzzzzz; // r1 - r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h59 && op_step == 3'b000) ? 25'b00000000000000001_001_1001_0 : 25'hzzzzzzz; // r2 - r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h57 && op_step == 3'b000) ? 25'b00000000000000001_001_0111_0 : 25'hzzzzzzz; // r1 - r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h5D && op_step == 3'b000) ? 25'b00000000000000001_001_1101_0 : 25'hzzzzzzz; // r3 - r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h5A && op_step == 3'b000) ? 25'b00000000000000001_001_1010_0 : 25'hzzzzzzz; // r2 - r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h5B && op_step == 3'b000) ? 25'b00000000000000001_001_1011_0 : 25'hzzzzzzz; // r2 - r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h5E && op_step == 3'b000) ? 25'b00000000000000001_001_1110_0 : 25'hzzzzzzz; // r3 - r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h5F && op_step == 3'b000) ? 25'b00000000000000001_001_1111_0 : 25'hzzzzzzz; // r3 - r3

// ------------------------ LSL ------------------------------------------------
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h60 && op_step == 3'b000) ? 25'b00000000000000001_010_0000_0 : 25'hzzzzzzz; // r0 << r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h61 && op_step == 3'b000) ? 25'b00000000000000001_010_0001_0 : 25'hzzzzzzz; // r0 << r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h64 && op_step == 3'b000) ? 25'b00000000000000001_010_0100_0 : 25'hzzzzzzz; // r1 << r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h62 && op_step == 3'b000) ? 25'b00000000000000001_010_0010_0 : 25'hzzzzzzz; // r0 << r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h68 && op_step == 3'b000) ? 25'b00000000000000001_010_1000_0 : 25'hzzzzzzz; // r2 << r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h63 && op_step == 3'b000) ? 25'b00000000000000001_010_0011_0 : 25'hzzzzzzz; // r0 << r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h6C && op_step == 3'b000) ? 25'b00000000000000001_010_1100_0 : 25'hzzzzzzz; // r3 << r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h65 && op_step == 3'b000) ? 25'b00000000000000001_010_0101_0 : 25'hzzzzzzz; // r1 << r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h66 && op_step == 3'b000) ? 25'b00000000000000001_010_0110_0 : 25'hzzzzzzz; // r1 << r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h69 && op_step == 3'b000) ? 25'b00000000000000001_010_1001_0 : 25'hzzzzzzz; // r2 << r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h67 && op_step == 3'b000) ? 25'b00000000000000001_010_0111_0 : 25'hzzzzzzz; // r1 << r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h6D && op_step == 3'b000) ? 25'b00000000000000001_010_1101_0 : 25'hzzzzzzz; // r3 << r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h6A && op_step == 3'b000) ? 25'b00000000000000001_010_1010_0 : 25'hzzzzzzz; // r2 << r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h6B && op_step == 3'b000) ? 25'b00000000000000001_010_1011_0 : 25'hzzzzzzz; // r2 << r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h6E && op_step == 3'b000) ? 25'b00000000000000001_010_1110_0 : 25'hzzzzzzz; // r3 << r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h6F && op_step == 3'b000) ? 25'b00000000000000001_010_1111_0 : 25'hzzzzzzz; // r3 << r3

// ------------------------ LSR ------------------------------------------------
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h70 && op_step == 3'b000) ? 25'b00000000000000001_011_0000_0 : 25'hzzzzzzz; // r0 >> r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h71 && op_step == 3'b000) ? 25'b00000000000000001_011_0001_0 : 25'hzzzzzzz; // r0 >> r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h74 && op_step == 3'b000) ? 25'b00000000000000001_011_0100_0 : 25'hzzzzzzz; // r1 >> r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h72 && op_step == 3'b000) ? 25'b00000000000000001_011_0010_0 : 25'hzzzzzzz; // r0 >> r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h78 && op_step == 3'b000) ? 25'b00000000000000001_011_1000_0 : 25'hzzzzzzz; // r2 >> r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h73 && op_step == 3'b000) ? 25'b00000000000000001_011_0011_0 : 25'hzzzzzzz; // r0 >> r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h7C && op_step == 3'b000) ? 25'b00000000000000001_011_1100_0 : 25'hzzzzzzz; // r3 >> r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h75 && op_step == 3'b000) ? 25'b00000000000000001_011_0101_0 : 25'hzzzzzzz; // r1 >> r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h76 && op_step == 3'b000) ? 25'b00000000000000001_011_0110_0 : 25'hzzzzzzz; // r1 >> r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h79 && op_step == 3'b000) ? 25'b00000000000000001_011_1001_0 : 25'hzzzzzzz; // r2 >> r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h77 && op_step == 3'b000) ? 25'b00000000000000001_011_0111_0 : 25'hzzzzzzz; // r1 >> r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h7D && op_step == 3'b000) ? 25'b00000000000000001_011_1101_0 : 25'hzzzzzzz; // r3 >> r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h7A && op_step == 3'b000) ? 25'b00000000000000001_011_1010_0 : 25'hzzzzzzz; // r2 >> r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h7B && op_step == 3'b000) ? 25'b00000000000000001_011_1011_0 : 25'hzzzzzzz; // r2 >> r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h7E && op_step == 3'b000) ? 25'b00000000000000001_011_1110_0 : 25'hzzzzzzz; // r3 >> r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h7F && op_step == 3'b000) ? 25'b00000000000000001_011_1111_0 : 25'hzzzzzzz; // r3 >> r3

// ------------------------ ASR ------------------------------------------------
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h80 && op_step == 3'b000) ? 25'b00000000000000001_100_0000_0 : 25'hzzzzzzz; // r0 >>> r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h81 && op_step == 3'b000) ? 25'b00000000000000001_100_0001_0 : 25'hzzzzzzz; // r0 >>> r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h84 && op_step == 3'b000) ? 25'b00000000000000001_100_0100_0 : 25'hzzzzzzz; // r1 >>> r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h82 && op_step == 3'b000) ? 25'b00000000000000001_100_0010_0 : 25'hzzzzzzz; // r0 >>> r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h88 && op_step == 3'b000) ? 25'b00000000000000001_100_1000_0 : 25'hzzzzzzz; // r2 >>> r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h83 && op_step == 3'b000) ? 25'b00000000000000001_100_0011_0 : 25'hzzzzzzz; // r0 >>> r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h8C && op_step == 3'b000) ? 25'b00000000000000001_100_1100_0 : 25'hzzzzzzz; // r3 >>> r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h85 && op_step == 3'b000) ? 25'b00000000000000001_100_0101_0 : 25'hzzzzzzz; // r1 >>> r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h86 && op_step == 3'b000) ? 25'b00000000000000001_100_0110_0 : 25'hzzzzzzz; // r1 >>> r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h89 && op_step == 3'b000) ? 25'b00000000000000001_100_1001_0 : 25'hzzzzzzz; // r2 >>> r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h87 && op_step == 3'b000) ? 25'b00000000000000001_100_0111_0 : 25'hzzzzzzz; // r1 >>> r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h8D && op_step == 3'b000) ? 25'b00000000000000001_100_1101_0 : 25'hzzzzzzz; // r3 >>> r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h8A && op_step == 3'b000) ? 25'b00000000000000001_100_1010_0 : 25'hzzzzzzz; // r2 >>> r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h8B && op_step == 3'b000) ? 25'b00000000000000001_100_1011_0 : 25'hzzzzzzz; // r2 >>> r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h8E && op_step == 3'b000) ? 25'b00000000000000001_100_1110_0 : 25'hzzzzzzz; // r3 >>> r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h8F && op_step == 3'b000) ? 25'b00000000000000001_100_1111_0 : 25'hzzzzzzz; // r3 >>> r3

// ------------------------ MUL ------------------------------------------------
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h90 && op_step == 3'b000) ? 25'b00000000000000001_101_0000_0 : 25'hzzzzzzz; // r0 * r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h91 && op_step == 3'b000) ? 25'b00000000000000001_101_0001_0 : 25'hzzzzzzz; // r0 * r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h94 && op_step == 3'b000) ? 25'b00000000000000001_101_0100_0 : 25'hzzzzzzz; // r1 * r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h92 && op_step == 3'b000) ? 25'b00000000000000001_101_0010_0 : 25'hzzzzzzz; // r0 * r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h98 && op_step == 3'b000) ? 25'b00000000000000001_101_1000_0 : 25'hzzzzzzz; // r2 * r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h93 && op_step == 3'b000) ? 25'b00000000000000001_101_0011_0 : 25'hzzzzzzz; // r0 * r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h9C && op_step == 3'b000) ? 25'b00000000000000001_101_1100_0 : 25'hzzzzzzz; // r3 * r0
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h95 && op_step == 3'b000) ? 25'b00000000000000001_101_0101_0 : 25'hzzzzzzz; // r1 * r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h96 && op_step == 3'b000) ? 25'b00000000000000001_101_0110_0 : 25'hzzzzzzz; // r1 * r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h99 && op_step == 3'b000) ? 25'b00000000000000001_101_1001_0 : 25'hzzzzzzz; // r2 * r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h97 && op_step == 3'b000) ? 25'b00000000000000001_101_0111_0 : 25'hzzzzzzz; // r1 * r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h9D && op_step == 3'b000) ? 25'b00000000000000001_101_1101_0 : 25'hzzzzzzz; // r3 * r1
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h9A && op_step == 3'b000) ? 25'b00000000000000001_101_1010_0 : 25'hzzzzzzz; // r2 * r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h9B && op_step == 3'b000) ? 25'b00000000000000001_101_1011_0 : 25'hzzzzzzz; // r2 * r3
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h9E && op_step == 3'b000) ? 25'b00000000000000001_101_1110_0 : 25'hzzzzzzz; // r3 * r2
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_mov, r0_out, r1_mov, r1_out, r2_mov, r2_out, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'h9F && op_step == 3'b000) ? 25'b00000000000000001_101_1111_0 : 25'hzzzzzzz; // r3 * r3

// register in
assign r0_in = ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b00 && op_step == 3'b000) ? 1'b1 : 1'bz;
assign r1_in = ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b01 && op_step == 3'b000) ? 1'b1 : 1'bz;
assign r2_in = ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b10 && op_step == 3'b000) ? 1'b1 : 1'bz;
assign r3_in = ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b11 && op_step == 3'b000) ? 1'b1 : 1'bz;
// ------------------------------------------------------------------------------

// ------------------------ B ---------------------------------------------------
// ir out, branch en
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'hE0 && op_step == 3'b000) ? 29'b00000010000000000000000000001 : 29'hzzzzzzzz;
// ------------------------------------------------------------------------------


// ------------------------ OUT ------------------------------------------------
// out in, r0 out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'hF0 && op_step == 3'b000) ? 29'b00000000010000000001000000000 : 29'hzzzzzzzz;
// out in, r1 out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'hF1 && op_step == 3'b000) ? 29'b00000000000010000001000000000 : 29'hzzzzzzzz;
// out in, r2 out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'hF2 && op_step == 3'b000) ? 25'b00000000000000010001000000000 : 29'hzzzzzzzz;
// out in, r3 out
assign {ram_in, ram_out, ram_wr, pc_out, pc_count, ir_in, ir_out, r0_in, r0_mov, r0_out, r1_in, r1_mov, r1_out, r2_in, r2_mov, r2_out, r3_in, r3_mov, r3_out, out_in, alu_en, alu_sel, branch} = (OPCODE == 8'hF3 && op_step == 3'b000) ? 25'b00000000000000000011000000000 : 29'hzzzzzzzz;
// ------------------------------------------------------------------------------
*/
assign fetch_new = (fetching == 1'b0 && f_step != 2'b10 && next_op_step == 3'b111);
               
endmodule
