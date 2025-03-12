package otter;

typedef enum logic [1:0] {
    PCSEL_PC_PLUS4 = 2'b00,
    PCSEL_JALR     = 2'b01,
    PCSEL_BRANCH   = 2'b10,
    PCSEL_JAL      = 2'b11
} pcSel_t;

typedef enum logic [1:0] {
    RFWR_PC_PLUS4  = 2'b00,
    RFWR_CSR_REG   = 2'b01,
    RFWR_MEM_IN    = 2'b10,
    RFWR_ALU_RES   = 2'b11
} rfWrSel_t;

typedef enum logic [6:0] {
    OPCODE_LUI    = 7'b0110111,
    OPCODE_AUIPC  = 7'b0010111,
    OPCODE_JAL    = 7'b1101111,
    OPCODE_JALR   = 7'b1100111,
    OPCODE_BRANCH = 7'b1100011,
    OPCODE_LOAD   = 7'b0000011,
    OPCODE_STORE  = 7'b0100011,
    OPCODE_OP_IMM = 7'b0010011,
    OPCODE_OP_REG = 7'b0110011
} opcode_t;

typedef enum logic [2:0] {
    FUNC3_BEQ = 3'b000,
    FUNC3_BNE = 3'b001,
    FUNC3_BLT = 3'b100,
    FUNC3_BGE = 3'b101,
    FUNC3_BLTU = 3'b110,
    FUNC3_BGEU = 3'b111
} func3_t;

typedef enum logic [6:0] {
    FUNC7_DEFAULT = 7'b0000000,
    FUNC7_SUB_SRA = 7'b0100000
} func7_t;

typedef enum logic {
    SEL_RS1     = 1'b0,
    SEL_UTYPE   = 1'b1
} muxSrcASel_t;

typedef enum logic [1:0] {
    SEL_RS2     = 2'b00,
    SEL_ITYPE   = 2'b01,
    SEL_STYPE   = 2'b10,
    SEL_PC      = 2'b11
} muxSrcBSel_t;

typedef enum logic [3:0] {
    ADD = 4'b0000,
    SLL = 4'b0001,
    SLT = 4'b0010,
    SLTU = 4'b0011,
    XOR = 4'b0100,
    SRL = 4'b0101,
    OR = 4'b0110,
    AND = 4'b0111,
    SUB = 4'b1000,
    LUI = 4'b1001,
    SRA = 4'b1101
} aluFunc_t;

typedef logic [31:0] word_t ;

endpackage : otter

interface control_if(input logic clk, rst);
    import otter::*;
    
    // Decoder Signals
    logic br_eq; 
    logic br_lt; 
    logic br_ltu;
    opcode_t opcode;
    func3_t func3;
    func7_t func7;         

    pcSel_t pc_sel;
    muxSrcASel_t alu_srcA;
    muxSrcBSel_t alu_srcB; 
    rfWrSel_t rf_wr_sel;
    aluFunc_t alu_fun;

    // FSM Signals
    logic reset;
    logic pc_we;
    logic rf_we;
    logic mem_we;
    logic mem_re1;
    logic mem_re2;

    modport decoder (
        input br_eq, br_lt, br_ltu, opcode, func7, func3,
        output pc_sel, alu_srcA, alu_srcB, rf_wr_sel, alu_fun
    );

    modport fsm (
        input clk, rst, opcode,
        output reset, pc_we, rf_we, mem_we, mem_re1, mem_re2
    );
    
endinterface