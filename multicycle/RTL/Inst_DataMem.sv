`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 02:38:41 PM
// Design Name: 
// Module Name: Inst_DataMem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Pure Unified Instruction and Data Memory (Von Neumann architecture)
//              for Multicycle RISC-V.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Inst_DataMem( 
    input clk, 
    input rst, 
    input WE,              // Write Enable for Memory
    input [31:0] Adr,      // Address bus 
    input [31:0] WD,       // Write Data (32-bit)
    output logic [31:0] RD // Read Data (32-bit)
);
        
    // 1 KB Single Unified Byte-Addressable Memory Array (1024 bytes)
    logic [7:0] memory [1023:0];  
    
    // Pre-populating the single memory block with instructions at the start addresses
    initial begin
        // 1. 0x00500293  addi t0, x0, 5
        memory[0]  = 8'h93; memory[1]  = 8'h02; memory[2]  = 8'h50; memory[3]  = 8'h00;

        // 2. 0x00700313  addi t1, x0, 7
        memory[4]  = 8'h13; memory[5]  = 8'h03; memory[6]  = 8'h70; memory[7]  = 8'h00;

        // 3. 0x006283B3  add t2, t0, t1
        memory[8]  = 8'hB3; memory[9]  = 8'h83; memory[10] = 8'h62; memory[11] = 8'h00;

// sw t2, 32(x0)  ->  address = 32, safely past all instructions
        // Machine code: 0x02702023
        memory[12] = 8'h23; memory[13] = 8'h20; memory[14] = 8'h70; memory[15] = 8'h02;
        
        // lw t3, 32(x0)  ->  address = 32
        // Machine code: 0x02002E03
        memory[16] = 8'h03; memory[17] = 8'h2E; memory[18] = 8'h00; memory[19] = 8'h02;
            // 6. 0x01C38463  beq t2, t3, pass  (offset +8 -> PC=20+8=28 = pass label)
        memory[20] = 8'h63; memory[21] = 8'h84; memory[22] = 8'hC3; memory[23] = 8'h01;

        // 7. 0x0000006F  jal x0, fail      (offset 0 -> infinite loop at PC=24)
        memory[24] = 8'h6F; memory[25] = 8'h00; memory[26] = 8'h00; memory[27] = 8'h00;

        // 8. 0x0000006F  jal x0, pass      (offset 0 -> infinite loop at PC=28)
        memory[28] = 8'h6F; memory[29] = 8'h00; memory[30] = 8'h00; memory[31] = 8'h00;
    end

    // Synchronous Memory Writes
    always_ff @(posedge clk) begin
        if (rst) begin
            // Synchronous reset actions can go here if needed
        end else if (WE) begin
            // Little-endian write layout into the single array
            memory[Adr]   <= WD[7:0];
            memory[Adr+1] <= WD[15:8];
            memory[Adr+2] <= WD[23:16];
            memory[Adr+3] <= WD[31:24];
        end
    end

    // Asynchronous Memory Reads (No multiplexer conditional statements needed!)
    assign RD = {memory[Adr+3], memory[Adr+2], memory[Adr+1], memory[Adr]};
   
endmodule