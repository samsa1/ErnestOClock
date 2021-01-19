type flag =
  | Fe | Fne
  | Fs | Fns
  | Fg | Fge | Fl | Fle 
  | Fa | Fae 
  | Fb | Fbe

type unop =
  | Neg
  | Not
  | Incr | Decr

type binop =
  | Add | Sub
  | And | Or | Xor | Nand
  | Cmp | Test
  | Lsl | Lsr | Asr

type label =  string

type param =
  | Cst of int
  | Reg of int
  | Addr of int

type instr = 
  | Unop of unop * param
  | Binop of binop * param * param 
  | Jump of (flag option) * label
  | Mov of (flag option) * param * param
  | Mark of label

type program = instr list
