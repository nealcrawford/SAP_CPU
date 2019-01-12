# A 16 Bit softcore processor designed with Verilog

### LOADING and STORING TO/FROM MEMORY
```
LDR0  0000_0000  Load value from memory to r0
LDR1  0000_0001  Load value from memory to r1
LDR2  0000_0010  Load value from memory to r2
LDR3  0000_0011  Load value from memory to r3
```

```
STR0  0001_0000  Store value from r0 to memory
STR1  0001_0001  Store value from r1 to memory
STR2  0001_0010  Store value from r2 to memory
STR3  0001_0011  Store value from r3 to memory
```

```
MOV0  0010_0000  Move immediate into r0
MOV1  0010_0001  Move immediate into r1
MOV2  0010_0010  Move immediate into r2
MOV3  0010_0011  Move immediate into r3
```

### ALU OPERATIONS
The machine code for ALU operations follow the following pattern:
Operation   operand 1 and operand 2
     xxxx   xx            xx
A two bit destination register must also be ammended to each instruction

Examples:

```
ADD  0100_0000  Add r0 + r0
SUB  0101_1110  Subtract r3 - r2
LSL  0110_1100  Shift r3 << r0
LSR  0111_0101  Shift r1 >> r1
ASR  1000_0000  Shift r0 >>> r0 (Sign preserved)
MUL  1001_1101  Multiply r3 * r1
```

### BRANCH
```
B    1110_0000  Change PC to specified value
```

### OUTPUT
```
OUT0  1111_0000  Output contents of r0
OUT1  1111_0001  Output contents of r1
OUT2  1111_0010  Output contents of r2
OUT3  1111_0011  Output contents of r3
```

### An example multiply by two program:
```
mov r0, #1
mov r1, #2
mul r0, r0, r1
out r0
b #2
```
