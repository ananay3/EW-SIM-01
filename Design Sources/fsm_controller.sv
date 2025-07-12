// Module: FSM Controller
// Role: Takes decisions based on threat + auth results
module fsm_controller (
    input logic clk, reset,
    input logic [7:0] threat_vector,
    input logic known_threat,
    input logic [3:0] threat_id,
    input logic auth_valid,
    input logic [1:0] safest_channel,
    output logic [2:0] state,
    output logic [1:0] current_channel
);
    typedef enum logic [2:0] {
        MONITOR, VALIDATE, JAMMED, BLACKOUT, RECOVERY
    } fsm_state_t;

    fsm_state_t current_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= MONITOR;
            current_channel <= 0;
        end else begin
            case (current_state)
                MONITOR: begin
                    // Threat detected
                    if (|threat_vector)
                        current_state <= known_threat ? RECOVERY : VALIDATE;
                end
                VALIDATE: begin
                    if (!auth_valid) current_state <= BLACKOUT;
                    else if (threat_vector[0] || threat_vector[4])
                        current_state <= JAMMED;
                    else
                        current_state <= MONITOR;
                end
                JAMMED: begin
                    // Channel switch on jamming
                    current_channel <= safest_channel;
                    current_state <= MONITOR;
                end
                BLACKOUT: begin
                    // Isolated state
                    current_state <= RECOVERY;
                end
                RECOVERY: begin
                    // Recover and return
                    current_state <= MONITOR;
                end
            endcase
        end
        state <= current_state;
    end
endmodule
