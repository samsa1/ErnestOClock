open Netlist_ast

type fil = int

let max_size = ref 10;;


let decl = 
"#include <stdio.h>
#include <stdlib.h>
"

let debut = ref
"int main() {
	int numberSteps;
	printf(\"Number steps ? \");
	char numberStepsC[64];
	fgets(numberStepsC,64, stdin);
	numberSteps = atoi(numberStepsC);\n"

let debutBoucle verbose = 
"\tfor (int i = 0; i != numberSteps; i++) {
\t\tchar liste[256];
\t\t long long addr;\n"^(if not verbose then "" else 
"\t\tprintf(\"Etape : %d/%d\\n\", i+1, numberSteps);\n")

let (finBoucle:string) = ""

let fin = "\treturn(1);\n}\n"



let declareFil debut_var fmt n =
	Format.fprintf fmt "\nchar fil[%d];\n" n;
	debut_var := !debut_var ^ "\tfor (int i = 0; i < "^(string_of_int n)^"; i++) {fil[i] = 0;};\n"

let filn fmt n = if n >= 0 then Format.fprintf fmt "fil[%d]" n
	else Format.fprintf fmt "%s" (if n = -1 then "1" else "0");;

let traductionBin fmt b filS fil1 fil2 = Format.fprintf fmt "\t\t%a = " filn filS;
	match b with
		| And 	-> Format.fprintf fmt "%a & %a;\n" filn fil1 filn fil2
		| Or 	-> Format.fprintf fmt "%a | %a;\n" filn fil1 filn fil2
		| Xor	-> Format.fprintf fmt "%a ^ %a;\n" filn fil1 filn fil2
		| Nand	-> Format.fprintf fmt "!(%a & %a);\n" filn fil1 filn fil2

let traductionNot fmt filS filE = Format.fprintf fmt "\t\t%a = !(%a);\n" filn filS filn filE;;

let traductionLectureRam fmt n lfilS lfilA = 
	let lengthA = Array.length lfilA in 
	let lengthS = Array.length lfilS in 
	Format.fprintf fmt "\t\taddr = %d" (1 lsl !max_size); 
	for i = 0 to lengthA - 1 do 
		Format.fprintf fmt "+ (%a<<%d)" filn lfilA.(i) (lengthA - 1 - i)
	done;
	Format.fprintf fmt ";\n\t\tif (addr < %d) {\n" (2 lsl !max_size);
	for i = 0 to lengthS - 1 do 
		Format.fprintf fmt "\t\t%a = %s[addr * %d+%i];\n" filn lfilS.(i) n lengthS i
	done;
	Format.fprintf fmt "\t\t} else {\n";
	for i = 0 to lengthS - 1 do 
		Format.fprintf fmt "\t\t%a = 0 == 1;\n" filn lfilS.(i)
	done;
	Format.fprintf fmt "\t\t};\n";;

let traductionLectureRom fmt n lfilS lfilA = 
	let lengthA = Array.length lfilA in 
	let lengthS = Array.length lfilS in 
	Format.fprintf fmt "\t\taddr = 0"; 
	for i = 0 to lengthA - 1 do 
		Format.fprintf fmt "+ (%a<<%d)" filn lfilA.(i) (lengthA - 1 - i)
	done;
	Format.fprintf fmt ";\n";
	Format.fprintf fmt "\t\tif (addr >= size_of_%s) {exit(0);};\n" n;
	for i = 0 to lengthS - 1 do 
		Format.fprintf fmt "\t\t%a = %s[addr * %d+%i];\n" filn lfilS.(i) n lengthS i
	done;;

let traductionEcritureRam fmt n filE lfilAddr lfilData = 
	Format.fprintf fmt "\t\tif (%a) {\n\t\t\tlong long unsigned addresse = %d" filn filE (1 lsl !max_size);
	let lengthA = Array.length lfilAddr in 
	let lengthD = Array.length lfilData in 
	for i = 0 to lengthA - 1 do 
		Format.fprintf fmt "+ (%a<<%d)" filn lfilAddr.(i) (lengthA - 1 - i)
	done;
	Format.fprintf fmt ";\n\t\tif (addresse < %d) {\n" (2 lsl !max_size);
	for i = 0 to lengthD - 1 do 
		Format.fprintf fmt "\t\t\t%s[addresse * %d+ %d ] = %a;\n" n lengthD i filn lfilData.(i)
	done;
	Format.fprintf fmt "\t\t\t} else {printf(\"Congrats, you just segfaulted\\n\");exit(1);};\n\t\t};\n"


