// ============================================================
//  QAM-16 Demapper
//
//  Input: recovered complex point from FFT bin X[0]
//  Output: 4-bit data word
//
//  The full TX→RX chain scales values by exactly 4x:
//    original I=+1 → received I=+4
//    original I=+2 → received I=+8
//    original I=-1 → received I=-4
//    original I=-2 → received I=-8
//
//  So threshold is at ±6 to split +4 from +8:
//    I >= 6  → was +2    I < -6 → was -2
//    I > 0   → was +1    I <= 0 → was -1
//
//  Combinational only — no clock needed.
// ============================================================

module qam_demod (
    input  signed [15:0] I_in,
    input  signed [15:0] Q_in,
    output reg    [3:0]  data_out
);

    reg signed [2:0] I_dec;  // decoded: +2,+1,-1,-2
    reg signed [2:0] Q_dec;

    always @(*) begin
        // I decision
        if      (I_in >= 6)  I_dec =  2;
        else if (I_in >  0)  I_dec =  1;
        else if (I_in > -6)  I_dec = -1;
        else                 I_dec = -2;

        // Q decision (same thresholds)
        if      (Q_in >= 6)  Q_dec =  2;
        else if (Q_in >  0)  Q_dec =  1;
        else if (Q_in > -6)  Q_dec = -1;
        else                 Q_dec = -2;

        case ({I_dec, Q_dec})
            {3'sd1,  3'sd1 }: data_out = 4'b0000;
            {-3'sd1, 3'sd1 }: data_out = 4'b0001;
            {3'sd1,  -3'sd1}: data_out = 4'b0010;
            {-3'sd1, -3'sd1}: data_out = 4'b0011;
            {3'sd2,  3'sd1 }: data_out = 4'b0100;
            {-3'sd2, 3'sd1 }: data_out = 4'b0101;
            {3'sd2,  -3'sd1}: data_out = 4'b0110;
            {-3'sd2, -3'sd1}: data_out = 4'b0111;
            {3'sd1,  3'sd2 }: data_out = 4'b1000;
            {-3'sd1, 3'sd2 }: data_out = 4'b1001;
            {3'sd1,  -3'sd2}: data_out = 4'b1010;
            {-3'sd1, -3'sd2}: data_out = 4'b1011;
            {3'sd2,  3'sd2 }: data_out = 4'b1100;
            {-3'sd2, 3'sd2 }: data_out = 4'b1101;
            {3'sd2,  -3'sd2}: data_out = 4'b1110;
            {-3'sd2, -3'sd2}: data_out = 4'b1111;
            default:          data_out = 4'b0000;
        endcase
    end

endmodule
