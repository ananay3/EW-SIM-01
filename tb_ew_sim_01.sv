module tb_ew_sim_01();

    // Clock and reset
    logic clk = 0;
    logic reset = 1;

    // Inputs to DUT
    logic [7:0] signal_in, command_in;
    logic [7:0] ch0 = 8'h08, ch1 = 8'h0F, ch2 = 8'h14, ch3 = 8'h19;

    // Outputs from DUT
    logic [2:0] fsm_state;
    logic [1:0] comm_channel;
    logic system_fault;

    // Instantiate the DUT (Device Under Test)
    ew_sim_top DUT (
        .clk(clk),
        .reset(reset),
        .signal_in(signal_in),
        .command_in(command_in),
        .ch0(ch0),
        .ch1(ch1),
        .ch2(ch2),
        .ch3(ch3),
        .fsm_state(fsm_state),
        .comm_channel(comm_channel),
        .system_fault(system_fault)
    );

    // Clock Generation
    always #5 clk = ~clk;

    // Track previous FSM state to detect transitions
    logic [2:0] prev_state;

    initial begin
        $display("=== EW-SIM-01 Console Threat Monitor Activated ===");

        // Reset sequence
        #5 reset = 1;
        #10 reset = 0;

        // Initialize variables
        signal_in = 8'h00;
        command_in = 8'h00;
        prev_state = 3'b000;

        // Inject simulated threats
        #10;
        signal_in = 8'd220; command_in = 8'hFF; // Burst Jam
        $display(">> Injecting THREAT 1: BURST JAM (signal=220, command=FF)");

        #30;
        signal_in = 8'd123; command_in = 8'h00; // Spoofed Signal
        $display(">> Injecting THREAT 2: SPOOF SIGNAL (signal=123)");

        #30;
        signal_in = 8'd255; command_in = 8'hAA; // Entropy Noise
        $display(">> Injecting THREAT 3: ENTROPY / RANDOM NOISE (signal=255)");

        #30;
        signal_in = 8'd0; command_in = 8'h00; // Safe state
        $display(">> Resetting Signal Input to Normal.");

        #30;
        $display(">> Simulation Completed. Shutting down EW-SIM-01.");
        $finish;
    end

    // Monitor FSM transitions automatically
    always @(posedge clk) begin
        if (fsm_state !== prev_state) begin
            case (fsm_state)
                3'd0: $display("FSM State: IDLE");
                3'd1: $display("FSM State: JAMMED");
                3'd2: $display("FSM State: SPOOF_DETECTED");
                3'd3: $display("FSM State: AUTHENTICATING");
                3'd4: $display("FSM State: RECOVERY");
                3'd5: $display("FSM State: LOGGING");
                3'd6: $display("FSM State: THREAT_KNOWN");
                default: $display("FSM State: UNKNOWN");
            endcase
            prev_state = fsm_state;
        end
    end

endmodule
