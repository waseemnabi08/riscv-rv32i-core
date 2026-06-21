`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 10:04:39 AM
// Design Name: 
// Module Name: Instr
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


module Instr(input [31:0] ReadData,
            input clk, EN,
            output logic [31:0] outData
    );
    
    
    // Hold instruction stable across all states until next Fetch (IRWrite/EN=1)
    always_ff @(posedge clk) begin
        if(EN) outData <= ReadData;
        // No else: always_ff implicitly retains value when EN=0
    end
    
    
endmodule