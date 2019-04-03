module MUX2(
	input [15:0] Ain, // mux inputs
	input [15:0] Bin,
	input Select, // control signal
	output reg [15:0] Output // output value
	);
	// mux case
	assign Output = (Select == 1'b0)? Ain : Bin;
endmodule

module MUX3(
	input [15:0] Ain, // mux inputs
	input [15:0] Bin,
	input [15:0] Cin,
	input [1:0] Select, // control signal
	output reg [15:0] Output
	);
	// mux case
	always @(*)
	begin
		case (Select)
		2'b00: Output = Ain;
		2'b01: Output = Bin;
		2'b10: Output = Cin;
		2'b11: Output = 16'd0; // default value
		endcase
	end
endmodule

module MUX4(
	input [15:0] Ain, // mux inputs
	input [15:0] Bin,
	input [15:0] Cin,
	input [15:0] Din,
	input [1:0] Select, // control signal
	output reg [15:0] Output
	);
	// mux case
	always @(*)
	begin
		case (Select)
		2'b00: Output = Ain;
		2'b01: Output = Bin;
		2'b10: Output = Cin;
		2'b11: Output = Din;
		endcase
	end
endmodule

