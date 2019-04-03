module cpu_control(
	input [17:0] switches, // SW
	input [3:0] keys, // KEY
	output reg [2:0] clkspeed, // control the clock of the cpu
	output reg [5:0] addressdisplay, // display a value in register at address
	output reg enableloop, // if the program should loop from the last line to first
	output reg [1:0] selectprog, // no longer usefull
	output reg resetcpu, // reset the register values and program counter
	output reg resetpc, // reset program counter
	output reg runprog, // pause program
	output reg manualclk, // button for clock for debug mode
	output reg [15:0] proginstruction, // this function has been outdated by assembler
	output reg backclk, // does not work
	output reg saveinstr // does not work, just use the assembler lol
	);
	// Information:
	// This module is meant to re-route the inputs for ease of use
	// when debugging or running the cpu.
	// mode selection
	wire [1:0] cpumode;
	assign cpumode = switches[17:16];
	// at any change to input
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