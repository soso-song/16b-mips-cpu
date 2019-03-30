The assembler provides an easy conversion between the assembly for the cpu and
machine code that is loaded into the cpu program memory. An exe has been included
for use on windows machines without python. Other users should use the command:
'python assembler.py' in terminal

If the assembler closes immediately, there was an exception. Either you entered
the filename wrong or something really bad happened. gg.
If your mif file is empty, read the assembler error msg.

The output for the assembler is always titled "PROGMEM.mif", it can be loaded
into the cpu by copying the mif file directly into the folder where the
cpu verilog files are located. To load the memory into the de2 board in quartus,
click: processing->update memory initialization file. Then in the left side
of the quartus window, right click on the assembler and click run again. Then
open the de2 programmer and upload to the de2 board.

There are 3 headers that can be specified in the assembler for different types
of assembly and conversions.

mips_x16:
This is the lowest level assembly available. Commands are documented in the
control_unit.v. All commands will have either 1 or 2 arguments. Be careful when
using register $1 as every operation saves a value to it. $1 is disabled and
reserved for the assembler in other modes.

An example program in mips_x16 is fib.txt

mips_x32:
This allows you to use standard mips instructions. The assembler then converts them
into mips_x16 as a combination of mv, lim and other commands and then assembles
into machine code. registers $1, $30, $31 are disabled and reserved for the assember.
Instead, use the register names $ra, $sp. mips_x16 commands are disabled as they
can easily cause undesired results when accidentally moving to reserved registers.

Incase the conversion log is too large and the terminal cannot display all of it, a
copy of all the commands converted is saved into command_log.txt

An example program is count.txt

mips_x32+:
This is a free for all mode, commands can be either format however when writing
this assembly it is advised to pay special attention to every line you write as
creating bugs is extremely easy. The assembler will not check anything except for
the bare minimum (if instructions are valid).


