// ============================================================
//  4-Point Radix-2 IFFT — no 1/N scaling
//  Twiddle factor: W^(-1) = +j
//    (a+jb)*j = -b + ja
//    temp_r2 = -B1i,  temp_i2 = +B1r
// ============================================================

module ifft_twiddle (
    input  signed [15:0] X0r, X0i,
    input  signed [15:0] X1r, X1i,
    input  signed [15:0] X2r, X2i,
    input  signed [15:0] X3r, X3i,

    output reg signed [15:0] x0r, x0i,
    output reg signed [15:0] x1r, x1i,
    output reg signed [15:0] x2r, x2i,
    output reg signed [15:0] x3r, x3i
);

    // Stage 1 — butterfly (17-bit to prevent overflow)
    wire signed [16:0] A0r = X0r + X2r;
    wire signed [16:0] A0i = X0i + X2i;
    wire signed [16:0] A1r = X0r - X2r;
    wire signed [16:0] A1i = X0i - X2i;

    wire signed [16:0] B0r = X1r + X3r;
    wire signed [16:0] B0i = X1i + X3i;
    wire signed [16:0] B1r = X1r - X3r;
    wire signed [16:0] B1i = X1i - X3i;

    // Twiddle W^0 = 1 (no change), W^(-1) = +j
    wire signed [16:0] temp_r1 =  B0r;
    wire signed [16:0] temp_i1 =  B0i;
    wire signed [16:0] temp_r2 = -B1i;   // +j: real = -imag
    wire signed [16:0] temp_i2 =  B1r;   // +j: imag = +real

    // Stage 2 — final butterfly, truncate back to 16-bit
    // Max value: 2*(±2 + ±2) = ±8, well within 16-bit range
    always @(*) begin
        x0r = (A0r + temp_r1);
        x0i = (A0i + temp_i1);

        x1r = (A1r + temp_r2);
        x1i = (A1i + temp_i2);

        x2r = (A0r - temp_r1);
        x2i = (A0i - temp_i1);

        x3r = (A1r - temp_r2);
        x3i = (A1i - temp_i2);
    end

endmodule