let traductionReg fmt filR filE = Format.fprintf fmt "\t\t%a = %a;\n" filn filR filn filE;;

let traductionMultiplex fmt filS filM filA filB = 
	Format.fprintf fmt "\t\t%a = %a ? %a : %a;\n" filn filS filn filM filn filB filn filA;;

let longueur = function 
	|TBit -> 1
	|TBitArray n -> n


let compilateur fmt p decl_var debut_var debutBoucle_var finBoucle_var fin_var verbose = 
	let nEq = List.length p.p_eqs in 
	let listeFils = Hashtbl.create nEq in 
	let lastFil = ref 0 in 
	let rec rajouteReg = function 
		|[] -> ()
		|(n, Ereg _)::tl -> begin
			Hashtbl.replace listeFils n [|!lastFil|];
			lastFil := 1 + !lastFil;
			rajouteReg tl		
			end
		|_::tl -> rajouteReg tl
	in rajouteReg p.p_eqs;
	let rec rajouteInputs = function 
		|[] -> ()
		|hd::tl -> begin
			let length = longueur (try Env.find hd p.p_vars with Not_found -> failwith ("not found "^hd)) in 
			let t = Array.init length (fun i -> i + !lastFil) in
			Hashtbl.replace listeFils hd t;
			lastFil := length + !lastFil;
			rajouteInputs tl
			end
	in rajouteInputs p.p_inputs;
	let pos a = match a with 
		|Aconst (VBit b) -> [|if b then -1 else -2|]
		|Aconst (VBitArray t) -> Array.init (Array.length t) (fun i -> if t.(i) then -1 else -2)
		|Avar n -> (try Hashtbl.find listeFils n  with Not_found -> failwith ("not found "^n))
	in let rec calcFils liste = match liste with  
		|[] -> ()
		|(n,eq)::tl -> begin
			let () = match eq with
				|Ebinop _ -> begin
					Hashtbl.replace listeFils n [|!lastFil|];
					lastFil := 1 + !lastFil;
					end
				|Enot _ -> begin
					Hashtbl.replace listeFils n [|!lastFil|];
					lastFil := 1 + !lastFil;
					end
				|Eram (_,length,_,_,_,_) -> begin
					let t = Array.init length (fun i -> i + !lastFil) in
					Hashtbl.replace listeFils n t;
					lastFil := length + !lastFil;
					end
				|Erom (_,length,_) -> begin
					let t = Array.init length (fun i -> i + !lastFil) in
					Hashtbl.replace listeFils n t;
					lastFil := length + !lastFil;
					end
				|Emux _ -> begin
					Hashtbl.replace listeFils n [|!lastFil|];
					lastFil := 1 + !lastFil;
					end
				|Ereg _ -> ()
				|Earg a -> begin
					Hashtbl.replace listeFils n (pos a);
					end
				|Econcat (a,b) -> Hashtbl.replace listeFils n (Array.concat [(pos a);(pos b)])
				|Eslice (i,j,a) -> begin 
					let t1 = pos a in 
					let t2 = Array.init (j-i+1) (fun k -> t1.(k+i)) in 
					Hashtbl.replace listeFils n t2
					end 
				|Eselect (j,a) -> let t = pos a in 
					Hashtbl.replace listeFils n [|t.(j)|] in 
			calcFils tl 
		end
	in calcFils p.p_eqs;
	let rec declareRam fmt = function
		|[] -> ()
		|(n,Eram (i,j,_,_,_,_))::tl -> begin
			Format.fprintf fmt "\nchar %s[%d];\n%a" n (j lsl (1+min i !max_size)) declareRam tl
			end
		|(n,Erom (_,j,_))::tl -> begin
			let f = open_in ("./ROM"^n^".rom") in
			let ind = ref 0 in
			let l = ref "{" in
			let () = try 
				while true do
					let nl = input_line f in
					if String.length nl <> j then failwith "bad word size in rom";
					for i = 0 to j-1 do
                        incr ind;
                        l := !l ^ (String.sub nl i 1) ^ ", "
					done;
					l := !l ^ "\n";
				done
			with End_of_file -> close_in f in
			
			Format.fprintf fmt "char %s[%d] = %s};\nint size_of_%s = %d;\n%a" n !ind !l n (!ind/j) declareRam tl
			end
		|_::tl -> declareRam fmt tl
	in let traductionEq fmt (n,eq) = match eq with 
		|Ebinop (binop,a,b) -> traductionBin fmt binop (try Hashtbl.find listeFils n with Not_found -> failwith "l.151").(0) (pos a).(0) (pos b).(0)
		|Enot a -> traductionNot fmt (try Hashtbl.find listeFils n with Not_found -> failwith "l.152").(0) (pos a).(0)
		|Eram (_,_,a,_,_,_) -> traductionLectureRam fmt n (try Hashtbl.find listeFils n with Not_found -> failwith "l.153") (pos a)
		|Erom (_,_,a) -> traductionLectureRom fmt n (try Hashtbl.find listeFils n with Not_found -> failwith "l.154") (pos a)
		|Emux (a,b,c) -> traductionMultiplex fmt (try Hashtbl.find listeFils n with Not_found -> failwith "l.155").(0) (pos a).(0) (pos b).(0) (pos c).(0)
		|Ereg _ -> ()
		|Earg _ -> ()
		|Econcat _ -> ()
		|Eslice _ -> ()
		|Eselect _ -> ()
	in 
	let rec traduction1 fmt = function 
		|[] 	-> ()
		|hd::tl -> Format.fprintf fmt "%a%a" traductionEq hd traduction1 tl
	in let rec traduction2 fmt = function
		|[]  -> ()
		|(nR,Ereg n)::tl -> begin 
			traductionReg fmt (try Hashtbl.find listeFils nR with Not_found -> failwith "l.168a").(0) (try Hashtbl.find listeFils n with Not_found -> failwith ("l.168b "^n^"->"^nR)).(0); 
			Format.fprintf fmt "%a" traduction2 tl
			end
		|(nRam,Eram (_,_,_,b,c,d))::tl -> begin
			traductionEcritureRam fmt nRam (pos b).(0) (pos c) (pos d); 
			Format.fprintf fmt "%a" traduction2 tl
			end
		|_::tl -> traduction2 fmt tl
	in let rec affichageIn fmt = function 
		|[] -> ()
		|n::tl -> begin
			let fil = (try Hashtbl.find listeFils n with Not_found -> failwith "l.179") in 
			let length = Array.length fil in 
			Format.fprintf fmt "\t\tprintf(\"";
			for i = 0 to length - 1 do 
				Format.fprintf fmt "\t\t%a = '1' == liste[%d];\n" filn fil.(i) i
			done;
			Format.fprintf fmt " = \");\n\t\tfgets(liste, 256, stdin);\n%a" affichageIn tl
		end
	in let rec affichageOut fmt = function 
		|[] -> ()
		|n::tl -> begin
			let fil = (try Hashtbl.find listeFils n with Not_found -> failwith "l.190") in 
			let length = Array.length fil in 
			Format.fprintf fmt "\t\tprintf(\"";
			for _ = 0 to length - 1 do 
				Format.fprintf fmt "%s" "%d"
			done;
			Format.fprintf fmt "\\n\"";
			for i = 0 to length - 1 do
				Format.fprintf fmt ", %a" filn fil.(i)
			done;
			Format.fprintf fmt ");\n%a" affichageOut tl
		end
	in 
	Format.fprintf fmt "%s" decl_var;
	Format.fprintf fmt "%a" (declareFil debut_var) !lastFil;
	Format.fprintf fmt "%a" declareRam p.p_eqs;
	Format.fprintf fmt "%s" !debut_var;
	Format.fprintf fmt "%s" debutBoucle_var;
	Format.fprintf fmt "%a" affichageIn p.p_inputs;
	Format.fprintf fmt "%a" traduction1 p.p_eqs;
	Format.fprintf fmt "%a" traduction2 p.p_eqs;
	if verbose then Format.fprintf fmt "%a" affichageOut p.p_outputs;
	Format.fprintf fmt "%s\n" finBoucle_var;
	Format.fprintf fmt "\t}\n%s" fin_var


let compile decl_var debut_var debutBoucle_var finBoucle_var fin_var filename verbose = 
	let p = Netlist.read_file filename in 
	let p = Scheduler.schedule p in 
	let out_name = (Filename.chop_suffix filename ".net") ^ ".c" in
	let out = open_out out_name in 
	let close_all () = close_out out in 
	try 
		compilateur (Format.formatter_of_out_channel out) p decl_var debut_var debutBoucle_var finBoucle_var fin_var verbose; 
		close_all ()
	with a -> begin
		close_all ();
		raise a
	end


(* let main () =
  Arg.parse 
  	["-no-print", Arg.Set disablePrint, "Remove prints"]
    (compile debut debutBoucle finBoucle fin)
    ""
;;

main ()
*)
