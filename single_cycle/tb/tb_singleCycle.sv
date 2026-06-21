`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 04:36:05 PM
// Design Name: 
// Module Name: tb_singleCycle
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


module tb_singleCycle;

  logic clk, rst;
  logic [31:0] ReadData;
  
  
  //instatiate the top module
  
    SingleCycle DUT(.clk(clk), .rst(rst), .ReadData(ReadData));
    
    always #5 clk = ~clk;
    
    
    initial begin
       
       // rst at first
       clk = 0;
       rst = 1; #5
       
       #10;
       
       // realease rst
       
       rst = 0;
       
       
       //wait for some time
       
       #100;
       
       $finish;
       
   end
       
       


endmodule
