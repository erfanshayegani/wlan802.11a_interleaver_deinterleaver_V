module itok(Ncbps,i,k);
	input wire [6:0]Ncbps; // 96 or 48, 96 necessiates 7 bits
	input wire [6:0]i;
	output reg [6:0]k; // will be assigned in always so it has to be reg 
	//assign i = (4'd3)*(k%(5'd16)) + (k >> 4);	
	always@(*)
	begin
		if (Ncbps == 7'd48)
		begin
			k = (i<<4) - 47*((i<<4)/48);
		end
		else if (Ncbps == 7'd96)
		begin
			k = (i<<4) - 95*((i<<4)/96);
		end
		else // avoid latch
			k = 8'b0;
	end
	
endmodule
