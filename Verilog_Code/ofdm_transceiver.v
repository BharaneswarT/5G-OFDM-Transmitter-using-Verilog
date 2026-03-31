// ============================================================
//  OFDM Transceiver — connects transmitter and receiver
//
//  TX path: data_in → QAM → zero_padd → IFFT → CP → 5 samples
//  RX path: 5 samples → CP remove → FFT → QAM demod → serial
//
//  In this loopback model the TX output connects directly to
//  RX input (no channel noise). Perfect for verifying that
//  what you send is exactly what you recover.
//
//  Timing note:
//    TX has 1 cycle latency (CP register stage)
//    So RX valid is driven by TX symbol_valid output
// ============================================================

module ofdm_transceiver (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [3:0]  data_in,      // 4-bit data to transmit
    input  wire        data_valid,   // pulse when data_in is ready

    // Serial recovered output
    output wire        serial_out,
    output wire        tx_done,
    output wire        tx_busy,

    // Debug — parallel recovered word (should match data_in after 1 cycle)
    output wire [3:0]  data_recovered
);

// ── TX side ──────────────────────────────────────────────────
wire signed [15:0] tx0r, tx0i;   // CP sample
wire signed [15:0] tx1r, tx1i;   // x[0]
wire signed [15:0] tx2r, tx2i;   // x[1]
wire signed [15:0] tx3r, tx3i;   // x[2]
wire signed [15:0] tx4r, tx4i;   // x[3]
wire               symbol_valid;  // 1 cycle after data_valid

ofdm_transmitter tx_inst (
    .clk         (clk),
    .reset_n     (reset_n),
    .data_in     (data_in),
    .data_valid  (data_valid),
    .out0r(tx0r), .out0i(tx0i),
    .out1r(tx1r), .out1i(tx1i),
    .out2r(tx2r), .out2i(tx2i),
    .out3r(tx3r), .out3i(tx3i),
    .out4r(tx4r), .out4i(tx4i),
    .symbol_valid(symbol_valid)
);

// ── RX side — TX output wired directly to RX input ───────────
ofdm_receiver rx_inst (
    .clk      (clk),
    .reset_n  (reset_n),

    // TX output → RX input (loopback, no channel)
    .in0r(tx0r), .in0i(tx0i),
    .in1r(tx1r), .in1i(tx1i),
    .in2r(tx2r), .in2i(tx2i),
    .in3r(tx3r), .in3i(tx3i),
    .in4r(tx4r), .in4i(tx4i),

    .data_valid        (symbol_valid),   // RX starts when TX symbol is ready
    .serial_out        (serial_out),
    .tx_done           (tx_done),
    .tx_busy           (tx_busy),
    .data_out_parallel (data_recovered)
);

endmodule
