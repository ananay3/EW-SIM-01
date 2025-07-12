module ew_assertions #(parameter FSM_BITS = 3)(
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

    // Assert valid state
    property valid_state_check;
        @(posedge clk) disable iff (rst)
        fsm_state inside {IDLE, MONITOR, JAMMED, SPOOF_DETECTED,
                          ENTROPY_ANALYZED, COUNTER_MEASURE, RECOVERY};
    endproperty
    assert property (valid_state_check)
        else $fatal("? Invalid FSM state!");

    // Prevent direct JAMMED -> RECOVERY
    property jammed_to_recovery_check;
        @(posedge clk) disable iff (rst)
        (state_cast == JAMMED) |=> !(state_cast == RECOVERY);
    endproperty
    assert property (jammed_to_recovery_check)
        else $fatal("? Invalid jump JAMMED -> RECOVERY");

    // IDLE must go to MONITOR
    property idle_transition_check;
        @(posedge clk) disable iff (rst)
        (state_cast == IDLE) |=> (state_cast == MONITOR);
    endproperty
    assert property (idle_transition_check)
        else $fatal("? IDLE did not transition to MONITOR");

endmodule
