// ============================================================
//  Cyclic Prefix Inserter — 4-point IFFT, CP length = 1
//  Timing:
//    Cycle 0: valid_in=1, IFFT data presented
//    Cycle 1: valid_out=1, all outputs stable (1-cycle latency)
//    Cycle 2: valid_out=0 (unless new valid_in arrives)
// ============================================================

module cyclic_prefix (
    input clk,
    input reset_n,                        // active-low reset

    input signed [15:0] in0r, in0i,       // IFFT output x[0]
    input signed [15:0] in1r, in1i,       // x[1]
    input signed [15:0] in2r, in2i,       // x[2]
    input signed [15:0] in3r, in3i,       // x[3]
    input valid_in,

    output reg signed [15:0] out0r, out0i, // CP  = copy of x[3]
    output reg signed [15:0] out1r, out1i, // x[0]
    output reg signed [15:0] out2r, out2i, // x[1]
    output reg signed [15:0] out3r, out3i, // x[2]
    output reg signed [15:0] out4r, out4i, // x[3]
    output reg valid_out
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        // Reset all outputs to zero
        out0r <= 0; out0i <= 0;
        out1r <= 0; out1i <= 0;
        out2r <= 0; out2i <= 0;
        out3r <= 0; out3i <= 0;
        out4r <= 0; out4i <= 0;
        valid_out <= 0;
    end
    else if (valid_in) begin
        // --- Cyclic Prefix: copy last sample to front ---
        out0r <= in3r;
        out0i <= in3i;

        // --- Original IFFT samples ---
        out1r <= in0r;  out1i <= in0i;   // x[0]
        out2r <= in1r;  out2i <= in1i;   // x[1]
        out3r <= in2r;  out3i <= in2i;   // x[2]
        out4r <= in3r;  out4i <= in3i;   // x[3]  (same as CP src)

        valid_out <= 1;
    end
    else begin
        valid_out <= 0;
    end
end

endmodule
