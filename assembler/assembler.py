import time, sys
def update_progress(progress):
    barLength = 25
    status = ""
    if isinstance(progress, int):
        progress = float(progress)
    if not isinstance(progress, float):
        progress = 0
        status = "error: progress var must be float\r\n"
    if progress < 0:
        progress = 0
        status = "Halt...\r\n"
    if progress < 1:
        status = "Processing..."
    if progress >= 1:
        progress = 1
        status = "Complete...\r\n"
    block = int(round(barLength*progress))
    text = "\r[{0}] {1}% {2}".format( "#"*block + "-"*(barLength-block), int(progress*100), status)
    sys.stdout.write(text)
    sys.stdout.flush()

def progbar(curr, max):
    progress = curr/(max - 1)
    progress = progress * 100
    progress = progress // 1
    progress = progress / 100
    return progress

# opcode values
mapcode = {
    'NOP':'000000',
    'LW':'000001',
    'SW':'000010',
    'MV':'000011',
    'BGZ':'000100',
    'BEZ':'000101',
    'JMP':'000110',
    'JAL':'000111',
    'JR':'001000',
    'SLT':'001001',
    'SLTI':'001010',
    'SEQ':'001011',
    'SEQI':'001100',
    'LIM':'001101',
    'SL':'001110',
    'SR':'001111',
    'ADD':'010000',
    'SUB':'010001',
    'MULT':'010010',
    'DIV':'010011',
    'MOD':'010100',
    'ADDI':'010101',
    'SUBI':'010110',
    'MULTI':'010111',
    'DIVI':'011000',
    'MODI':'011001',
    'NOT':'011010',
    'XOR':'011011',
    'OR':'011100',
    'AND':'011101',
    'LWR':'011110',
    'SWR':'011111',
    'SI':'100000',
    'SLI':'100001',
    'SRI':'100010'
}

srcname = input("input the file name: ")
src = open(srcname, "r")
inputlines = src.readlines()
inputlines = [inputlines[0]] + ["nop"] + inputlines[1:]

error = False
mode = ""
if("mips_x32+" in inputlines[0]):
    mode = "mips_x32+"
elif("mips_x16" in inputlines[0]):
    mode = "mips_x16"
elif("mips_x32" in inputlines[0]):
    mode = "mips_x32"
else:
    print("Missing assembly type declaration header.")
    error = True
    
inputlines = inputlines[1:]
line = []
lines = []

print("\nAsserting instructions...")
for i in range(len(inputlines)):
    inputlines[i] = inputlines[i].strip()
    inputlines[i] = inputlines[i].upper()
    line = inputlines[i].split(" ")
    if(not (":" in line[0] or line[0].startswith("//") or line[0] == "")):
        try:
            mapcode[line[0]]
        except:
            error = True
            print("Unknown instruction '" + line[0] + "' on line " + str(i))
if(not error):
    print("complete.\n")

for i in range(len(inputlines)):
    inputlines[i] = inputlines[i].strip()
    inputlines[i] = inputlines[i].upper()
    if(inputlines[i] != ""):
        lines.append(inputlines[i])

i = 0
while(i < len(lines)):
    line = lines[i].split(" ")
    if("//" in lines[i]):
        if("//" in line[0]):
            lines.remove(lines[i])
            i -= 1
        else:
            lines[i] = lines[i][0:lines[i].index("//")]
            lines[i] = lines[i].strip()
    i += 1

