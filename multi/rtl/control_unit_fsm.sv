`timescale 1ns / 1ps

import otter::*;

// cu_fsm.v


module CU_FSM (control_if.fsm ctrl);

    typedef enum logic [1:0] {
       INIT,
       FETCH,
       EXECUTE,
       WRITEBACK
    }  state_t;
    state_t  NS,PS;

    //- state registers (PS)
    always @ (posedge ctrl.clk) begin
        if (ctrl.rst)
            PS <= INIT;
        else
            PS <= NS;
    end

    always_comb begin
        NS = INIT;
        ctrl.reset = 1'b0;
        ctrl.pc_we = 1'b0;
        ctrl.rf_we = 1'b0;
        ctrl.mem_we = 1'b0;
        ctrl.mem_re1 = 1'b0;
        ctrl.mem_re2 = 1'b0;
        
        case (PS)
            INIT: begin
                ctrl.reset = 1'b1;
                ctrl.pc_we = 1'b0;
                ctrl.rf_we = 1'b0;
                ctrl.mem_we = 1'b0;
                ctrl.mem_re1 = 1'b0;
                ctrl.mem_re2 = 1'b0;
                NS = FETCH;
            end

            FETCH: begin
                ctrl.mem_re1 = 1'b1;
                NS = EXECUTE;
            end

            EXECUTE: begin
                ctrl.pc_we = 1'b1;
                ctrl.rf_we = 1'b1;
                NS = FETCH;

                case (ctrl.opcode)
                    OPCODE_BRANCH: begin
                        ctrl.rf_we = 1'b0;
                    end

                    OPCODE_LOAD: begin
                        ctrl.pc_we = 1'b0;
                        ctrl.rf_we = 1'b0;
                        ctrl.mem_re2 = 1'b1;
                        NS = WRITEBACK;
                    end

                    OPCODE_STORE: begin
                        ctrl.rf_we = 1'b0;
                        ctrl.mem_we = 1'b1;
                    end

                    default: begin
                        NS = FETCH;
                    end
                endcase
            end

            WRITEBACK: begin
                ctrl.pc_we = 1'b1;
                ctrl.rf_we = 1'b1;
                NS = FETCH;
            end

            default: NS = INIT;
        endcase 
    end
endmodule
