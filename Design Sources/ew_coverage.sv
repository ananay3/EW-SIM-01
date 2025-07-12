module ew_coverage #(parameter FSM_BITS = 3)(
    input logic clk,
    input logic rst,
    input logic [FSM_BITS-1:0] fsm_state
);

    typedef enum logic [FSM_BITS-1:0] {
        IDLE, MONITOR, JAMMED,
        SPOOF_DETECTED, ENTROPY_ANALYZED,
        COUNTER_MEASURE, RECOVERY
    } fsm_state_t;

    fsm_state_t state_cast;
    assign state_cast = fsm_state_t'(fsm_state);

    covergroup fsm_state_cov @(posedge clk);
        option.per_instance = 1;
        coverpoint state_cast {
            bins idle             = {IDLE};
            bins monitor          = {MONITOR};
            bins jammed           = {JAMMED};
            bins spoof_detected   = {SPOOF_DETECTED};
            bins entropy_analyzed = {ENTROPY_ANALYZED};
            bins counter_measure  = {COUNTER_MEASURE};
            bins recovery         = {RECOVERY};
        }
    endgroup

    fsm_state_cov fsmcov = new();

endmodule
