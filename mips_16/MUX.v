module MUX2(Ain, Bin, Select, Output);
	input [15:0] Ain, Bin;
	input Select;
	output [15:0] Output;

	assign Output = (Select == 1'b0)? Ain : Bin;
endmodule

module MUX3(Ain, Bin, Cin, Select, Output);
	input [15:0] Ain, Bin, Cin;
	input [1:0] Select;
	output reg [15:0] Output;

	always @(*)
	begin
		case (Select)
		2'b00: Output = Ain;
		2'b01: Output = Bin;
		2'b10: Output = Cin;
		2'b11: Output = 16'd0;
		endcase
	end
endmodule

module MUX4(Ain, Bin, Cin, Din, Select, Output);
	input [15:0] Ain, Bin, Cin, Din;
	input [1:0] Select;
	output reg [15:0] Output;

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