if("mips_x32" in mode and not error):
    regreg = {"ADD", "SUB", "MULT", "DIV", "MOD", "SL", "SR", "SEQ", "SLT",
                  "XOR", "OR", "AND"}
    regimm = {"SLTI", "SEQI", "ADDI", "SUBI", "MULTI", "DIVI", "MODI", "SLI", "SRI"}
    lsword = {"LW", "SW", "BGZ", "BEZ", "LIM"}
    other = {"BGZ", "BEZ"}
    ops = set()
    ops = ops.union(regreg, regimm)
    inputlines = []
    
    if(mode != "mips_x32+"):
        # check for using any reserved registers
        for i in range(len(lines)):
            line = lines[i].split(" ")
            for i in range(len(line)):
                if(line[i] == "$1" or line[i] == "$30" or line[i] == "$31"):
                    error = True
                    print("Cannot use registers reserved for assembler (use name instead"
                          + " or change header to mips_x32+)") 
                if(line[i] == "ZERO"):
                    line[i] = "$0"
            if(line[0] in regreg and len(line) == 4):
                if(not ("$" in line[1] and "$" in line[2] and "$" in line[3])):
                    error = True
                    print("Register declaration missing")
            elif(line[0] in regimm and len(line) == 4):
                if(not ("$" in line[1] and "$" in line[2] and "$" not in line[3])):
                    error = True
                    print("Register declaration missing")
            elif(line[0] in lsword and len(line) == 3):
                if(not ("$" in line[1] and "$" not in line[2])):
                    error = True
                    print("Register declaration missing")
            if((line[0] in ops and len(line) < 4) or
                 (line[0] in lsword and len(line) < 3) or line[0] == "MV"):
                error = True
                print("Header declares mips_x32 but instructions contain mips_x16\n")
    print("Converting x32 to x16...\n")
    log = open("conversion_log.txt", "w")
    i = 0
    while(i < len(lines)):
        converted = []
        line = lines[i].split(" ")
        if(line[0] in regreg and len(line) == 4):
            converted = [lines[i]]
            lines[i] = " ".join([line[0], line[2], line[3]])
            lines = lines[:i+1] + ["MV $1 " + line[1]] + lines[i+1:]
            converted += [lines[i], lines[i+1]]
        elif(line[0] in regimm):
            converted = [lines[i]]
            if(int(line[3]) > 31 and len(line) == 4):
                lines[i] = " ".join([line[0][:-1], line[2], "$1"])
                lines = lines[:i] + ["LIM " + line[3]] + lines[i:]
                converted += [lines[i], lines[i+1]]
                i += 1
            else:
                lines[i] = " ".join([line[0], line[2], line[3]])
                converted += [lines[i]]
            lines = lines[:i+1] + ["MV $1 " + line[1]] + lines[i+1:]
            converted += [lines[i+1]]
        elif(line[0] in lsword and len(line) == 3):
            converted += [lines[i]]
            lines[i] = " ".join([line[0], line[2]])
            if(line[0] == "LW" or line[0] == "LIM"):
                lines = lines[:i+1] + ["MV $1 " + line[1]] + lines[i+1:]
                converted += [lines[i], lines[i+1]]
            elif(line[0] in other):
                lines = lines[:i] + ["MV $1 " + line[1]] + lines[i:]
                converted += [lines[i], lines[i+1]]                
            else:
                lines = lines[:i] + ["MV " + line[1] + " $1"] + lines[i:]
                converted += [lines[i], lines[i+1]]
        elif(line[0] == "JAL"):
            converted += [lines[i]]
            lines[i] = "JAL $31"
            lines = lines[:i+1] + ["JMP " + line[1]] + lines[i+1:]
            converted += [lines[i], lines[i+1]]
            i += 1
        if(len(converted) != 0):
            print(converted[0] + " -> ")
            log.write(converted[0] + " ->\n")
            for x in range(1, len(converted)):
                print("\t\t" + converted[x])
                log.write("\t\t" + converted[x] + "\n")
            print(" ")
        i += 1
    print("Conversion complete.")
    log.close()

destname = "PROGMEM.mif"
dest = open(destname, "w")
machinecode = ["WIDTH=16;\n",
               "DEPTH=1024;\n",
               "\n",
               "ADDRESS_RADIX=DEC;\n",
               "DATA_RADIX=BIN;\n",
               "\n",
               "CONTENT BEGIN\n"]

lastline = 0
instruction = []
if(not error):
    print("\nMapping branch addresses...")
    branch = ["BGZ", "BEZ", "JMP"]
    branches = dict()
    i = 0
    while(i < len(lines)):
        line = lines[i].split(" ")
        jumpaddr = line[0]
        if(":" in line[0]):
            temp = line[0]
            line[0] = line[0].strip(":")
            branches[line[0]] = "{:010d}".format(int(i));
            print("{"+line[0]+":0x"+"{0:03X}".format(int(branches[line[0]]))+"}")
            lines.remove(jumpaddr)
            i -= 1
        i += 1
    print("\nAssembling x16...")
    i = 0
    prev = 0
    while(i < len(lines) and not error):
        curr = progbar(i, len(lines))
        if(curr != prev):
            update_progress(curr)
        prev = curr
      
        line = lines[i].split(" ")
        if(line[0] in branch and ":" not in line[0]):
            line[1] = branches[line[1]]
            
        if(":" not in line[0]):
            line[0] = mapcode[line[0]]
            if(line[0] == "000000"):
                line[0] = "{:016d}".format(int(line[0]))
        
        for x in range(1, len(line)):
            line[x] = line[x].strip("$")
            line[x] = line[x].strip(",")
            if(line[x] == "SP"):
                line[x] = "30"
            elif(line[x] == "RA"):
                line[x] = "31"
            elif(line[x] == "ZERO"):
                line[x] = "0"
            line[x] = "{0:b}".format(int(line[x]))
            if(len(line) == 2):
                line[x] = "{:010d}".format(int(line[x]))
            else:
                line[x] = "{:05d}".format(int(line[x]))
        instruction = "".join(line)
        if(len(instruction) > 16):
            print("Immediate or address value out of bounds "
                            + "on line " + str(i) + " (not counting blank lines)\n")
            error = True
        padding = (4 - len(str(i)))*" "   
        line[:] = ["\t", padding, str(i), " : ", instruction + ";"]
        lines[i] = "".join(line)
        machinecode.append(str(lines[i]) + "\n")
        lastline = i
        i += 1
else:
    print("Fatal error during assembly.")

if(lastline < 1022):
    machinecode.append("\t[" + str(lastline + 1) + "..1023] : 0000000000000000;\n")
elif(lastline == 1022):
    machinecode.append("\t1023 : 0000000000000000;\n")
machinecode.append("END\n")

plength = len(machinecode) - 9
if(plength > 1023):
    print("\nProgram is too large to load into memory: "
                    + str(plength) + "/1023 lines.\n")
elif(error == False):
    for i in range(len(machinecode)):
        dest.write(machinecode[i])
    print("\n\nAssembly successful.\n")
src.close()
dest.close()

input("Press enter to exit.\n")
