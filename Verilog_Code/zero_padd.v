// ============================================================
//  Zero Padding / Subcarrier Assignment
//
//  Takes 1 QAM symbol and maps it to 4 IFFT input bins:
//    X[0] = (I, Q)   ← subcarrier 0  (signal)
//    X[1] = (I, Q)   ← subcarrier 1  (repeated)
//    X[2] = (0, 0)   ← subcarrier 2  (zeroed)
//    X[3] = (0, 0)   ← subcarrier 3  (zeroed)
//
//  NAMING FIX: changed i/q → r/i to match ifft_twiddle ports

// ============================================================

module zero_padd (
    input  signed [15:0] I_in,   // from QAM_16 I_out
    input  signed [15:0] Q_in,   // from QAM_16 Q_out

    output signed [15:0] X0r, X0i,   // bin 0 = signal
    output signed [15:0] X1r, X1i,   // bin 1 = repeated
    output signed [15:0] X2r, X2i,   // bin 2 = zero
    output signed [15:0] X3r, X3i    // bin 3 = zero
);

    assign X0r = I_in;
    assign X0i = Q_in;

    assign X1r = I_in;
    assign X1i = Q_in;

    assign X2r = 16'sd0;
    assign X2i = 16'sd0;

    assign X3r = 16'sd0;
    assign X3i = 16'sd0;

endmodule
