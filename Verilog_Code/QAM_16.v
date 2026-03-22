module QAM_16 (
	input [3:0] in_data,
	output reg signed [15:0] I_out,
	output reg signed [15:0] Q_out
);

always @(*) begin 
	case (in_data)
		4'b0000: begin I_out =  16'sd1;   Q_out =  16'sd1;   end
        	4'b0001: begin I_out = -16'sd1;   Q_out =  16'sd1;   end
        	4'b0010: begin I_out =  16'sd1;   Q_out = -16'sd1;   end
        	4'b0011: begin I_out = -16'sd1;   Q_out = -16'sd1;   end 
        	4'b0100: begin I_out =  16'sd2;   Q_out =  16'sd1;   end
        	4'b0101: begin I_out = -16'sd2;   Q_out =  16'sd1;   end
        	4'b0110: begin I_out =  16'sd2;   Q_out = -16'sd1;   end
        	4'b0111: begin I_out = -16'sd2;   Q_out = -16'sd1;   end
        	4'b1000: begin I_out =  16'sd1;   Q_out =  16'sd2;   end
        	4'b1001: begin I_out = -16'sd1;   Q_out =  16'sd2;   end
        	4'b1010: begin I_out =  16'sd1;   Q_out = -16'sd2;   end
        	4'b1011: begin I_out = -16'sd1;   Q_out = -16'sd2;   end       
        	4'b1100: begin I_out =  16'sd2;   Q_out =  16'sd2;   end
        	4'b1101: begin I_out = -16'sd2;   Q_out =  16'sd2;   end
        	4'b1110: begin I_out =  16'sd2;   Q_out = -16'sd2;   end
        	4'b1111: begin I_out = -16'sd2;   Q_out = -16'sd2;   end
        
        	default: begin I_out = 16'sd0;    Q_out = 16'sd0;    end
	endcase
end
endmodule
 