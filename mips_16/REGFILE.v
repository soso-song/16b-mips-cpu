module REGFILE(
	input clk, // clk
	input Reset, // reset signal
	input Write, // write enable signal
	input [4:0] Waddr, // write address
	input [15:0] Wdata, // data to write in
	input [4:0] Aaddr, // address for reading out data
	output [15:0] Adata, // value read out at address
	input [4:0] Baddr,
	output [15:0] Bdata,
	input [4:0] Caddr,
	output [15:0] Cdata
	);
	reg [5:0] i = 6'd0;
	// create a register array of size 32
	reg [15:0] register[31:0];
	// update on clk input
	always @(posedge clk)
	begin
		if (Write == 1'b1) begin
			register[Waddr] <= Wdata; // write data to register
		end
		else if (Reset == 1'b1) begin
			for(i = 0; i < 32; i = i + 1) begin // reset all register values
				register[i] <= 16'd0;
			end
			i <= 6'b0;
		end
	end
	// set read values
	assign Adata = (Aaddr == 0)? 16'd0 : register[Aaddr];
	assign Bdata = (Baddr == 0)? 16'd0 : register[Baddr];
	assign Cdata = (Caddr == 0)? 16'd0 : register[Caddr]; // This reg is for display purposes only
endmodule

module CACHE(
	input clk, // input clk
	input Write, // write enable
	input [9:0] Waddr, // write address
	input [15:0] Wdata, // write data
	input [9:0] Aaddr, // read address
	output [15:0] Adata, // read data
	input [9:0] Baddr,
	output [15:0] Bdata
	);
	// create cache size of 1024 words
	reg [15:0] register[1023:0];
	// update on clk input
	always @(posedge clk)
	begin
		if (Write)
		begin
			register[Waddr] <= Wdata; // write data
		end
	end
	// set read values
	assign Adata = register[Aaddr]; // set read values
	assign Bdata = register[Baddr];
endmodule
