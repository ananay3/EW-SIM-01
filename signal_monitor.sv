// Module: Signal Monitor
// Role: Detects anomalies in incoming signal
module signal_monitor (
    input logic clk, reset,
    input logic [7:0] signal_in,
    output logic [7:0] threat_vector
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) threat_vector <= 8'b0;
        else begin
            // Each bit represents a type of threat
            threat_vector[0] <= (signal_in > 8'd200);       // Burst Jam
            threat_vector[1] <= (signal_in < 8'd10);        // Signal Drop
            threat_vector[2] <= (signal_in == 8'd123);      // Spoofing Signature
            threat_vector[3] <= (signal_in == 8'd0);        // Blanking
            threat_vector[4] <= (signal_in[3:0] == 4'b1010);// Ramp Jam
            threat_vector[5] <= (signal_in == 8'd255);      // Entropy Noise
            threat_vector[6] <= ^signal_in;                 // Random Noise (XOR of bits)
            threat_vector[7] <= ~|signal_in;                // All bits are 0
        end
    end
endmodule
