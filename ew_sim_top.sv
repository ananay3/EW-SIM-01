module ew_sim_top (
    input logic clk, reset,
    input logic [7:0] signal_in,
    input logic [7:0] command_in,
    input logic [7:0] ch0, ch1, ch2, ch3,
    output logic [2:0] fsm_state,
    output logic [1:0] comm_channel,
    output logic system_fault
);
    logic [7:0] threat_vector, encrypted_data;
    logic [3:0] threat_id;
    logic known_threat, auth_valid;
    logic [1:0] safest_channel;

    signal_monitor       u1 (.clk, .reset, .signal_in, .threat_vector);
    threat_logger        u2 (.clk, .reset, .threat_vector, .known_threat, .threat_id);
    command_authenticator u3 (.clk, .reset, .command_in, .auth_valid);
    aes_lite_encryptor   u4 (.clk, .reset, .data_in(command_in), .data_out(encrypted_data));
    frequency_analyzer   u5 (.clk, .reset, .ch0, .ch1, .ch2, .ch3, .safest_channel);
    fsm_controller       u6 (.clk, .reset, .threat_vector, .known_threat, .threat_id,
                             .auth_valid, .safest_channel, .state(fsm_state), .current_channel(comm_channel));
    watchdog_timer       u7 (.clk, .reset, .fsm_state, .system_fault);
endmodule
