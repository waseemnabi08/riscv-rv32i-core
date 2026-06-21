`timescale 1ns / 1ps

module tb_Top_RV32I();

    logic clk;
    logic rst;

    Top_RV32I dut (
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
        
        #150;        // Run for 15 clock cycles (15 * 10ns)
        $finish;
    end

    // Waveform Dump
    initial begin
        $dumpfile("rv32i_wave.vcd");
        $dumpvars(0, tb_Top_RV32I);
    end

endmodule