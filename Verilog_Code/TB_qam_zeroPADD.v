`timescale 1ns/1ps

module TB_qam_zeroPADD;
	
	reg [3:0] data_in;
	wire signed [15:0] X0r, X0i, X1r, X1i, X2r, X2i, X3r, X3i;


	QAM_zeroPADD_TB dut (
        .data_in(data_in),
        .X0r(X0r), .X0i(X0i),
        .X1r(X1r), .X1i(X1i),
        .X2r(X2r), .X2i(X2i),
        .X3r(X3r), .X3i(X3i)
    );

    initial begin
        $monitor("Time=%0t | data=%b | bin0=(%3d,%3d) bin1=(%3d,%3d) bin2=(%3d,%3d) bin3=(%3d,%3d)",$time, data_in, X0r,X0i, X1r,X1i, X2r,X2i, X3r,X3i);

        data_in = 4'b0000; #10;
        data_in = 4'b0001; #10;
        data_in = 4'b1100; #10;
        data_in = 4'b1111; #10;
        $finish;
    end

endmodule