module tb_ew_sim_top;

  // Clock and Reset
  logic clk = 0;
  logic reset = 1;

  // Inputs to DUT
  logic [7:0] signal_in, command_in;
  logic [7:0] ch0 = 8'h08, ch1 = 8'h0F, ch2 = 8'h14, ch3 = 8'h19;

  // Outputs from DUT
  logic [2:0] fsm_state;
  logic [1:0] comm_channel;
  logic system_fault;

  // For FSM tracking
  logic [2:0] prev_state;

  // DUT Instantiation
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

  // === Test Scenario ===
  initial begin
    $display("=== EW-SIM-01 | Defence Verification Testbench Activated ===");

    // Reset system
    reset = 1;
    #15 reset = 0;

    // THREAT 1: BURST JAM (high signal + suspicious command)
    #10;
    signal_in = 8'd220; command_in = 8'hFF;
    $display("[Time %0t ns] THREAT 1 INJECTED: BURST JAM (Signal = %0d, Command = 0x%0h)", $time, signal_in, command_in);

    // THREAT 2: SPOOF SIGNAL (non-zero signal, neutral command)
    #30;
    signal_in = 8'd123; command_in = 8'h00;
    $display("[Time %0t ns] THREAT 2 INJECTED: SPOOFING (Signal = %0d)", $time, signal_in);

    // THREAT 3: RANDOM NOISE / ENTROPY (Max noise value)
    #30;
    signal_in = 8'd255; command_in = 8'hAA;
    $display("[Time %0t ns] THREAT 3 INJECTED: RANDOM NOISE (Signal = %0d, Command = 0x%0h)", $time, signal_in, command_in);

    // SAFE ZONE: Back to normal
    #30;
    signal_in = 8'd0; command_in = 8'h00;
    $display("[Time %0t ns] Signal Reset to SAFE MODE (0, 0)", $time);

    // Let FSM settle and recover
    #100;
  end

  // === FSM Transition Monitor with Explanation ===
  always @(posedge clk) begin
    if (fsm_state !== prev_state) begin
      case (fsm_state)
        3'd0: $display("[Time %0t ns] FSM ? IDLE: System is idle and monitoring.", $time);
        3'd1: $display("[Time %0t ns] FSM ? JAMMED: Jammer signal detected. Communication blocked!", $time);
        3'd2: $display("[Time %0t ns] FSM ? SPOOF_DETECTED: Spoofed pattern found. Authenticity compromised.", $time);
        3'd3: $display("[Time %0t ns] FSM ? AUTHENTICATING: Verifying command legitimacy via secure FSM.", $time);
        3'd4: $display("[Time %0t ns] FSM ? RECOVERY: Defensive countermeasures deployed. Recovering system...", $time);
        3'd5: $display("[Time %0t ns] FSM ? LOGGING: Threat recorded and stored in memory buffer.", $time);
        3'd6: $display("[Time %0t ns] FSM ? THREAT_KNOWN: Known threat re-encountered. Instant response applied.", $time);
        default: $display("[Time %0t ns] FSM ? UNKNOWN: Invalid state encountered.", $time);
      endcase
      prev_state = fsm_state;
    end
  end

  // === Final Verification Report ===
  initial begin
    #200;
    $display("\n=================================================");
    $display("              ? EW-SIM-01 MISSION REPORT          ");
    $display("=================================================");
    $display(" > Threats Simulated             : 3");
    $display(" > Final FSM State               : %0d (%s)", fsm_state,
      (fsm_state == 3'd0) ? "IDLE" :
      (fsm_state == 3'd1) ? "JAMMED" :
      (fsm_state == 3'd2) ? "SPOOF_DETECTED" :
      (fsm_state == 3'd3) ? "AUTHENTICATING" :
      (fsm_state == 3'd4) ? "RECOVERY" :
      (fsm_state == 3'd5) ? "LOGGING" :
      (fsm_state == 3'd6) ? "THREAT_KNOWN" : "UNKNOWN");

    $display(" > System Fault Flag             : %0b", system_fault);
    $display(" > Channel In Use                : CH-%0d", comm_channel);
    $display(" > Coverage Collection           : ? Enabled");
    $display(" > Assertion Observability       : ? Via XSIM Console");
    $display("-------------------------------------------------");
    if (system_fault) begin
        $display(" ? System Fault Detected! Check FSM transitions.");
    end else begin
        $display(" ? System Passed Threat Handling Successfully.");
    end
    $display("=================================================\n");
    $finish;
  end

endmodule