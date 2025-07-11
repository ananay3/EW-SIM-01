// Module: Frequency Analyzer
// Role: Picks least jammed communication channel
module frequency_analyzer (
    input logic clk, reset,
    input logic [7:0] ch0, ch1, ch2, ch3,
    output logic [1:0] safest_channel
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) safest_channel <= 0;
        else begin
            if (ch0 <= ch1 && ch0 <= ch2 && ch0 <= ch3) safest_channel <= 0;
            else if (ch1 <= ch0 && ch1 <= ch2 && ch1 <= ch3) safest_channel <= 1;
            else if (ch2 <= ch0 && ch2 <= ch1 && ch2 <= ch3) safest_channel <= 2;
            else safest_channel <= 3;
        end
    end
endmodule
