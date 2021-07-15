`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:56:07 01/22/2021 
// Design Name: 
// Module Name:    interleaver 
// Project Name: 
///////////////////////////////////////
module interleaver(
    input wire clk,
    input wire reset,
    input wire in,
    output reg out
    );
	
	reg [6:0]k;
	wire [7:0]i;
	reg [6:0]Ncbps;
	
// Instantiate the module
ktoi ktoi (
    .Ncbps(Ncbps), 
    .k(k), 
    .i(i)
    );
//combo logic which maps k to i 
	
	/*
		if flag is 1, we fill a with input and get output from b
		if flag is 0, we fill b with input and get output from a
		
		this always block configures k,Ncbps,flag
	*/
	reg flag; 
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
		begin
			k <= 0;
			Ncbps <= 7'd48;
			flag <= 0;
		end	
		else if (Ncbps == 7'd48 && k == 7'd47) // the point where we have completely received SIGNAL part 
		begin												// and from next clk Ncbps changes and DATA field starts!
			k <= 0;
			Ncbps <= 7'd96;
			flag <= 1; // fill a with input
		end	
		else if (k == 7'd95) // switch from a to b or vice versa
		begin
			k <= 0;
			flag <= ~flag;
		end	
		else
			k <= k+1; // increment k every clock
	end	
	
	
	/*
	this always block configures signal memory
	as long as Ncbps is 48, we put input in the appropriate index in SIGNAL memory
	the index (i) is determined by combo logic 
	k -> combo logic -> i
	*/

	reg [0:47]signal; // this is the memory where I insert the interleaved SIGNAL
							// first 48 bits we receive and perform interleaving on them
	
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
			signal <= 0;
		else if(Ncbps == 7'd48)
			signal[i] <= in;
	end
	
	
	
	/*
	this always block configures a and b-96 bits memories
	if flag is 1 we fill a
	if flag is 0 we fill b
	Ncbps == 96 indicates whether SIGNAL part ( first 48 bits ) have been finished or not
	*/
	
	reg [0:95]a,b; // two 96 bits memories
	
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
		begin
			a <= 0; b <= 0;
		end
		else if (Ncbps == 7'd96 && flag == 1)	
			a[i] <= in;
		else if (Ncbps == 7'd96 && flag == 0)	
			b[i] <= in;
	end
	
	
	/*
	this always block configures a counter I defined only for first 144 clocks,
	its more like an assistance
	when it becomes 255, it tells me from that moment on output is supplied with a and b not the SIGNAL memory
	*/

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
	
	
	/*
	this always block configures output
	when counter reaches 96 we start sending output from SIGNAL mem, for 48 clk cycles which 
	means 144 the clk, from that moment on counter turns 255 and remains constant 
	and indicates that output should be supplied
	from a and b then a then b then a then b and so forth
	*/
	
	always@(posedge clk or negedge reset)
	begin
		if (!reset)
		begin
			// output is X until the 96th clk
		end
		else if (counter <= 143)
		begin
			if (counter >= 96)
			begin
				out <= signal[counter - 96]; // output is supplied from SIGNAL mem
			end
		end
		else if (counter == 255 && flag == 0) //output from a and b
			out <= a[k];
		else if (counter == 255 && flag == 1)
			out <= b[k];	
	end
	
	
endmodule
