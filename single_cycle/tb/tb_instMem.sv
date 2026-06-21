`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 03:13:19 PM
// Design Name: 
// Module Name: tb_instMem
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


module tb_instMem;

  logic [31:0] PC ;
  logic [31:0] Instr;
  
  inst_mem uut(.PC(PC), .Instr(Instr));
  
  initial begin
  
  $monitor("Time = %0t | PC = %d | Instruction = 0x%h", $time, PC, Instr);
  
    PC = 0;
    
    #5;
    
    PC = 4;
    
    #5;
    
    PC = 8;
    
    #5;
    
    PC = 12;
    
    #5;
    
    PC = 16;
    
    #5;
    
    PC = 20;
    
    #5;
    
    PC = 24;
    
    #5;
    
    PC = 28;
    $finish;
    
    end

endmodule
