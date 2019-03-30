module cpu_control(
	switches,
	keys,
	clkspeed,
	addressdisplay,
	enableloop,
	selectprog,
	resetcpu,
	resetpc,
	runprog,
	manualclk,
	proginstruction,
	backclk,
	saveinstr
	);				
	input [17:0] switches;
	input [3:0] keys;
	
	wire [1:0] cpumode;
	assign cpumode = switches[17:16];
	
	output reg [2:0] clkspeed;
	output reg [5:0] addressdisplay;
	output reg enableloop;
	output reg [1:0] selectprog;
	output reg resetcpu, resetpc, runprog, manualclk;
	
	output reg [15:0] proginstruction;
	output reg backclk, saveinstr;
	
	always @(*)
	begin
		case (cpumode)
		2'b00: begin // idle mode
				clkspeed 			= 3'b000;
				addressdisplay 	= 5'b00000;
				enableloop 			= 1'b0;
				selectprog 			= 2'b00;
				resetcpu 			= 1'b0;
				resetpc 				= 1'b0;
				runprog 				= 1'b0;
				manualclk 			= 1'b0;
				proginstruction 	= 16'b0;
				backclk 				= 1'b0;
				saveinstr 			= 1'b0;
				end
		2'b01: begin // program mode (doesnt work, use assembler and mif programmer instead.)
				clkspeed 			= 3'b000; // no one wants to program in binary using switches anyways. It sucks.
				addressdisplay 	= 5'b00001;
				enableloop 			= 1'b0;
				selectprog 			= 2'b00;
				resetcpu 			= 1'b0;
				resetpc 				= keys[1];
				runprog 				= 1'b0;
				manualclk 			= keys[0];
				proginstruction 	= switches[15:0];
				backclk 				= keys[3];
				saveinstr 			= keys[2];
				end
		2'b10: begin // run mode
				clkspeed 			= switches[15:13];
				addressdisplay 	= switches[5:0];
				enableloop 			= switches[12];
				selectprog 			= switches[11:10];
				resetcpu 			= keys[2];
				resetpc 				= keys[1];
				runprog 				= switches[9];
				manualclk 			= 1'b0;
				proginstruction 	= 16'd0;
				backclk 				= 1'b0;
				saveinstr 			= 1'b0;
				end
		2'b11: begin // debug mode
				clkspeed 			= 3'b000;
				addressdisplay 	= switches[5:0];
				enableloop 			= switches[12];
				selectprog 			= switches[11:10];
				resetcpu 			= keys[2];
				resetpc 				= keys[1];
				runprog 				= switches[9];
				manualclk 			= keys[0];
				proginstruction 	= 16'd0;
				backclk 				= 1'b0;
				saveinstr 			= 1'b0;
				end
		endcase
	end
endmodule