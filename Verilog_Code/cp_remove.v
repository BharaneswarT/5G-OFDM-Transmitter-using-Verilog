module cp_remove(
	input signed[15:0] in0r, in0i,
	input signed[15:0] in1r, in1i, 
	input signed[15:0] in2r, in2i, 
	input signed[15:0] in3r, in3i, 
	input signed[15:0] in4r, in4i, 
	
	output signed [15:0] out1r, out1i,
	output signed [15:0] out2r, out2i,
	output signed [15:0] out3r, out3i,
	output signed [15:0] out4r, out4i
);
	assign out1r = in1r;
	assign out2r =  in2r;
	assign out3r =  in3r;
	assign out4r =  in4r;

	assign out1i = in1i;
	assign out2i =  in2i;
	assign out3i = in3i;
	assign out4i =in4i;
	
endmodule 

