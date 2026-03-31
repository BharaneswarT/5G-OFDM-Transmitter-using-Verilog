// ============================================================
//  OFDM Receiver — top module
//
//  Chain:
//  5 samples → cp_remove → fft_rx → qam_demod → serial_out
//
//  Signal flow:
//    in0..in4   : 5 complex samples from transmitter (CP+data)
//    after CP remove: 4 samples (data only)
//    after FFT  : 4 frequency bins — we only use bin X[0]
//                 because transmitter put signal on bins 0 and 1
//                 (bin 0 output = 4 × original QAM symbol)
//    after demod: 4-bit recovered data word
//    serial_out : 1 bit per clock, MSB first
//
//  Clock usage:
//    cp_remove  → combinational (assign only)
//    fft_rx     → combinational (always @*)
//    qam_demod  → combinational (always @*)
//    serial_out → sequential   (always @posedge clk) ← only one
// ============================================================

module ofdm_receiver (
    input  wire        clk,
    input  wire        reset_n,

    // 5 complex input samples from transmitter
    input  wire signed [15:0] in0r, in0i,  // CP (will be discarded)
    input  wire signed [15:0] in1r, in1i,
    input  wire signed [15:0] in2r, in2i,
    input  wire signed [15:0] in3r, in3i,
    input  wire signed [15:0] in4r, in4i,

    input  wire        data_valid,   // pulse when input samples are ready
    output wire        serial_out,   // recovered data, 1 bit per clock
    output wire        tx_done,      // high 1 cycle when all 4 bits sent
    output wire        tx_busy,      // high while sending

    // Debug outputs — recovered 4-bit word (parallel)
    output wire [3:0]  data_out_parallel
);

// ── Stage 1: CP removal ──────────────────────────────────────
wire signed [15:0] s0r, s0i;
wire signed [15:0] s1r, s1i;
wire signed [15:0] s2r, s2i;
wire signed [15:0] s3r, s3i;

cp_remove cp_inst (
    .in0r(in0r), .in0i(in0i),   // discarded inside cp_remove
    .in1r(in1r), .in1i(in1i),
    .in2r(in2r), .in2i(in2i),
    .in3r(in3r), .in3i(in3i),
    .in4r(in4r), .in4i(in4i),
    .out1r(s0r), .out1i(s0i),   // these become time samples for FFT
    .out2r(s1r), .out2i(s1i),
    .out3r(s2r), .out3i(s2i),
    .out4r(s3r), .out4i(s3i)
);

// ── Stage 2: 4-point FFT ─────────────────────────────────────
wire signed [15:0] X0r, X0i;
wire signed [15:0] X1r, X1i;
wire signed [15:0] X2r, X2i;
wire signed [15:0] X3r, X3i;

fft_rx fft_inst (
    .xf0r(s0r), .xf0i(s0i),
    .xf1r(s1r), .xf1i(s1i),
    .xf2r(s2r), .xf2i(s2i),
    .xf3r(s3r), .xf3i(s3i),
    .xt0r(X0r), .xt0i(X0i),   // bin 0 — has our signal (×4 scaled)
    .xt1r(X1r), .xt1i(X1i),   // bin 1 — also has signal (unused)
    .xt2r(X2r), .xt2i(X2i),   // bin 2 — zero (unused)
    .xt3r(X3r), .xt3i(X3i)    // bin 3 — zero (unused)
);

// ── Stage 3: QAM demapper (uses bin 0 only) ──────────────────
qam_demod demod_inst (
    .I_in    (X0r),
    .Q_in    (X0i),
    .data_out(data_out_parallel)
);

// ── Stage 4: Serial output ───────────────────────────────────
serial_out serial_inst (
    .clk       (clk),
    .reset_n   (reset_n),
    .data_in   (data_out_parallel),
    .load      (data_valid),
    .serial_out(serial_out),
    .tx_done   (tx_done),
    .tx_busy   (tx_busy)
);

endmodule
