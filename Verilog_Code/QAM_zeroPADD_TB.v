module QAM_zeroPADD_TB(
	input [3:0] data_in,           

	output signed [15:0] X0r, X0i, 
    	output signed [15:0] X1r, X1i,
    	output signed [15:0] X2r, X2i,
    	output signed [15:0] X3r, X3i
);

    	wire signed [15:0] I_qam;
    	wire signed [15:0] Q_qam;


    	QAM_16 qam_inst (
        	.in_data(data_in),
        	.I_out(I_qam),
        	.Q_out(Q_qam)
    	);

    	
    	zero_padd pad_inst ( 
        	.I_in(I_qam),
        	.Q_in(Q_qam),
        
        	.x1i(X0r), .x1q(X0i),     //x1 = bin 0
        	.x2i(X1r), .x2q(X1i),     //x2 = bin 1
        	.x3i(X2r), .x3q(X2i),     //x3 = bin 2 (zero)
        	.x4i(X3r), .x4q(X3i)      //x4 = bin 3 (zero)
    	);

endmodule