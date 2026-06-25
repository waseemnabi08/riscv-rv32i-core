`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 05:21:28 PM
// Design Name: 
// Module Name: tb_piplined
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


module TB_Top_RV32I_Pipelined;

    logic clk;
    logic rst;

    Top_RV32I_Pipelined dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock Generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test Sequence
    initial begin
        rst = 1;
        #20;         // Assert reset for 2 clock cycles
        rst = 0;
        
        #500;        
        $finish;
    end

    // Waveform Dump
    initial begin
        $dumpfile("rv32i_wave.vcd");
    end
       
       


endmodule
