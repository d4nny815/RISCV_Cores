`timescale 1ns / 1ps

import otter::*;

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2023 03:51:47 AM
// Design Name: 
// Module Name: main
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


module ALU (
    input aluFunc_t alu_fun,
    input word_t srcA, 
    input word_t srcB, 
    output word_t result
    );
        
    always_comb begin
        case(alu_fun)
            ADD: result = srcA + srcB;                   
            SLL: result = srcA << srcB[4:0];             
            SLT: result = $signed(srcA) < $signed(srcB); 
            SLTU: result = srcA < srcB;                  
            XOR: result = srcA ^ srcB;                    
            SRL: result = srcA >> srcB[4:0];             
            OR: result = srcA | srcB;                    
            AND: result = srcA & srcB;                   
            SUB: result = srcA - srcB;                   
            LUI: result = srcA;                    
            SRA: result = $signed(srcA) >>> srcB[4:0]; 
            default: result = 32'hDEAD_BEEF;
        endcase
    end
endmodule
