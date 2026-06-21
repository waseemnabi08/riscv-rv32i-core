`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 06:18:22 PM
// Design Name: 
// Module Name: tb_dataMem
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


module tb_dataMem;

   logic clk;
   logic  mem_read;              
   logic mem_write;
   logic [31:0] address; 
   logic [31:0] data_in;        
   logic [31:0] data_out;
   
    
   
   data_mem uut(clk, mem_read, mem_write, address, data_in, data_out);
   
   always #5 clk = ~clk;
   
   initial  begin
    clk = 0;
    mem_read = 0;
    mem_write = 0;
    address = 0;
    data_in = 0;
    data_out = 0;
    
    #10;
    
    //writng to mem loc 0
    mem_write = 1;
    address = 0;
    data_in = 32'd998;
    
    #10
     //writng to mem loc 1
    mem_write = 1;
    address = 4;
    data_in = 32'd2019;
    
    #10;
    
    //reading from memory
    mem_write = 0;
    mem_read = 1;
    address = 0;
    
    #10;
    
    mem_read = 1;
    address = 4;
    
    #10;
    $finish;
    
    end

endmodule
