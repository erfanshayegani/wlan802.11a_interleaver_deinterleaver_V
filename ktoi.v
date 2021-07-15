module ktoi(Ncbps,k,i);
	input wire [6:0]Ncbps; // 96 or 48, 96 necessiates 7 bits
	input wire [6:0]k;
	output reg [7:0]i;
	//assign i = (4'd3)*(k%(5'd16)) + (k >> 4);	
	always@(*)
	begin
		if (Ncbps == 7'd48)
		begin
			i = (4'd3)*(k%(5'd16)) + (k >> 4);
		end
		else if (Ncbps == 7'd96)
		begin
			i = (4'd6)*(k%(5'd16)) + (k >> 4);
		end
		else // avoid latch
			i = 8'b0;
	end
	
endmodule
