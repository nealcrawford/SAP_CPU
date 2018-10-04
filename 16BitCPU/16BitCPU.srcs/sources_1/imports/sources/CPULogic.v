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
            4'b01?_0: next_f_step <= 2'b11;
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
        if (f_step == 2'b01)
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
assign pc_count = (f_step == 2'b01) ? 1'b1 : 1'b0;

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

// ram out, r0 in
// -----------------------------------------------------------------------------


// ------------------------ LD1 ------------------------------------------------
// ram in, ir out

// ram out, r1 in
// -----------------------------------------------------------------------------


// ------------------------ LD2 ------------------------------------------------
// ram in, ir out

// ram out, r2 in
// -----------------------------------------------------------------------------


// ------------------------ LD3 ------------------------------------------------
// ram in, ir out

// ram out, r3 in
// -----------------------------------------------------------------------------


// ------------------------ STR0 -----------------------------------------------
// ram in, ir out

// ram wr, r0 out
// -----------------------------------------------------------------------------


// ------------------------ STR1 -----------------------------------------------
// ram in, ir out

// ram wr, r1 out
// -----------------------------------------------------------------------------

// ------------------------ STR2 -----------------------------------------------
// ram in, ir out

// ram wr, r2 out
// -----------------------------------------------------------------------------

// ------------------------ STR3 -----------------------------------------------
// ram in, ir out

// ram wr, r3 out
// -----------------------------------------------------------------------------

// ------------------------ MOV0 -----------------------------------------------
// r0 mov en, ir out
// -----------------------------------------------------------------------------

// ------------------------ MOV1 -----------------------------------------------
// r1 mov en, ir out
// -----------------------------------------------------------------------------

// ------------------------ MOV2 -----------------------------------------------
// r2 mov en, ir out
// -----------------------------------------------------------------------------

// ------------------------ MOV3 -----------------------------------------------
// r3 mov en, ir out
// -----------------------------------------------------------------------------

// ---------------- ADD/SUB/LSL/LSR/ASR/MUL ------------------------------------
// alu en, alu sel, reg in

assign r0_in = ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b00 && op_step == 3'b000) ? 1'b1 : 1'bz;
assign r1_in = ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b01 && op_step == 3'b000) ? 1'b1 : 1'bz;
assign r2_in = ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b10 && op_step == 3'b000) ? 1'b1 : 1'bz;
assign r3_in = ((OPCODE[7:4] >= 4'b0100 && OPCODE[7:4] <= 4'b1001) && FULL_OPCODE[1:0] == 2'b11 && op_step == 3'b000) ? 1'b1 : 1'bz;
// ------------------------------------------------------------------------------

// ------------------------ B ---------------------------------------------------
// ir out, branch en
// ------------------------------------------------------------------------------


// ------------------------ OUT ------------------------------------------------
// out in, r0 out
// out in, r1 out
// out in, r2 out
// out in, r3 out
// ------------------------------------------------------------------------------
*/
assign fetch_new = (fetching == 1'b0 && next_op_step == 3'b111);
               
endmodule
