// ============================================================
//  OFDM Transmitter — top module
//
//  Chain:
//    data_in[3:0] → QAM_16 → zero_padd → ifft_twiddle → cyclic_prefix
//  Output: 5 complex samples per OFDM symbol (CP + 4 data)
//  Latency: 1 clock cycle (cyclic_prefix is the only register stage)
// ============================================================

module ofdm_transmitter (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [3:0]  data_in,
    input  wire        data_valid,

    // 5 output samples: out0=CP, out1=x[0], out2=x[1], out3=x[2], out4=x[3]
    output wire signed [15:0] out0r, out0i,
    output wire signed [15:0] out1r, out1i,
    output wire signed [15:0] out2r, out2i,
    output wire signed [15:0] out3r, out3i,
    output wire signed [15:0] out4r, out4i,
    output wire        symbol_valid
);

// Stage 1: QAM mapper
wire signed [15:0] I_qam, Q_qam;

QAM_16 qam_inst (
    .in_data (data_in),
    .I_out   (I_qam),
    .Q_out   (Q_qam)
);

// Stage 2: Subcarrier assignment
wire signed [15:0] X0r, X0i;
wire signed [15:0] X1r, X1i;
wire signed [15:0] X2r, X2i;
wire signed [15:0] X3r, X3i;

zero_padd pad_inst (
    .I_in (I_qam),
    .Q_in (Q_qam),
    .X0r(X0r), .X0i(X0i),
    .X1r(X1r), .X1i(X1i),
    .X2r(X2r), .X2i(X2i),
    .X3r(X3r), .X3i(X3i)
);

// Stage 3: 4-point IFFT
wire signed [15:0] t0r, t0i;
wire signed [15:0] t1r, t1i;
wire signed [15:0] t2r, t2i;
wire signed [15:0] t3r, t3i;

ifft_twiddle ifft_inst (
    .X0r(X0r), .X0i(X0i),
    .X1r(X1r), .X1i(X1i),
    .X2r(X2r), .X2i(X2i),
    .X3r(X3r), .X3i(X3i),
    .x0r(t0r), .x0i(t0i),
    .x1r(t1r), .x1i(t1i),
    .x2r(t2r), .x2i(t2i),
    .x3r(t3r), .x3i(t3i)
);

// Stage 4: Cyclic prefix
cyclic_prefix cp_inst (
    .clk      (clk),
    .reset_n  (reset_n),
    .in0r(t0r), .in0i(t0i),
    .in1r(t1r), .in1i(t1i),
    .in2r(t2r), .in2i(t2i),
    .in3r(t3r), .in3i(t3i),
    .valid_in (data_valid),
    .out0r(out0r), .out0i(out0i),
    .out1r(out1r), .out1i(out1i),
    .out2r(out2r), .out2i(out2i),
    .out3r(out3r), .out3i(out3i),
    .out4r(out4r), .out4i(out4i),
    .valid_out(symbol_valid)
);

endmodule
