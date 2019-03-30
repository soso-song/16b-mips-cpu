module REGFILE(clk, Reset, Write, Waddr, Wdata, Aaddr, Adata, Baddr, Bdata, Caddr, Cdata);
	input Write, clk, Reset;
	input [4:0] Waddr, Aaddr, Baddr, Caddr;
	input [15:0] Wdata;
	output [15:0] Adata, Bdata, Cdata;
	
	reg [15:0] register[31:0];
	
	always @(posedge clk)
	begin
		if (Write == 1'b1) begin
			register[Waddr] <= Wdata;
		end
		else if (Reset == 1'b1) begin
			register[1] <= 16'd0;
			register[2] <= 16'd0;
			register[3] <= 16'd0;
			register[4] <= 16'd0;
			register[5] <= 16'd0;
			register[6] <= 16'd0;
			register[7] <= 16'd0;
			register[8] <= 16'd0;
			register[9] <= 16'd0;
			register[10] <= 16'd0;
			register[11] <= 16'd0;
			register[12] <= 16'd0;
			register[13] <= 16'd0;
			register[14] <= 16'd0;
			register[15] <= 16'd0;
			register[16] <= 16'd0;
			register[17] <= 16'd0;
			register[18] <= 16'd0;
			register[19] <= 16'd0;
			register[20] <= 16'd0;
			register[21] <= 16'd0;
			register[22] <= 16'd0;
			register[23] <= 16'd0;
			register[24] <= 16'd0;
			register[25] <= 16'd0;
			register[26] <= 16'd0;
			register[27] <= 16'd0;
			register[28] <= 16'd0;
			register[29] <= 16'd0;
			register[30] <= 16'd0;
			register[31] <= 16'd0;
		end
	end
	
	assign Adata = (Aaddr == 0)? 16'd0 : register[Aaddr];
	assign Bdata = (Baddr == 0)? 16'd0 : register[Baddr];
	assign Cdata = (Caddr == 0)? 16'd0 : register[Caddr]; // This reg is for display purposes only
endmodule

module CACHE(clk, Write, Waddr, Wdata, Aaddr, Adata, Baddr, Bdata);
	input Write, clk;
	input [9:0] Waddr, Aaddr, Baddr;
	input [15:0] Wdata;
	output [15:0] Adata, Bdata;
	
	reg [15:0] register[63:0];
	
	always @(posedge clk)
	begin
		if (Write)
		begin
			register[Waddr] <= Wdata;
		end
	end
	
	assign Adata = register[Aaddr];
	assign Bdata = register[Baddr];
endmodule
