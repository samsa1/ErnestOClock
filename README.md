# General purpose microprocessor

## Objectives

### Clock

INPUTS : init time (seconds since midnight) + time in seconds, mod 2 (aka tick tock).

OUTPUTS : 7 segment display : HH : MM : SS 

Treatment (software) : INIT : convert in H.H:M.M:S.S

For every change in tick/tock : increment time; format output; send output

### Game console prototype

Input via controller/keyboard, output on screen.

## Designing the microprocessor

### Design of the computing part

It has two main building blocks :

1. A *n*-bit ALU.
2. Memory management

We want these blocks to be the more efficient possible, so we want them to use as few gates as possible (because we simulate in a linear manner). In general, we have to think the microprocessor architecture to take advantage of the sequential fashion of the simulator.

### Representation of the data

|   Data type    |                  Binary representation                  |
| :------------: | :-----------------------------------------------------: |
|    Integer     | Little-endian bit word<br />Signed with complement to 2 |
|     Float      |                   Not implemented yet                   |
|    Boolean     |                         Integer                         |
| Char/string... |              At the level of the compiler               |

The instruction set provided to the user will only operate on bit words.

### Design of the ALU

Instead of shaping every problem like a nail so we can smash it with the $n$-adder hammer, we make a toolbox. This way, we avoid using several multiplexers ahead of the adder, and we have a slight gain in performance.

### Design of the assembly language

We want to provide the user with several basic instructions :

- Arithmetic and logic
- Registers
- Move things in memory
- Control flow
- Flags, conditions

### Design of the architecture

$32$-bit registers

Special registers:

- cpp (code position pointer -> memory address of the current instruction in ROM)
- rbp/rsp (base / end of stack pointers)

Names : r00 - r28

Callee/caller conventions : r00-r13 are caller saved; r14-r28 and rbp are callee-save



Pins for in/out (RAM with large word size and tiny addr size)



The general architecture will look like what have been suggested in class (cf figure below). It is inspired by RISC, and flavoured with x86 sprinkles.

![image-20201208142132810](/home/pollux/.config/Typora/typora-user-images/image-20201208142132810.png)

### Instruction design

Operator | 1 * write_enable | 16 * Param2 | 2 * Param2 type (imm, reg, mem) | Reg_address_size * Param1 | 1 * Param1 type (reg, mem)

Raise/lower flags (1 bit physical reg) -> negative, null, overflow and carry (hardware) + other flags (firmware, can be derived from the 3 ones before)

Unary or binary

- ADD x y -> x := x+y
- SUB x y -> x := x-y
- AND x y -> x := x&&y
- NOT x -> x := ¬x
- XOR x y -> x := x^y
- OR x y -> x := x||y
- MOV[FLAG] x y -> x := y
- LSL/ LSR / ASR (logical/arithmetic shift, left/right)
- JMP[FLAG]
- CMP
- TEST
- INCR x -> x := x+1
- DECR x -> x := x-1
- Maybe add some other operators, only they will be converted the aforementioned ones. It will be easier for the programmer to write in higher-level assembly.

## Enhancement ideas

To be determined
