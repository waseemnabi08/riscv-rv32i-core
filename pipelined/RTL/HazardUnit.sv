`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 02:51:57 PM
// Design Name: 
// Module Name: HazardUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Fully Fixed Hazard and Forwarding Unit with Control Hazard Flushes.
// 
//////////////////////////////////////////////////////////////////////////////////

module HazardUnit( 
    input [4:0] Rs1E, Rs2E, RdM, RdW, Rs1D, Rs2D, RdE,
    input RegWriteM, RegWriteW, ResultSrcEo, PCSrcE, 
    output logic [1:0] ForwardAE, ForwardBE,
    output logic StallF, StallD, 
    output logic FlushD, FlushE 
);
    
    logic lwStall;
    
    // Data Hazard Detection: 
    assign lwStall = (((Rs1D == RdE) | (Rs2D == RdE)) & ResultSrcEo);
    
    assign StallF = lwStall;
    assign StallD = lwStall;
    
    
    assign FlushE = lwStall | PCSrcE;
    assign FlushD = PCSrcE; 
    
    always_comb begin
    
        // ------------------ ForwardAE Logic ------------------
        if (((Rs1E == RdM) & RegWriteM) & (Rs1E != 5'b0)) begin
            // Forward from Memory Stage 
            ForwardAE = 2'b10;
        end 
        else if (((Rs1E == RdW) & RegWriteW) & (Rs1E != 5'b0)) begin
            // Forward from Writeback Stage
            ForwardAE = 2'b01;
        end 
        else begin
            // No Hazard: Use Register File directly
            ForwardAE = 2'b00;     
        end
        
        // ------------------ ForwardBE Logic ------------------
        if (((Rs2E == RdM) & RegWriteM) & (Rs2E != 5'b0)) begin
            // Forward from Memory Stage
            ForwardBE = 2'b10;                         
        end 
        else if (((Rs2E == RdW) & RegWriteW) & (Rs2E != 5'b0)) begin
            // Forward from Writeback Stage        
            ForwardBE = 2'b01;                         
        end 
        else begin                                         
            ForwardBE = 2'b00;                         
        end
    end
    
endmodule