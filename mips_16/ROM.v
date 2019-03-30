//module INSTRMEM(Addr, Sel, Instr);
//	input [9:0] Addr;
//	input [1:0] Sel;
//	output reg [15:0] Instr;
//	
//	reg [9:0] address1;
//	reg [9:0] address2;
//	reg [9:0] address3;
//	reg [9:0] address4;
//	
//	wire [15:0] instruction1;
//	wire [15:0] instruction2;
//	wire [15:0] instruction3;
//	wire [15:0] instruction4;
//	
//	always @(Sel)
//	begin
//		case (Sel)
//		2'b00: begin
//					address1 = Addr;
//					address2 = 16'd0;
//					address3 = 16'd0;
//					address4 = 16'd0;
//				end
//		2'b01: begin
//					address1 = 16'd0;
//					address2 = Addr;
//					address3 = 16'd0;
//					address4 = 16'd0;
//				end
//		2'b10: begin
//					address1 = 16'd0;
//					address2 = 16'd0;
//					address3 = Addr;
//					address4 = 16'd0;
//				end
//		2'b11: begin
//					address1 = 16'd0;
//					address2 = 16'd0;
//					address3 = 16'd0;
//					address4 = Addr;
//				end
//		endcase
//	end
//	
//	always @(*)
//	begin
//		case (Sel)
//		2'b00: Instr <= instruction1;
//		2'b01: Instr <= instruction2;
//		2'b10: Instr <= instruction3;
//		2'b11: Instr <= instruction4;
//		endcase
//	end
//	
//	ROM1 program1(.Addr(address1), .Instr(instruction1));
//	ROM2 program2(.Addr(address2), .Instr(instruction2));
//	ROM3 program3(.Addr(address3), .Instr(instruction3));
//	ROM4 program4(.Addr(address4), .Instr(instruction4));
//
//endmodule
//
//
//
//module ROM1(Addr, Instr);
//	input [9:0] Addr;
//	output [15:0] Instr;
//		
//	reg [15:0] ROM[1023:0];
//	
//	initial
//	begin
//		// Paste program here
//		ROM[0] = 16'b0000000000000001;
//		ROM[1] = 16'b0000000000000010;
//		ROM[2] = 16'b0000000000000101;
//		ROM[3] = 16'b0000000000010101;
//		ROM[4] = 16'b1111111111111111;
//		ROM[593] = 16'b1011011000101001;
//	end
//	
//	assign Instr = ROM[Addr];
//endmodule
//
//module ROM2(Addr, Instr);
//	input [9:0] Addr;
//	output [15:0] Instr;
//		
//	reg [15:0] ROM[1023:0];
//	
//	initial
//	begin
//		// Paste program here
//		ROM[0] = 16'b0000000000000010;
//	end
//	
//	assign Instr = ROM[Addr];
//endmodule
//
//module ROM3(Addr, Instr);
//	input [9:0] Addr;
//	output [15:0] Instr;
//		
//	reg [15:0] ROM[1023:0];
//	
//	initial
//	begin
//		// Paste program here
//		ROM[0] = 16'b0000000000000100;
//	end
//	
//	assign Instr = ROM[Addr];
//endmodule

module ROM4(Addr, Instr);
	input [9:0] Addr;
	output [15:0] Instr;
		
	reg [15:0] ROM[1023:0];
	
	initial
	begin
		// Paste program here
		ROM[0] = 16'b0000000000000000;
		ROM[1] = 16'b0011100000000001;
		ROM[2] = 16'b0001000000100010;
		ROM[3] = 16'b0001000000000001;
		ROM[4] = 16'b0100010001000011;
		ROM[5] = 16'b0001000000100011;
		ROM[6] = 16'b0010110001111111;
		ROM[7] = 16'b0000000000000000;
		ROM[8] = 16'b0001010000000011;
		ROM[9] = 16'b0001000000000011;
		ROM[10] = 16'b0001110000000011;
		/*
		while(true){
			i = 0;
			while(i < 32){
				i++;
			}
		}
		*/
	end
	
	assign Instr = ROM[Addr];
endmodule
