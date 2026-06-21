`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 05:18:26 PM
// Design Name: 
// Module Name: tb_regFile
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


module tb_regFile;

    logic        clk;
    logic        rst;
    logic [4:0]  rs1;       
    logic [4:0]  rs2;
    logic [4:0]  rd;
    logic [31:0] wdata;
    logic        regwrite;
    logic [31:0] outdata1;  
    logic [31:0] outdata2;
    
    //module instatiation
    
    reg_file uut(clk, rst, rs1, rs2, rd, wdata, regwrite, outdata1, outdata2);
    
    //clock generation 
    
    always #10 clk = ~clk;
    
    initial begin
     clk = 0;
     rs1 = 0;
     rs2 = 0;
     rd  = 0;
     wdata = 0;
     regwrite = 0;
     rst = 1; #2
     
     #10;
     
     rst = 0;
     rs1 = 5;
     rs2 = 25;
     
     #10;
     
     //write to reg10;
     regwrite = 1;
     rd = 5'd10;
     wdata = 32'd62;
     
     #10;
     
      // write to reg23
      regwrite = 1;
      rd = 5'd23;
      wdata = 32'd99;
      
      #10;
      
      //read reg10 and reg23
      
      regwrite = 0;
      rs1 = 5'd10;
      rs2 = 5'd23;
      
      #10;
      
      $finish; 
     #10;
     
     
    
    
    end     
    
    
endmodule
