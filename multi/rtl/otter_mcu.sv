`timescale 1ns / 1ps

import otter::*;

module OTTER_MCU (
    input CLK,    
    input INTR,       
    input RESET,      
    input [31:0] IOBUS_IN,    
    output [31:0] IOBUS_OUT,    
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR );

    // PC wires
    word_t pc, mux_pc;

    // memory wires
    word_t ir, dout2;

    // register file wires
    word_t mux_regfile, rs1, rs2;

    // immediate generation wires
    word_t u_type, i_type, s_type, b_type, j_type;

    // branch address generation wires
    word_t jalr, jal, branch;

    // ALU wires
    word_t alu_out, mux_srcA, mux_srcB;

    // control unit wires
    control_if ctrl(CLK, RESET);
    assign ctrl.opcode = opcode_t'(ir[6:0]);
    assign ctrl.func3 = func3_t'(ir[14:12]);
    assign ctrl.func7 = func7_t'(ir[31:25]);
    
    always_ff @( posedge ctrl.clk ) begin : PC
        if (ctrl.reset) pc <= 0;
        else if (ctrl.pc_we) begin : PC_MUX
            case(ctrl.pc_sel)
                PCSEL_PC_PLUS4  : pc <= pc + 4;
                PCSEL_JALR      : pc <= jalr;
                PCSEL_BRANCH    : pc <= branch;
                PCSEL_JAL       : pc <= jal;
            endcase
        end
    end

    Memory OTTER_MEMORY (
        .MEM_CLK   (ctrl.clk),
        .MEM_RDEN1 (ctrl.mem_re1), 
        .MEM_RDEN2 (ctrl.mem_re2), 
        .MEM_WE2   (ctrl.mem_we),
        .MEM_ADDR1 (pc[15:2]),  // remove the LSB
        .MEM_ADDR2 (alu_out),
        .MEM_DIN2  (rs2),  
        .MEM_SIZE  (ir[13:12]),
        .MEM_SIGN  (ir[14]),
        .IO_IN     (IOBUS_IN),
        .IO_WR     (IOBUS_WR),
        .MEM_DOUT1 (ir),
        .MEM_DOUT2 (dout2)  
    );
    
    always_comb begin
        case(ctrl.rf_wr_sel)
            RFWR_PC_PLUS4: mux_regfile = pc + 4;
            RFWR_CSR_REG: mux_regfile = 0;
            RFWR_MEM_IN: mux_regfile = dout2;
            RFWR_ALU_RES: mux_regfile = alu_out;
        endcase
    end
    
    RegFile my_regfile (
        .wd       (mux_regfile),
        .clk      (ctrl.clk), 
        .en       (ctrl.rf_we),
        .adr1     (ir[19:15]),
        .adr2     (ir[24:20]),
        .wa       (ir[11:7]),
        .rs1      (rs1), 
        .rs2      (rs2)  
    );
    assign IOBUS_OUT = rs2; 

    // IMMED GEN
    always_comb begin
        i_type = { {21{ir[31]}}, ir[30:25], ir[24:20]};
        s_type = { {21{ir[31]}}, ir[30:25], ir[11:7]};
        b_type = { {20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
        u_type = { ir[31:12], 12'b0};
        j_type = { {12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};

        jalr   = rs1 + i_type;
        jal    = pc + j_type;
        branch = pc + b_type;
    end

    // ALU MUXs
    always_comb begin
        case(ctrl.alu_srcA)
            SEL_RS1     : mux_srcA = rs1;
            SEL_UTYPE   : mux_srcA = u_type;
        endcase

        case(ctrl.alu_srcB)
            SEL_RS2     : mux_srcB = rs2;
            SEL_ITYPE   : mux_srcB = i_type;
            SEL_STYPE   : mux_srcB = s_type;
            SEL_PC      : mux_srcB = pc;
        endcase
    end

    ALU my_alu (
        .alu_fun  (ctrl.alu_fun),
        .srcA     (mux_srcA), 
        .srcB     (mux_srcB), 
        .result   (alu_out) 
    );
    assign IOBUS_ADDR = alu_out; 

    always_comb begin
        ctrl.br_eq  = (rs1 == rs2);
        ctrl.br_lt  = ($signed(rs1) < $signed(rs2));
        ctrl.br_ltu = (rs1 < rs2);
    end

    CU_FSM my_fsm (ctrl);
    
    CU_DCDR my_cu_dcdr (ctrl);

endmodule
