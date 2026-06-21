`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 02:32:25 PM
// Design Name: 
// Module Name: tb_PC
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


module tb_PC;

 logic clk, rst;
 logic [31:0] count;
 
 PC_32bit uut(.clk(clk), .rst(rst) , .count(count));
 
 
 
 always #5 clk = ~ clk;

 
 initial begin
 
 $monitor("Time = %0t | CLK = %b | RST = %b | COUNT = %d", $time, clk, rst, count);
 
 clk = 0;
 rst = 1; #5
 #5;
 
 rst = 0; 
 
 #100;
 $finish;
 end
 
  

endmodule
