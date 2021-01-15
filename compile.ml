open Ast 
open Format

exception Exec_error of string

let bound = 65536

let ceil = bound*bound

let labels = Hashtbl.create 16 

let jumpUnaire = ref false

let to_bin n =
  if n >= ceil || n < - ceil then raise(Exec_error "constant to large");
  let b = ref "" in
  let k = if n < 0 then ref (n + ceil) else ref n in
  while !k > 0 do 
    b := Int.to_string (!k mod 2) ^ (!b) ;
    k := !k / 2
  done;
  let l = String.length !b in 
  if l > 32 then raise(Exec_error "constant to large")
  else (String.make (32 - l) '0')^(!b)

let reg_addr n =
  let a = ref "" in 
  let k = ref n in
  while !k > 0 do 
    a := Int.to_string (!k mod 2) ^(!a) ;
    k := !k / 2
  done;
  (String.make (5 - (String.length !a)) '0')^(!a)

let cycle = ref 0

let count = function 
  | Unop _ -> incr cycle
  | Jump _ -> cycle := !cycle + (if !jumpUnaire then 1 else 2)
  | Binop (_, _, p) | Mov (_, _, p) -> begin match p with
                                        | Cst n -> if n < 0 || n >= bound then cycle := !cycle + 2 
                                                    else incr cycle
                                        | _ -> incr cycle
                                      end
  | Mark l -> Hashtbl.add labels l !cycle


let operator = function 
  | None -> "0011000"^"1"
  | Some Fe -> "0000000"^"1"
  | Some Fne -> "1000000"^"1"
  | Some Fs -> "0100000"^"1"
  | Some Fns -> "1100000"^"1"
  | Some Fg -> "1010000"^"1"
  | Some Fge -> "0010000"^"1"
  | Some Fl -> "1110000"^"1"
  | Some Fle -> "0110000"^"1"
  | Some Fa -> "1001000"^"1"
  | Some Fae -> "0001000"^"1"
  | Some Fb -> "1101000"^"1"
  | Some Fbe-> "0101000"^"1"


let compile = function
  | Unop (u, p) -> begin let a,b = match p with 
                                  | Reg r -> (reg_addr r), "0"
                                  | Addr r -> reg_addr r, "1"
                                  | _ -> raise(Exec_error "register expected")
                          in 
                          match u with
                          | Neg  -> "0001101"^"1"^a^"00000000000"^"1"^b^a^b^"\n"
                          | Not  -> "0000101"^"1"^a^"00000000000"^"1"^b^a^b^"\n"
                          | Incr -> "1000011"^"1"^a^"00000000000"^"1"^b^a^b^"\n"
                          | Decr -> "1100011"^"1"^a^"00000000000"^"1"^b^a^b^"\n"
                  end
  | Binop (o, p1, p2) -> begin let a = match p1 with 
                                        | Reg r1 -> (reg_addr r1) ^ "0"
                                        | Addr r1 -> reg_addr r1 ^ "1"
                                        | _ -> raise(Exec_error "register expected")
                                in 
                                let op = match o with
                                          | Add  -> "0000011"^"1"
                                          | Sub  -> "0100011"^"1"
                                          | And  -> "0000001"^"1"                                          
                                          | Or   -> "0100001"^"1"
                                          | Xor  -> "1100001"^"1"
                                          | Nand -> "1000001"^"1"
                                          | Cmp  -> "0100011"^"0"
                                          | Test -> "0000001"^"0" 
                                          | Lsl  -> "0000111"^"1"
                                          | Lsr  -> "0100111"^"1"
                                          | Asr  -> "1100111"^"1"
                                in
                                match p2 with
                                | Reg r2 -> op^(reg_addr r2)^"00000000000"^"10"^a^"\n"
                                | Addr r2 -> op^(reg_addr r2)^"00000000000"^"11"^a^"\n"
                                | Cst n -> let b = to_bin n in 
                                            if n >= 0 && n < bound then op^(String.sub b 16 16)^"00"^a^"\n"
                                            else "00000000"^"0"^(String.sub b 0 16)^"00"^"00000"^"0\n"^op^(String.sub b 16 16)^"01"^a^"\n"
                            end
  | Jump (f, l) -> begin try let n = Hashtbl.find labels l in
                              let j = operator f in 
                              let a = "11111" in 
                              let b = to_bin n in 
                              if !jumpUnaire then j^(String.sub b 16 16)^"00"^a^"0\n"
                              else "0000000"^"0"^(String.sub b 0 16)^"00"^"00000"^"0\n"^j^(String.sub b 16 16)^"01"^a^"0\n"
                          with Not_found -> raise(Exec_error ("label "^l^"is not defined"))
                  end
  | Mov (f, p1, p2) -> begin let a = match p1 with 
                                      | Reg r1 -> (reg_addr r1) ^ "0"
                                      | Addr r1 -> reg_addr r1 ^ "1"
                                      | _ -> raise(Exec_error "register expected")
                              in 
                              let m = operator f in 
                              match p2 with
                              | Reg r2 -> m^(reg_addr r2)^"00000000000"^"10"^a^"\n"
                              | Addr r2 -> m^(reg_addr r2)^"00000000000"^"11"^a^"\n"
                              | Cst n -> let b = to_bin n in 
                                          if n >= 0 && n < bound then m^(String.sub b 16 16)^"00"^a^"\n"
                                          else "0000000"^"0"^(String.sub b 0 16)^"00"^"00000"^"0\n"^m^(String.sub b 16 16)^"01"^a^"\n"
                          end
  | Mark _ -> ""
  (*| _ -> raise(Exec_error "illegal instruction")*)

let compile_prog file p =
  let c = open_out file in
  let fmt = formatter_of_out_channel c in
  jumpUnaire := List.length p < 1 lsl 15;
  List.iter count p;
  List.iter (fun i -> fprintf fmt "%s" (compile i)) p;
  fprintf fmt "@?";
  close_out c
