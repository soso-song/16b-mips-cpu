module PCOUNTER(clk, Jaddr, Jflag, Caddr, Enloop, Clear, backclk);
	input clk, Jflag, Enloop, Clear, backclk;
	input [9:0] Jaddr;
	output reg [9:0] Caddr;

	always @(posedge clk or posedge backclk or posedge Clear)
	begin
		if (Clear == 1'b1) begin
			Caddr = 10'd0;
		end
		else if (backclk == 1'b1) begin
			if (Caddr != 10'b0000000000) begin
				Caddr <= Caddr - 1'b1;
			end
		end
		else if(Jflag == 1'b1) begin
			Caddr <= Jaddr;
		end
		else if(Caddr == 10'b1111111111) begin
			if(Enloop == 1'b1) begin
				Caddr <= 10'd0;
			end
		end
		else begin
			Caddr <= Caddr + 1'b1;
		end
	end
endmodule

module microcounter(clk, count);
	input clk;
	output reg [1:0] count;
	
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

module stablizer(clkin, clkout);
	input clkin;
	output reg clkout;
	
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

module RATEDIV(clkin, Rate, clkout, Clear);
	input clkin, Clear;
	input [2:0] Rate;
	output clkout;
	
	reg [25:0] currRate;
	reg [25:0] currCount = 26'd0;
	
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
	
	assign clkout = (currCount == currRate)? 1:0;
endmodule
