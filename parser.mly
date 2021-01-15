%{
    open Ast
%}

%token <int> CST
%token <int> REG
%token <int> ADDR
%token <Ast.label> LABEL
%token <Ast.flag> FLAG
%token ADD SUB NEG INCR DECR
%token AND OR XOR NAND NOT
%token LSL LSR ASR
%token CMP TEST
%token JMP MOV
%token DEF END
%token EOF

%start prog

%type <Ast.program> prog

%%

prog :
| p = instrs EOF { List.rev p }
;

instrs:
| i = instr { [i] }
| l = instrs i = instr { i :: l }
;

instr:
| l = LABEL DEF END { Mark l }
| u = uop p = param END { Unop (u, p) }
| o = bop p1 = param p2 = param END { Binop (o, p1, p2) }
| JMP f = FLAG? l = LABEL END { Jump (f, l)}
| MOV f = FLAG? p1 = param p2 = param END { Mov (f, p1, p2)}
;

param:
| r = REG { Reg r }
| a = ADDR { Addr a }
| c = CST { Cst c }
;

%inline uop :
| NEG { Neg }
| NOT { Not }
| INCR { Incr }
| DECR { Decr }
;

%inline bop :
| ADD { Add }
| SUB { Sub }
| AND { And }
| OR { Or }
| XOR { Xor }
| NAND { Nand }
| CMP { Cmp }
| TEST { Test }
| LSL { Lsl }
| LSR { Lsr }
| ASR { Asr }
;
