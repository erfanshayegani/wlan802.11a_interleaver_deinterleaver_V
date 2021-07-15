`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:22:04 01/23/2021 
// Design Name: 
// Module Name:    deinterleaver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module deinterleaver(
    input wire clk,
    input wire reset,
    input wire in,
    output reg out
    );

	reg [6:0]i;
	wire [6:0]k;
	reg [6:0]Ncbps;
	
// Instantiate the module
itok itok (
    .Ncbps(Ncbps), 
    .i(i), 
    .k(k)
    );

//combo logic which maps k to i 
	reg flag;
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
		begin
			i <= 0;
			Ncbps <= 7'd48;
			flag <= 0;
		end	
		else if (Ncbps == 7'd48 && i == 7'd47)
		begin
			i <= 0;
			Ncbps <= 7'd96;
			flag <= 1;
		end	
		else if (i == 7'd95)
		begin
			i <= 0;
			flag <= ~flag;
		end	
		else
			i <= i+1;
	end	


	reg [0:47]signal;
	
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
			signal <= 0;
		else if(Ncbps == 7'd48)
			signal[k] <= in;
	end
	
	
	reg [0:95]a,b;
	
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
		begin
			a <= 0; b <= 0;
		end
		else if (Ncbps == 7'd96 && flag == 1)	
			a[k] <= in;
		else if (Ncbps == 7'd96 && flag == 0)	
			b[k] <= in;
	end
	

	reg [7:0]counter;
	
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
			counter <= 0;
		else if (counter < 8'd143)
			counter <= counter +1;
		else if (counter == 8'd143)
			counter <= 8'd255; // acts as a flag
	end	
	
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
		begin
			
		end
		else if (counter <= 143)
		begin
			if (counter >= 96)
			begin
				out <= signal[counter - 96];
			end
		end
		else if (counter == 255 && flag == 0)
			out <= a[i];
		else if (counter == 255 && flag == 1)
			out <= b[i];	
	end


endmodule
