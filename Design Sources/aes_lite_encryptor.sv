// Module: AES-lite Encryptor
// Role: Simulates encryption using XOR
module aes_lite_encryptor (
    input logic clk, reset,
    input logic [7:0] data_in,
    output logic [7:0] data_out
);
    parameter logic [7:0] ENCRYPT_KEY = 8'h3C;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) data_out <= 0;
        else data_out <= data_in ^ ENCRYPT_KEY;
    end
endmodule
