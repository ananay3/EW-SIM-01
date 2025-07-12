// Module: Command Authenticator
// Role: Ensures command is from a valid source
module command_authenticator (
    input logic clk, reset,
    input logic [7:0] command_in,
    output logic auth_valid
);
    parameter logic [7:0] SECRET_KEY = 8'hA5;
    logic [7:0] expected_hash = 8'h5A;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) auth_valid <= 0;
        else auth_valid <= ((command_in ^ SECRET_KEY) == expected_hash);
    end
endmodule
