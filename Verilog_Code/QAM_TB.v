`timescale 1ns / 1ps
module QAM_TB;
	reg [3:0] in_data;
	wire signed [15:0] I_out;
	wire signed [15:0] Q_out;
	
	QAM_16 DUT(
		.in_data(in_data),
		.I_out(I_out),
		.Q_out(Q_out)
	);
	
	initial begin
        $monitor("Time=%0t | in_data=%b | I=%d | Q=%d", $time, in_data, I_out, Q_out);
        in_data = 4'b0000; #10;
        in_data = 4'b0001; #10;
        in_data = 4'b0010; #10;
        in_data = 4'b0011; #10;
        in_data = 4'b1100; #10;
        in_data = 4'b1111; #10;
        in_data = 4'bxxxx; #10;  
        
        $finish;
    end

endmodule
