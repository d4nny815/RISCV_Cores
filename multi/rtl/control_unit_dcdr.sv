`timescale 1ns / 1ps

import otter::*;

// cu_dcdr.v
// Members: Daniel Gutierrez
// Description:


module CU_DCDR (control_if.decoder ctrl);

    typedef enum logic [2:0] {
        FUNC3_ADD  = 3'b000,
        FUNC3_SLL  = 3'b001,
        FUNC3_SLT  = 3'b010,
        FUNC3_SLTU = 3'b011,
        FUNC3_XOR  = 3'b100,
        FUNC3_SR   = 3'b101,
        FUNC3_OR   = 3'b110,
        FUNC3_AND  = 3'b111
    } alu_func3_t;
    alu_func3_t alu_func3 = alu_func3_t'(ctrl.func3);

    always_comb begin 
        ctrl.pc_sel = PCSEL_PC_PLUS4; 
        ctrl.alu_srcA = SEL_RS1; 
        ctrl.alu_srcB = SEL_RS2; 
        ctrl.rf_wr_sel = RFWR_ALU_RES; 
        ctrl.alu_fun  = ADD;
        
       case(ctrl.opcode)
            OPCODE_LUI: begin
                ctrl.alu_fun = LUI;      // lui instruction
                ctrl.alu_srcA = SEL_UTYPE;
            end

            OPCODE_AUIPC: begin
                ctrl.alu_fun = ADD;      // add
                ctrl.alu_srcA = SEL_UTYPE;
                ctrl.alu_srcB = SEL_PC;
            end
            
            OPCODE_JAL: begin
                ctrl.pc_sel = PCSEL_JAL;
                ctrl.rf_wr_sel = RFWR_PC_PLUS4;
            end

            OPCODE_JALR: begin
                ctrl.pc_sel = PCSEL_JALR;
                ctrl.rf_wr_sel = RFWR_PC_PLUS4;
            end

            OPCODE_BRANCH: begin
                case(ctrl.func3)
                    FUNC3_BEQ: ctrl.pc_sel = ctrl.br_eq ? PCSEL_BRANCH : PCSEL_PC_PLUS4; 
                    FUNC3_BNE: ctrl.pc_sel = !ctrl.br_eq ? PCSEL_BRANCH : PCSEL_PC_PLUS4;
                    FUNC3_BLT: ctrl.pc_sel = ctrl.br_lt ? PCSEL_BRANCH : PCSEL_PC_PLUS4;
                    FUNC3_BGE: ctrl.pc_sel = !ctrl.br_lt ? PCSEL_BRANCH : PCSEL_PC_PLUS4;
                    FUNC3_BLTU: ctrl.pc_sel = ctrl.br_ltu ? PCSEL_BRANCH : PCSEL_PC_PLUS4;
                    FUNC3_BGEU: ctrl.pc_sel = !ctrl.br_ltu ? PCSEL_BRANCH : PCSEL_PC_PLUS4;
                endcase
            end
            
            OPCODE_LOAD: begin
                ctrl.alu_srcB = SEL_ITYPE;
                ctrl.rf_wr_sel = RFWR_MEM_IN;
                ctrl.alu_fun = ADD;
            end
            
            OPCODE_STORE: begin
                ctrl.alu_srcB = SEL_STYPE;
                ctrl.alu_fun = ADD;
            end
            
            OPCODE_OP_IMM: begin
                ctrl.alu_srcB = SEL_ITYPE;
                case(ctrl.func3)
                    FUNC3_ADD :  ctrl.alu_fun = ADD;
                    FUNC3_SLL :  ctrl.alu_fun = SLL;
                    FUNC3_SLT :  ctrl.alu_fun = SLT;
                    FUNC3_SLTU:  ctrl.alu_fun = SLTU;
                    FUNC3_XOR :  ctrl.alu_fun = XOR;
                    FUNC3_SR  :  ctrl.alu_fun = ctrl.func7 == FUNC7_SUB_SRA ? 
                                                                SRA : SRL;
                    FUNC3_OR  :  ctrl.alu_fun = OR;
                    FUNC3_AND :  ctrl.alu_fun = AND;
                endcase
            end

            OPCODE_OP_REG: begin
                case ({ctrl.func7, ctrl.func3})
                    {FUNC7_DEFAULT, FUNC3_ADD} :  ctrl.alu_fun = ADD;
                    {FUNC7_SUB_SRA, FUNC3_ADD} :  ctrl.alu_fun = SUB;
                    {FUNC7_DEFAULT, FUNC3_SLL} :  ctrl.alu_fun = SLL;
                    {FUNC7_DEFAULT, FUNC3_SLT} :  ctrl.alu_fun = SLT;
                    {FUNC7_DEFAULT, FUNC3_SLTU}:  ctrl.alu_fun = SLTU;
                    {FUNC7_DEFAULT, FUNC3_XOR} :  ctrl.alu_fun = XOR;
                    {FUNC7_DEFAULT, FUNC3_SR}  :  ctrl.alu_fun = SRL;
                    {FUNC7_SUB_SRA, FUNC3_SR}  :  ctrl.alu_fun = SRA;
                    {FUNC7_DEFAULT, FUNC3_OR}  :  ctrl.alu_fun = OR;
                    {FUNC7_DEFAULT, FUNC3_AND} :  ctrl.alu_fun = AND;
                    default: ctrl.alu_fun = ADD;
                endcase
            end

            default: begin
                ctrl.pc_sel = PCSEL_PC_PLUS4; 
                ctrl.alu_srcA = SEL_RS1; 
                ctrl.alu_srcB = SEL_RS2; 
                ctrl.rf_wr_sel = RFWR_PC_PLUS4; 
                ctrl.alu_fun = ADD;
            end
       endcase
    end
endmodule
