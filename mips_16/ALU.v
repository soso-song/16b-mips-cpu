module ALU(Ain, Bin, MODE, ALUout, FLAGzero);
	input [15:0] Ain;
	input [15:0] Bin;
	input [3:0] MODE;
	output FLAGzero;
	output reg [15:0] ALUout;
	
	always @(*) // declare always block
	begin
		case (MODE) // start case statement
			4'b0000: ALUout = 16'd0;		// output 0
			4'b0001: ALUout = Ain + Bin;	// addition
			4'b0010: ALUout = Ain - Bin;	// subtraction A - B
			4'b0011: ALUout = Ain & Bin;	// bitwise AND
			4'b0100: ALUout = Ain | Bin;	// bitwise OR
			4'b0101: ALUout = Ain ^ Bin;	// bitwise XOR
			4'b0110: ALUout = ~Ain;			// bitwise NOT on A
			4'b0111: ALUout = Ain * Bin;	// multiplication
			4'b1000: ALUout = Ain / Bin;	// division
			4'b1001: ALUout = Ain % Bin;	// modulus
			4'b1010: ALUout = Ain<<Bin;	// shift left
			4'b1011: ALUout = Ain>>Bin;	// shift right
			4'b1100: ALUout = Ain;			// mux A
			4'b1101: ALUout = Bin;			// mux B
			4'b1110: begin if (Ain != Bin) ALUout = 16'd1;	// inequality, 1 if a != b
							else ALUout = 16'd0;
							end
			4'b1111: begin if (Ain < Bin) ALUout = 16'd1;		// inequality, 1 if a < b
							else ALUout = 16'd0;
							end
		endcase
	end
	assign FLAGzero = (ALUout == 16'd0) ? 1'b1: 1'b0;	// assign the zero flag
endmodule
