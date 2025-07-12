`timescale 1ns / 1ps

module tb_ew_sim_01;

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

    // File handle for flat-path heatmap logging
    integer f;

    // FSM transition tracking
    logic [2:0] prev_state;

    // Instantiate the DUT
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

    // Clock generation
    always #5 clk = ~clk;

    // Test sequence and file logging for heatmap
    initial begin
        $display("===== [? BASIC + HEATMAP SIMULATION: tb_ew_sim_01] =====");

        reset = 1;
        #10 reset = 0;

        signal_in = 8'h00;
        command_in = 8'h00;
        prev_state = 3'b000;

        // Open flat path log file in current sim dir
        f = $fopen("ew_log.txt", "w");
        if (f == 0) begin
            $display("[ERROR] Unable to open log file 'ew_log.txt'!");
            $finish;
        end
        $fwrite(f, "=== EW-SIM-01 Log File Start ===\n");

        // Inject threats
        #10;
        signal_in = 8'd220; command_in = 8'hFF;
        $display(">> Injecting THREAT 1: BURST JAM (signal=220, command=FF)");

        #30;
        signal_in = 8'd123; command_in = 8'h00;
        $display(">> Injecting THREAT 2: SPOOF SIGNAL (signal=123)");

        #30;
        signal_in = 8'd255; command_in = 8'hAA;
        $display(">> Injecting THREAT 3: ENTROPY / RANDOM NOISE (signal=255)");

        #30;
        signal_in = 8'd0; command_in = 8'h00;
        $display(">> Resetting Signal Input to Normal.");

        // Log FSM states over 10 cycles
        for (int i = 0; i < 10; i++) begin
            #10;
            $fwrite(f, "Cycle %0t ns: FSM State = %0d, Signal = %02X, Command = %02X\n",
                    $time, fsm_state, signal_in, command_in);
        end

        $fwrite(f, "=== EW-SIM-01 Log File End ===\n");
        $fclose(f);
        $display("? Log file for heatmap written to: ew_log.txt");
        $display(">> Simulation Completed. Shutting down EW-SIM-01.");
        $finish;
    end

    // FSM monitor for TCL Console output
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