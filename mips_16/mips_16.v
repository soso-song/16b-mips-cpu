`timescale 1ns / 1ns // `timescale time_unit/time_precision

module mips_16(
	// Default input output signals, do not change.
	input [17:0] SW,
	input [3:0] KEY,
	output [17:0] LEDR,
	output [7:0] LEDG,
	output [7:0] HEX0,
	output [7:0] HEX1,
	output [7:0] HEX2,
	output [7:0] HEX3,
	output [7:0] HEX4,
	output [7:0] HEX5,
	output [7:0] HEX6,
	output [7:0] HEX7,
	input CLOCK_50,
	// VGA ports, do not change.
	output VGA_CLK,   						//	VGA Clock
	output VGA_HS,							//	VGA H_SYNC
	output VGA_VS,							//	VGA V_SYNC
	output VGA_BLANK_N,						//	VGA BLANK
	output VGA_SYNC_N,						//	VGA SYNC
	output [9:0] VGA_R,   					//	VGA Red[9:0]
	output [9:0] VGA_G,	 					//	VGA Green[9:0]
	output [9:0] VGA_B						//	VGA Blue[9:0]);
	);

	//wires for the inputs from user
	wire [7:0] hexAout, hexBout;
	wire [15:0] hexCout;
	wire [2:0] clkspeedout;
	wire [4:0] addressdisplayout;
	wire enableloopout;
	wire [1:0] selectprogout;
	wire resetcpuout, resetpcout, runprogout, manualclkout, backclkout, saveinstrout;
	wire [15:0] proginstructionout;
	wire key0, key1, key2, key3;
	wire [3:0] keyinput = {~key3, ~key2, ~key1, ~key0};
	
	// Debounce all the keys
	debouncer k0(.clk(CLOCK_50), .PB(KEY[0]), .PB_state(key0));
	debouncer k1(.clk(CLOCK_50), .PB(KEY[1]), .PB_state(key1));
	debouncer k2(.clk(CLOCK_50), .PB(KEY[2]), .PB_state(key2));
	debouncer k3(.clk(CLOCK_50), .PB(KEY[3]), .PB_state(key3));

	// control the inputs from switches
	cpu_control controller(
		.switches(SW[17:0]),
		.keys(keyinput),
		.clkspeed(clkspeedout),
		.addressdisplay(addressdisplayout),
		.enableloop(enableloopout),
		.selectprog(selectprogout),
		.resetcpu(resetcpuout),
		.resetpc(resetpcout),
		.runprog(runprogout),
		.manualclk(manualclkout),
		.proginstruction(proginstructionout),
		.backclk(backclkout),
		.saveinstr(saveinstrout)
		);

	// display wires and modules
	assign regCread = addressdisplayout;
	assign LEDR[17] = SW[17];
	assign LEDR[16] = stableclk;
	assign LEDR[15:0]	= Instruction;
	wire [3:0] hexin0, hexin1, hexin2, hexin3, hexin4, hexin5, hexin6, hexin7;
	assign hexin0 = regCdata[3:0];
	assign hexin1 = regCdata[7:4];
	assign hexin2 = regCdata[11:8];
	assign hexin3 = regCdata[15:12];
	assign hexin4 = Caddr[3:0];
	assign hexin5 = Caddr[7:4];
	assign hexin6 = Caddr[9:8];
	assign hexin7 = ALUop;
	HEX h0(.IN(hexin0), .OUT(HEX0));
	HEX h1(.IN(hexin1), .OUT(HEX1));
	HEX h2(.IN(hexin2), .OUT(HEX2));
	HEX h3(.IN(hexin3), .OUT(HEX3));
	HEX h4(.IN(hexin4), .OUT(HEX4));
	HEX h5(.IN(hexin5), .OUT(HEX5));
	HEX h6(.IN(hexin6), .OUT(HEX6));
	HEX h7(.IN(hexin7), .OUT(HEX7));
	assign LEDG[7] = regWriteEN;
	assign LEDG[6] = ramWriteEN;
	assign LEDG[5] = ZFlag;
	assign LEDG[4] = JFlag;
	assign LEDG[3:0] = {progclk, ramclk, regclk, instrclk};

	// Wire for input to the cpu, use instruction SI[register] to save input
	wire [15:0] inputBus;

	// Wires for the datapath. do not change.
	wire sysclk;
	wire ramWriteEN, regWriteEN, ZFlag, JFlag;
	wire [1:0] selA, selB, selC;
	wire [15:0] muxAout, muxBout, muxCout;
	wire [9:0] Caddr, ramAddress;
	wire [15:0] Instruction;
	wire [15:0] regAdata, regBdata, regCdata;
	wire [3:0] ALUop;
	wire [15:0] ALUout;
	wire [15:0] Immediate;
	wire [9:0] vgaMemAddr;
	wire [15:0] vgaData, ramBdata;
	wire [4:0] regAread, regBread, regCread, regwrite;
	wire [1:0] microcount;
	wire stableclk;

	// Stablize the clock pulse from the rate divider
	stablizer clkfix(.clkin(sysclk), .clkout(stableclk));

	// Microcounter to count cpu microcode
	microcounter micro(.clk(stableclk | manualclkout), .count(microcount));
	
	// clk each stage of the cpu execution so that there are absolutely no race conditions in mem access.
	wire progclk;
	//clkdelay delayprog(sysclk, progclk);
	assign progclk = (microcount == 2'b00)? 1'b1 : 1'b0; // fetch instruction
	
	wire ramclk;
	//clkdelay delayram(progclk, ramclk);
	assign ramclk = (microcount == 2'b01)? 1'b1 : 1'b0; // decode and read memory
	
	wire regclk;
	//clkdelay delayreg(delayclk, regclk);
	assign regclk = (microcount == 2'b10)? 1'b1 : 1'b0; // execute and write back
	
	wire instrclk;
	assign instrclk = (microcount == 2'b11)? 1'b1 : 1'b0; // increment pc
	
	// control the cpu speed
	RATEDIV ratedivider(
		.clkin(CLOCK_50 && runprogout),
		.Rate(clkspeedout),
		.clkout(sysclk),
		.Clear(resetpcout)
		);

	// program counter module
	PCOUNTER programcounter(
		.clk(instrclk),
		.Jaddr(muxBout[9:0]), // input jump addres, truncate extra bits of muxB output
		.Jflag(JFlag),
		.Caddr(Caddr),
		.Enloop(enableloopout),
		.Clear(resetpcout),
		.backclk(backclkout)
		);
		
	// program memory module initialized by mif
	PROGMEM(
	.address(Caddr),
	.clock(progclk),
	.data(proginstructionout),
	.wren(saveinstrout),
	.q(Instruction)
	);

	// cpu control unit
	CTRLUNIT controlunit(
		.Instruction(Instruction), // input
		.ZFlag(ZFlag), // input
		.JFlag(JFlag),
		.RamWriteEN(ramWriteEN),
		.RamAddr(ramAddress),
		.ALUCtrl(ALUop),
		.RegWriteEN(regWriteEN),
		.RegWriteAddr(regwrite),
		.RegAddrA(regAread),
		.RegAddrB(regBread),
		.Immediate(Immediate),
		.MuxA(selA),
		.MuxB(selB),
		.MuxC(selC)
		);

	// multiplexer modules for controlling data
	MUX3 muxA(
		.Ain(regAdata),
		.Bin(Caddr),
		.Cin(inputBus),
		.Select(selA),
		.Output(muxAout)
		);
	MUX3 muxB(
		.Ain(regBdata),
		.Bin(ramBdata),
		.Cin(Immediate),
		.Select(selB),
		.Output(muxBout)
		);
	MUX3 muxC(
		.Ain(Caddr),
		.Bin(ramAddress),
		.Cin(muxAout),
		.Select(selC),
		.Output(muxCout)
		);

	// cpu ALU module
	ALU arithmaticlogic(
		.Ain(muxAout), // input
		.Bin(muxBout), // input
		.MODE(ALUop), // input
		.ALUout(ALUout),
		.FLAGzero(ZFlag)
		);

	// cpu register module
	REGFILE registers(
		.clk(regclk),
		.Reset(resetpcout),
		.Write(regWriteEN),
		.Waddr(regwrite),
		.Wdata(ALUout),
		.Aaddr(regAread),
		.Adata(regAdata), // output
		.Baddr(regBread),
		.Bdata(regBdata), // output
		.Caddr(regCread),
		.Cdata(regCdata) // output
		);
	// Uncomment this module, and comment the cache module if you want to use
	// ram, however the vga moduel will not be able to access memory to draw.
	// do not use both at the same time.
	//	RAM(
	//		.address(muxCout),
	//		.clock(ramclk),
	//		.data(regBdata),
	//		.wren(ramWriteEN),
	//		.q(ramBdata)
	//		);

	// clockless dual read reg file used as cache
	CACHE ram(
		.clk(ramclk),
		.Write(ramWriteEN),
		.Waddr(muxCout),
		.Wdata(regBdata),
		.Aaddr(vgaMemAddr), // memory address for coprocessor
		.Adata(vgaData),
		.Baddr(muxCout[9:0]),
		.Bdata(ramBdata),
		);

	// wires to connect the vga and controller datapath
	wire [15:0] drawCoord, drawCol, drawDim;
	wire [1:0] readState;
	wire vgaclk, reset, go;

	// VGA memory controlls memory access of cache for VGA controller module
	VGAMEMORY vgamem(
		.clk(CLOCK_50),
		.Data(vgaData),
		.Address(vgaMemAddr),
		.coord(drawCoord),
		.col(drawCol),
		.dim(drawDim),
		.state(readState),
		.reset(reset)
		);

	// vga drawing module, draws what data has been accessed by vga memory controller
	VGACONTROLLER vga0(
		.clk(CLOCK_50),
		.state(readState),
		.coordinates(drawCoord),
		.colours(drawCol),
		.dimensions(drawDim),
		.x(x),
		.y(y),
		.colour(colour),
		.clkout(vgaclk),
		.draw(go)
	);

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [14:0] colour;
	wire [7:0] x;
	wire [7:0] y;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			//Signals fSWor the DAC to drive the monitor.
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
	defparam VGA.BACKGROUND_IMAGE = "black.mif";
endmodule

module HEX(IN, OUT);
    input [3:0] IN;
	output reg [7:0] OUT;
	 
	always @(*)
	begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			4'b1010: OUT = 7'b0001000;
			4'b1011: OUT = 7'b0000011;
			4'b1100: OUT = 7'b1000110;
			4'b1101: OUT = 7'b0100001;
			4'b1110: OUT = 7'b0000110;
			4'b1111: OUT = 7'b0001110;
			
			default: OUT = 7'b0111111;
		endcase

	end
endmodule

// debouncer module from internet
module debouncer(
    input clk, //this is a 50MHz clock provided on FPGA pin PIN_Y2
    input PB,  //this is the input to be debounced
    output reg PB_state  //this is the debounced switch
);
/*This module debounces the pushbutton PB.
 *It can be added to your project files and called as is:
 *DO NOT EDIT THIS MODULE
 */

// Synchronize the switch input to the clock
	reg PB_sync_0;
	always @(posedge clk) PB_sync_0 <= PB; 
	reg PB_sync_1;
	always @(posedge clk) PB_sync_1 <= PB_sync_0;

	// Debounce the switch
	reg [15:0] PB_cnt;
	always @(posedge clk)
	if(PB_state==PB_sync_1)
		 PB_cnt <= 0;
	else
	begin
		 PB_cnt <= PB_cnt + 1'b1;  
		 if(PB_cnt == 16'hffff) PB_state <= ~PB_state;  
	end
endmodule

/*
CPU CONTROLS:
SW 17 = mode (run / program)
SW 16 = debug (if prog mode)

if run mode:
inputs:
SW 17 = run mode / program mode
SW 16 = run in debug mode
SW 5:0 = read reg out to hex
SW 15:13 = clk speed
SW 12 = enable loop
SW 11:10 = Select program
KEY 2 = reset cpu
KEY 1 = reset counter
KEY 0 = run program
outputs:
LEDR 17 = run mode
LEDR 16 = clk
LEDR 15:0 = instruction
HEX 5 = REG A
HEX 4 = REG B
HEX 3:0 = read reg C
LEDG 7 = write ram enable
LEDG 6 = write reg enable
LEDG 5 = ALU zero flag
LEDG 4:0 = mux select values

if debug mode:
inputs:
SW 16 = debug mode (if run mode)
SW 5:0 = read reg out to 
SW 12 = enable loop
SW 11:10 = Select program
KEY 2 = reset cpu
KEY 1 = reset counter
KEY 0 = manual clk
outputs:
LEDR 17 = mode
LEDR 16 = clk
LEDR 15:0 = instruction
HEX 5 = REG A
HEX 4 = REG B
HEX 3:0 = read reg C
LEDG 7 = write ram enable
LEDG 6 = write reg enable
LEDG 5 = ALU zero flag
LEDG 4:0 = mux select values

if program mode:
inputs:
SW 17 = prog mode
SW 16 = display reg C / display instruction
SW 9:0 = address reg C (if SW 16 is display reg c value)
SW 15:0 = enter instruction (if SW 16 is display instruction)
KEY 3 = - clk / previous instruction
KEY 2 = save instruction
KEY 1 = reset counter
KEY 0 = clk / next instruction
outputs:
LEDR 17 = show 
LEDR 16 = clk
LEDR 15:0 = instruction / reg c value
HEX 5 = REG A
HEX 4 = REG B
HEX 3:0 = read reg C
LEDG 7 = write ram enable
LEDG 6 = write reg enable
LEDG 5 = ALU zero flag
LEDG 4:0 = mux select values
*/