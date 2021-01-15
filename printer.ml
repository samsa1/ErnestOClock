open Ast 
open Format

let print_unop fmt = function 
  | Neg -> fprintf fmt "neq "
  | Not -> fprintf fmt "not "
  | Incr -> fprintf fmt "incr "
  | Decr -> fprintf fmt "decr "
  | Lsl -> fprintf fmt "lsl "
  | Lsr -> fprintf fmt "lsr "
  | Asr -> fprintf fmt "asr "

let print_binop fmt = function
  | Add -> fprintf fmt "add "
  | Sub -> fprintf fmt "sub "
  | And -> fprintf fmt "and "
  | Or -> fprintf fmt "or "
  | Xor -> fprintf fmt "xor "
  | Nand -> fprintf fmt "nand "
  | Cmp -> fprintf fmt "cmp "
  | Test -> fprintf fmt "test "

let print_param fmt = function
  | Cst n -> fprintf fmt "%d " n 
  | Reg n -> fprintf fmt "%cr%d " '%' n
  | Addr n -> fprintf fmt "(%cr%d) " '%' n

let print_flag fmt = function
  | Fe -> fprintf fmt "e "
  | Fne -> fprintf fmt "ne "
  | Fs -> fprintf fmt "s "
  | Fns -> fprintf fmt "ns "
  | Fg -> fprintf fmt "g "
  | Fge -> fprintf fmt "ge "
  | Fl -> fprintf fmt "l "
  | Fle -> fprintf fmt "le "
  | Fa -> fprintf fmt "a "
  | Fae -> fprintf fmt "ae "
  | Fb -> fprintf fmt "b "
  | Fbe -> fprintf fmt "be "

let print_instr fmt = function
  | Unop (u, p) -> print_unop fmt u ; print_param fmt p ; fprintf fmt "\n"
  | Binop (o, p1, p2) -> print_binop fmt o ; print_param fmt p1 ; print_param fmt p2 ; fprintf fmt "\n"
  | Jump (None, s) -> fprintf fmt "jmp \"%s\" \n" s
  | Jump (Some f, s) -> fprintf fmt "j"; print_flag fmt f; fprintf fmt "\"%s\" \n" s
  | Mov (None, p1, p2) -> fprintf fmt "mov " ; print_param fmt p1 ; print_param fmt p2 ; fprintf fmt "\n"
  | Mov (Some f, p1, p2) -> fprintf fmt "mov" ; print_flag fmt f; print_param fmt p1 ; print_param fmt p2 ; fprintf fmt "\n"
  | Mark s -> fprintf fmt "%s:\n" s

let print_file fmt = List.iter (print_instr fmt)