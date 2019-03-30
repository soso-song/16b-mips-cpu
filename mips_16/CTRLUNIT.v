module CTRLUNIT(Instruction, ZFlag, JFlag, RamWriteEN, RamAddr, ALUCtrl, RegWriteEN, RegWriteAddr, RegAddrA, RegAddrB, Immediate, MuxA, MuxB, MuxC);
	input [15:0] Instruction;
	input ZFlag;
	output reg RamWriteEN, RegWriteEN, JFlag;
	output reg [9:0] RamAddr;
	output reg [4:0] RegWriteAddr, RegAddrA, RegAddrB;
	output reg [9:0] Immediate;
	output reg [1:0] MuxA, MuxB, MuxC;
	output reg [3:0] ALUCtrl;
	
	wire [5:0] Opcode;
	wire [9:0] Address;
	wire [4:0] AddressA, AddressB;
	
	assign Opcode = Instruction[15:10]; // 6 bit
	assign Address = Instruction[9:0]; // 10 bit
	assign AddressA = Address[9:5]; // 5 bit
	assign AddressB = Address[4:0]; // 5 bit
	
	
	
	always @(*)
	begin
		case (Opcode)
		6'b000000: begin // NOP Do nothing
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00000;
					RegAddrA 		= 5'b00000;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0000;
					Immediate		= 10'b0000000000;
					end
		6'b000001: begin // LW[ADDRESS] Load word from Address in ram into register 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b01;
					MuxC				= 2'b01;
					RamAddr 			= Address;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= 5'b00000;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1101;
					Immediate		= 10'b0000000000;
					end
		6'b000010: begin // SW[ADDRESS] Save word from register 1 into Address in ram
					RamWriteEN 		= 1'b1;
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b01;
					RamAddr 			= Address;
					RegWriteAddr 	= 5'b00000;
					RegAddrA 		= 5'b00000;
					RegAddrB 		= 5'b00001;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0000;
					Immediate		= 10'b0000000000;
					end
		6'b000011: begin // MV[REGISTER][REGISTER] move register data from regA to regB
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= AddressB;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1100;
					Immediate		= 10'b0000000000;
					end
		6'b000100: begin // BGZ[ADDRESS] Branch to Address if the value in register 1 is greater than 0
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10; // Mux immediate address to the program counter
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00000;
					RegAddrA 		= 5'b00001; // Read reg 1 value to ALU
					RegAddrB 		= 5'b00000;
					JFlag				= ~ZFlag; // Set JFlag
					ALUCtrl			= 4'b1100; // Mux Ain
					Immediate		= Address; // Load address into immediate
					end
		6'b000101: begin // BEZ[ADDRESS] Branch to Address if the value in register 1 is 0
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00000;
					RegAddrA 		= 5'b00001;
					RegAddrB 		= 5'b00000;
					JFlag				= ZFlag;
					ALUCtrl			= 4'b1100;
					Immediate		= Address;
					end
		6'b000110: begin // JMP[ADDRESS] Jump to given immediate address
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00000;
					RegAddrA 		= 5'b00000;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b1;
					ALUCtrl			= 4'b0000;
					Immediate		= Address;
					end
		6'b000111: begin // JAL[REGISTER] Save current address into reg a to prepare for a jump (only works for mips32, mips16 must use several steps)
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;	// save to register 1
					MuxA 				= 1'b01;	// select input from pc
					MuxB 				= 2'b10; // select input from immediate
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= AddressA;
					RegAddrA 		= 5'b00000;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0; // This command does not jump! it prepares for a JAL
					ALUCtrl			= 4'b1100;	// mux Ain
					Immediate		= 10'b0000000000;
					end
		6'b001000: begin // JR[REGISTER] Jump to the address stored in register at address, note the last 5 bits of this instruction are ignored
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00; // mux address from bus B
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00000;
					RegAddrA 		= 5'b00000;
					RegAddrB 		= AddressA; // Read address into bus B
					JFlag				= 1'b1; // set jump flag
					ALUCtrl			= 4'b0000;
					Immediate		= 10'b0000000000;
					end
		6'b001001: begin // SLT[REGISTER][REGISTER] Set the value in register 1 to 1 if the value in reg a < reg b, 0 otherwise
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1; // Enable write to reg 1
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001; // Address reg 1
					RegAddrA 		= AddressA; // Read Ain
					RegAddrB 		= AddressB; // Read Bin
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1111; // set ALU to compare mode
					Immediate		= 10'b0000000000;
					end
		6'b001010: begin // SLTI[REGISTER][IMMEDIATE] Set the value in register 1 to 1 if the reg a < immediate, 0 otherwise
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1; // Enable write to reg 1
					MuxA 				= 1'b00;
					MuxB 				= 2'b10; // Mux immediate to ALU
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001; // Address reg 1
					RegAddrA 		= AddressA; // Read Ain
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1111; // set ALU to compare mode
					Immediate		= {5'b00000, AddressB};
					end
		6'b001011: begin // SEQ[REGISTER][REGISTER] Set the value in reg 1 to 1 if reg a != reg b, 0 otherwise
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1; // Enable write to reg 1
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001; // Address reg 1
					RegAddrA 		= AddressA; // Read Ain
					RegAddrB 		= AddressB; // Read Bin
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1110; // Set ALU mode
					Immediate		= 10'b0000000000;
					end
		6'b001100: begin // SEQI[REGISTER][IMMEDIATE] Set the value in reg 1 to 1 if reg a != immeduate, 0 otherwise
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1; // Enable write to reg 1
					MuxA 				= 1'b00;
					MuxB 				= 2'b10; // Mux immediate to ALU
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001; // Address reg 1
					RegAddrA 		= AddressA; // Read Ain
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1110; // set ALU to compare mode
					Immediate		= {5'b00000, AddressB};
					end
		6'b001101: begin // LIM[IMMEDIATE] Load a 10 bit immediate into register 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1; // Enable reg 1 write
					MuxA 				= 1'b00;
					MuxB 				= 2'b10; // Mux immediate to reg file
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001; // Address reg 1
					RegAddrA 		= 5'b00000;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1101;
					Immediate		= Address; // Immediate
					end
		6'b001110: begin // SL[REGISTER][REGISTER] Shift bits in reg a left by reg b bits
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1010; // Shift mode
					Immediate		= 10'b0000000000;
					end
		6'b001111: begin // SR[REGISTER][REGISTER] Shift bits in reg a right by reg b bits
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1011; // Shift mode
					Immediate		= 10'b0000000000;
					end
		6'b010000: begin // ADD[REGISTER][REGISTER] Add reg a to reg b and store results in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0001;
					Immediate		= 10'b0000000000;
					end
		6'b010001: begin // SUB[REGISTER][REGISTER] Subdract reg b from reg a and store results in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0010;
					Immediate		= 10'b0000000000;
					end
		6'b010010: begin // MULT[REGISTER][REGISTER] Multiply reg a and reg b and store result in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0111;
					Immediate		= 10'b0000000000;
					end
		6'b010011: begin // DIV[REGISTER][REGISTER] Divide reg a by reg b and store results in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1000;
					Immediate		= 10'b0000000000;
					end
		6'b010100: begin // MOD[REGISTER][REGISTER] Modulus reg a with reg b and store results in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1001;
					Immediate		= 10'b0000000000;
					end
		6'b010101: begin // ADDI[REGISTER][IMMEDIATE] Add reg a to immediate and store results in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0001;
					Immediate		= {5'b00000, AddressB};
					end
		6'b010110: begin // SUBI[REGISTER][IMMEDIATE] Subdract immediate from reg a and store results in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0010;
					Immediate		= {5'b00000, AddressB};
					end
		6'b010111: begin // MULTI[REGISTER][IMMEDIATE] Multiply reg a and immediate and store result in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0111;
					Immediate		= {5'b00000, AddressB};
					end
		6'b011000: begin // DIVI[REGISTER][IMMEDIATE] Divide reg a by immediate and store results in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1000;
					Immediate		= {5'b00000, AddressB};
					end
		6'b011001: begin // MODI[REGISTER][IMMEDIATE] Modulus reg a with immediate and store results in reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1001;
					Immediate		= {5'b00000, AddressB};
					end
		6'b011010: begin // NOT[REGISTER][REGISTER] Save the bitwise negation of reg a into reg b
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= AddressB;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0110;
					Immediate		= 10'b0000000000;
					end
		6'b011011: begin // XOR[REGISTER][REGISTER] Save the bitwise XOR of reg a and reg b into reg 1
					RamWriteEN 		= 1'b1;
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0101;
					Immediate		= 10'b0000000000;
					end
		6'b011100: begin // OR[REGISTER][REGISTER] Save the bitwise OR of reg a and reg b into reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0100;
					Immediate		= 10'b0000000000;
					end
		6'b011101: begin // AND[REGISTER][REGISTER] Save the bitwise AND of reg a and reg b into reg 1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= AddressB;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0011;
					Immediate		= 10'b0000000000;
					end
		6'b011110: begin // LWR[REGISTER][REGISTER] Load the word in memory from address contained in src reg a into dest reg b (dereference reg pointer)
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b01; // Mux RAM out
					MuxC				= 2'b10; // Mux address from src reg a into RAM address
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= AddressB;
					RegAddrA 		= AddressA; // Read the address from src reg a
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1101; // Mux Bin
					Immediate		= 10'b0000000000;
					end
		6'b011111: begin // SWR[REGISTER][REGISTER] Save the value in reg a into the memory at address contained in src reg b (set variable reg = value)
					RamWriteEN 		= 1'b1; // Write to ram
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00; // Mux in the address value
					MuxB 				= 2'b00;
					MuxC				= 2'b10; // Mux src reg a address into RAM address
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00000;
					RegAddrA 		= AddressB; // Address in RAM
					RegAddrB 		= AddressA; // Value to be saved
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0000;
					Immediate		= 10'b0000000000;
					end
		6'b100000: begin // SI[REGISTER] Save the value from the input bus mux a sel 2 into a reg given address, note last 5 bits are ignored
					RamWriteEN 		= 1'b0; // Write to ram
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b10; // Mux in the address value
					MuxB 				= 2'b00;
					MuxC				= 2'b10; // Mux src reg a address into RAM address
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= AddressA;
					RegAddrA 		= 5'b00000; // Address in RAM
					RegAddrB 		= 5'b00000; // Value to be saved
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1100;
					Immediate		= 10'b0000000000;
					end
		6'b100001: begin // SLI[REGISTER][IMMEDIATE] Shift bits in reg a left by immediate bits and store result in $1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1010; // Shift mode
					Immediate		= AddressB;
				end
		6'b100010: begin // SRI[REGISTER][IMMEDIATE] Shift bits in reg a right by immediate bits and store result in $1
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b1;
					MuxA 				= 1'b00;
					MuxB 				= 2'b10;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00001;
					RegAddrA 		= AddressA;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b1011; // Shift mode
					Immediate		= AddressB;
				end
		default: begin // NOP Do nothing if the opcode is not recognized
					RamWriteEN 		= 1'b0;
					RegWriteEN 		= 1'b0;
					MuxA 				= 1'b00;
					MuxB 				= 2'b00;
					MuxC				= 2'b00;
					RamAddr 			= 10'b0000000000;
					RegWriteAddr 	= 5'b00000;
					RegAddrA 		= 5'b00000;
					RegAddrB 		= 5'b00000;
					JFlag				= 1'b0;
					ALUCtrl			= 4'b0000;
					Immediate		= 10'b0000000000;
					end
		endcase
	end
endmodule
