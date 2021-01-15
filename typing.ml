open Ast

exception Type_error of string * int

let labels = Hashtbl.create 64
let line = ref 1 

let read = function 
  | Mark l -> if Hashtbl.mem labels l then raise(Type_error ("name "^l^" is already used", !line))
              else Hashtbl.add labels l ()
  | _ -> ()

let check_instr = function
  | Unop (_, p) -> begin match p with
                          | Reg _ | Addr _-> incr line
                          | _ -> raise(Type_error ("register expected ", !line))
                    end
  | Binop (u, p1, p2) -> begin match u with 
                |Lsr | Lsl | Asr -> begin match p2 with
                      |Cst i -> if i< 0 || i > 31 then raise(Type_error ("shift need a small constant ", !line)) else ()
                      |_ -> raise(Type_error ("shift need a constant ", !line))
                    end
                |_ -> ();
                match p1 with
                              | Reg _ -> incr line
                              | Addr _ -> begin match p2 with 
                                                | Addr _ -> raise(Type_error ("only one memory acces per instruction is allowed ", !line))
                                                | _ -> incr line
                                            end
                              | _ -> raise(Type_error ("register expected ", !line))
                          end
  | Jump (_, l) -> if Hashtbl.mem labels l then incr line
                    else raise(Type_error ("undefined label ", !line))
  | Mov (_, p1, p2) -> begin match p1 with 
                              | Reg _ -> incr line
                              | Addr _ -> begin match p2 with 
                                                | Addr _ -> raise(Type_error ("only one memory acces per instruction is allowed ", !line))
                                                | _ -> incr line
                                            end
                              | _ -> raise(Type_error("can't move something to a not register object ", !line))
                        end
  | Mark _ -> incr line

let type_prog f = 
  List.iter read f;
  List.iter check_instr f
