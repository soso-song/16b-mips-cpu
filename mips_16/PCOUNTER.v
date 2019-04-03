module PCOUNTER(
	input clk, // input clk
	input [9:0] Jaddr, // input jump address to jump to
	input Jflag, // jump flag
	output reg [9:0] Caddr, // current address at
	input Enloop, // if should loop from last to first line
	input Clear, // go back to line 0
	input backclk // decrease program count
	);
	// update on clk or clear
	always @(posedge clk or posedge backclk or posedge Clear)
	begin
		if (Clear == 1'b1) begin // clear the value
			Caddr = 10'd0;
		end
		else if (backclk == 1'b1) begin // back clk if possible
			if (Caddr != 10'b0000000000) begin
				Caddr <= Caddr - 1'b1;
			end
		end
		else if(Jflag == 1'b1) begin // jump to new address if jump flag
			Caddr <= Jaddr;
		end
		else if(Caddr == 10'b1111111111) begin // loop if enabled
			if(Enloop == 1'b1) begin
				Caddr <= 10'd0;
			end
		end
		else begin
			Caddr <= Caddr + 1'b1; // count up
		end
	end
endmodule

module microcounter(
	input clk, // input clk (stablized)
	output reg [1:0] count // output current microcode count
	);
	// update on clk
	always @(posedge clk)
	begin
		if (count == 2'b11) begin
			count <= 2'b00;
		end
		else begin
			count <= count + 1'b1;
		end
	end
endmodule

module stablizer(
	input clkin,
	output reg clkout
	);
	// update on clk
	always @(posedge clkin)
	begin
		if (clkout == 1'b1) begin
			clkout <= 1'b0;
		end
		else begin
			clkout <= 1'b1;
		end
	end
endmodule

module RATEDIV(
	input clkin,
	input [2:0] Rate,
	output clkout,
	input Clear
	);
	// create register for current rate and count
	reg [25:0] currRate;
	reg [25:0] currCount = 26'd0;
	// select a rate
	always @(Rate)
	begin
		case (Rate)
		3'b000: currRate = 26'd4999999; // 10hz
		3'b001: currRate = 26'd2499999; // 50hz
		3'b010: currRate = 26'd499999; // 100hz
		3'b011: currRate = 26'd49999; // 1000hz
		3'b100: currRate = 26'd4999; // 10,000hz
		3'b101: currRate = 26'd499; // 100,000z
		3'b110: currRate = 26'd49; // 1,000,000hz
		3'b111: currRate = 26'd1; // 50,000,000hz
		endcase
	end
	// counter section
	always @(posedge clkin or posedge Clear)
	begin
		if(Clear == 1'b1) begin
			currCount <= currRate;
		end
		else if(currCount == 26'd0) begin
			currCount <= currRate;
		end
		else begin
			currCount <= currCount - 1'b1;
		end
	end
	// generate clock pulse
	assign clkout = (currCount == currRate)? 1:0;
endmodule
