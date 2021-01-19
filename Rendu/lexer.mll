{
    open Lexing
    open Ast
    open Parser

    exception Lexing_error of string

    let last = ref false

    let reg_nb r =
      match r with 
      | "cpp" -> 31
      | "rsp" -> 29
      | "rbp" -> 30
      | s -> try let n = int_of_string (String.sub s 1 2) in 
                  if n < 32 then n else raise(Lexing_error ("Invalid register name "^r))
              with _ -> raise(Lexing_error ("Invalid register name "^r))

    let kwd_tbl = [("add", [ADD]); ("sub", [SUB]); ("neg", [NEG]); ("and", [AND]); ("not", [NOT]); ("xor", [XOR]); ("or", [OR]); ("nand", [NAND]); ("lsl", [LSL]); ("lsr", [LSR]); ("asr", [ASR]); ("cmp", [CMP]); ("test", [TEST]); ("incr", [INCR]); ("decr", [DECR]);
                    ("mov", [MOV]); ("move", [MOV; FLAG Fe]); ("movne", [MOV; FLAG Fne]); ("movs", [MOV; FLAG Fs]); ("movns", [MOV; FLAG Fs]); ("movg", [MOV; FLAG Fg]); ("movge", [MOV; FLAG Fge]); ("movl", [MOV; FLAG Fl]); ("movle", [MOV; FLAG Fle]); ("mova", [MOV; FLAG Fa]); ("movae", [MOV; FLAG Fae]); ("movb", [MOV; FLAG Fb]); ("movbe", [MOV; FLAG Fbe]);
                     ("jmp", [JMP]); ("je", [JMP; FLAG Fe]); ("jne", [JMP; FLAG Fne]); ("js", [JMP; FLAG Fs]); ("jns", [JMP; FLAG Fs]); ("jg", [JMP; FLAG Fg]); ("jge", [JMP; FLAG Fge]); ("jl", [JMP; FLAG Fl]); ("jle", [JMP; FLAG Fle]); ("ja", [JMP; FLAG Fa]); ("jae", [JMP; FLAG Fae]); ("jb", [JMP; FLAG Fb]); ("jbe", [JMP; FLAG Fbe])]

}

let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let integer = digit+ | '-' digit+
let ident = (letter | '_') (letter | '_' | digit)*
let space = [' ' '\t']
let register = ('r' digit digit) | "cpp" | "rsp" | "rbp"
let comment = "#" [^'\n']* '\n'

rule token = parse 
  | '\n' { new_line lexbuf ; if !last then token lexbuf else begin last := true; [END] end }
  | space+ { token lexbuf }
  | comment {new_line lexbuf ; token lexbuf}
  | '%' (register as r) { last := false ; [REG (reg_nb r)] }
  | "(%" (register as r) ')' { last := false ; [ADDR (reg_nb r)] }
  | '$' (integer as n) { last := false ; try [CST (int_of_string n)] with _ -> raise(Lexing_error ("constant to large "^n)) }
  | '"' (ident as s) '"' { last := false ; [LABEL s] }
  | (ident as s)':' { last := false; [LABEL s ; DEF] }
  | ident as k { last := false; try List.assoc k kwd_tbl with _ -> raise(Lexing_error ("Invalid operator name "^k))}
  | eof { if !last then [EOF] else [END; EOF]}
  | _ as c { raise(Lexing_error ("Illegal character " ^ (String.make 1 c)^"'"))}

{
    let next_token =
        let tokens = Queue.create () in
        fun lb -> if Queue.is_empty tokens 
                then begin
                    let l = token lb in
                    List.iter (fun t -> Queue.add t tokens) l
                    end;
        Queue.pop tokens

}