`timescale 1ns / 1ps

module tb_ALU();

    // Inputs
    logic [31:0] num1;
    logic [31:0] num2;
    logic [2:0]  ALUCtrl;

    // Outputs
    logic [31:0] result;
    logic        z;

    // Instantiate the Device Under Test (DUT)
    ALU dut (
        .num1(num1),
        .num2(num2),
        .ALUCtrl(ALUCtrl),
        .result(result),
        .z(z)
    );

   

    initial begin
       //ADD
       num1  = 32'd199;
       num2 = 32'd233;
       ALUCtrl = 3'b000;
       
       #10;
       
       //SUB
       num1  = 32'd199;
       num2 = 32'd233;
       ALUCtrl = 3'b001;
       
       
       #10;
       
       //AND
       
       num1  = 32'b00101;
       num2 = 32'b10101;
       ALUCtrl = 3'b010;
       
       
       #10;
       //OR
      num1  = 32'b00101;
       num2 = 32'b10101;
       ALUCtrl = 3'b011;
       
       #10;
       
       //zeroflag check
       
       num1 = 32'd101;
       num2 = 32'd101;
       ALUCtrl = 001;
       
        $finish;
    end

endmodule