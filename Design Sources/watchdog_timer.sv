// Module: Watchdog Timer
// Role: Triggers reset if FSM is stuck too long
module watchdog_timer (
    input logic clk, reset,
    input logic [2:0] fsm_state,
    output logic system_fault
);
    logic [3:0] idle_counter;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            idle_counter <= 0;
            system_fault <= 0;
        end else begin
            // If stuck in MONITOR state too long, trigger fault
            if (fsm_state == 3'd0) idle_counter <= idle_counter + 1;
            else idle_counter <= 0;

            system_fault <= (idle_counter > 8);
        end
    end
endmodule
