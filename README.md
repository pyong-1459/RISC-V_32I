# RISC-V 32I implementation with Verilog
## Reference
Official ISA is at https://riscv.org/technical/specifications/

Another reference is a lecture note that can be found at internet, attached in this repository
## Converting assembly code to hex code
https://venus.cs61c.org/

Assembly codes are at "assembly test"

Hex codes are at "machine code"

I tested 4 different codes for verification about every operation except for ECALL/EBREAK/FENCE
## Note
I have no synthesis tool license, cannot test the systhesis
## About some modules
Instruction memory has 128x32bit registers

Register file has 32x32bit register, specified in official document

Data memory has 4x2^32x8bit registers

All codes are designed with ternery operators and logical operators without "always @ (*)" to avoid synthesis error
