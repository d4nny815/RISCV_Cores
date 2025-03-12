`timescale 1ns / 1ps

import otter::*;

module CU_FSM(control_if.fsm ctrl);

    typedef  enum logic [1:0] {
       INIT,
       FETCH,
       EX,
       WB
    } state_t;
    state_t  NS,PS;

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
            INIT: begin  //waiting state
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
                NS = EX;
            end

            EX: begin
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
                        NS = WB;
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

            WB: begin
                ctrl.pc_we = 1'b1;
                ctrl.rf_we = 1'b1;
                NS = FETCH;
            end

            default: NS = INIT;
        endcase
    end
endmodule
