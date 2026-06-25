`timescale 1ns / 1ps

module PC_32bit ( 
    input  logic        clk,
    input  logic        rst,
    input logic         EN,
    input  logic [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk) begin
        if(rst) pc <= 32'b0;
        else begin if(!EN)    pc <= next_pc;
    end
   end
endmodule