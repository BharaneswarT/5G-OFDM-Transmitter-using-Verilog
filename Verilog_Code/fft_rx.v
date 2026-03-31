module fft_rx (
    input  signed [15:0] xf0r, xf0i,   
    input  signed [15:0] xf1r, xf1i,
    input  signed [15:0] xf2r, xf2i,
    input  signed [15:0] xf3r, xf3i,

    output reg signed [15:0] xt0r, xt0i,  
    output reg signed [15:0] xt1r, xt1i,
    output reg signed [15:0] xt2r, xt2i,
    output reg signed [15:0] xt3r, xt3i
);

    // Stage 1 — butterfly pairs (17-bit prevents overflow)
    wire signed [16:0] A0r = xf0r + xf2r;  // A 
    wire signed [16:0] A0i = xf0i + xf2i;
    wire signed [16:0] A1r = xf0r - xf2r;  // B
    wire signed [16:0] A1i = xf0i - xf2i;

    wire signed [16:0] B0r = xf1r + xf3r;  // C 
    wire signed [16:0] B0i = xf1i + xf3i;
    wire signed [16:0] B1r = xf1r - xf3r;  // D 
    wire signed [16:0] B1i = xf1i - xf3i;

    wire signed [16:0] temp_r1 =  B0r;   // C * W^0 = C
    wire signed [16:0] temp_r2 = +B1i;   // D * (-j): real = +Di
    wire signed [16:0] temp_i2 = -B1r;   // D * (-j): imag = -Dr

    // Stage 2 — final butterfly (same structure as IFFT)
    // X[0] = A + C
    // X[1] = B + D*(-j)
    // X[2] = A - C
    // X[3] = B - D*(-j)
    always @(*) begin
    	// X[0] = A + C  (no twiddle)
    	xt0r = A0r + B0r;
    	xt0i = A0i + B0i;

    	// X[1] = B + D*(-j)   
    	xt1r = A1r + B1i;
    	xt1i = A1i - B1r;

    	// X[2] = A - C  (no twiddle)
    	xt2r = A0r - B0r;
    	xt2i = A0i - B0i;

    	// X[3] = B - D*(-j)
   	 xt3r = A1r - B1i;
    	xt3i = A1i + B1r;
end

endmodule
	  