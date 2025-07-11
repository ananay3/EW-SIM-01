// Module: Threat Logger
// Role: Records unique threats and detects repetitions
module threat_logger (
    input logic clk, reset,
    input logic [7:0] threat_vector,
    output logic known_threat,
    output logic [3:0] threat_id
);
    logic [7:0] threat_buffer [15:0]; // Stores last 16 threats
    logic [3:0] write_ptr;            // Pointer to store new threat

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            write_ptr <= 0;
            known_threat <= 0;
            threat_id <= 0;
        end else begin
            known_threat <= 0;
            // Check if current threat_vector already exists
            for (int i = 0; i < 16; i++) begin
                if (threat_buffer[i] == threat_vector) begin
                    known_threat <= 1;
                    threat_id <= i;
                end
            end
            // If not found, store it
            if (!known_threat) begin
                threat_buffer[write_ptr] <= threat_vector;
                threat_id <= write_ptr;
                write_ptr <= (write_ptr + 1) % 16;
            end
        end
    end
endmodule
