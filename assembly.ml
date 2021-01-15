open Format
open Lexing
(*open Printer*)
(*open Typing*)
(*open Compile*)

let out_file = ref ""

let usage = "usage : assembly file.s"

let file =
  let file = ref None in
  let set_file s =
    if not (Filename.check_suffix s ".s") 
      then raise (Arg.Bad "expected .s extension");
    file := Some s
  in
  Arg.parse [("-o", Arg.Set_string out_file, "specify output file")] set_file usage;
  match !file with
    |Some f -> f
    |None -> exit 1

let ofile = if !out_file = "" then Filename.chop_suffix file ".s" ^ ".rom" else !out_file

let report (b, e) =
  let l = b.pos_lnum in
  let cb = b.pos_cnum - b.pos_bol + 1 in
  let ce = e.pos_cnum - b.pos_bol + 1 in
  eprintf "File \"%s\", line %d, characters %d-%d:\n" file l cb ce

let () =
  let c = open_in file in
  let lb = Lexing.from_channel c in
  try
    let f = Parser.prog Lexer.next_token lb in
    close_in c;
    Typing.type_prog f;
    Compile.compile_prog ofile f
  with
    | Lexer.Lexing_error s ->
        report (Lexing.lexeme_start_p lb, Lexing.lexeme_end_p lb);
        eprintf "lexical error : %s@." s;
        exit 1 
    | Parser.Error ->
        report (Lexing.lexeme_start_p lb, Lexing.lexeme_end_p lb);
        eprintf "syntax error@.";
        exit 1
    | Typing.Type_error (s, l) ->
        eprintf "File \"%s\", line %d:\n typing error : %s@." file l s
    | Compile.Exec_error s ->
        eprintf "File \"%s\"\n execution error : %s@." file s
    | e -> 
        eprintf "Anomaly : %s\n@." (Printexc.to_string e);
        exit 2
