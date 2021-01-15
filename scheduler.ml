open Netlist_ast
open Graph


exception Combinational_cycle;;

let rec printStrList = function
	|[] -> print_newline ()
	|hd::tl -> begin
		print_string hd;
		print_string "; ";
		printStrList tl;
	end;;
let read_exp exp =
	let aux = function
		|Avar a -> [a]
		|Aconst _ -> []
	in match exp with
		|Earg a -> aux a
		|Ereg _ -> []
		|Enot a -> aux a
		|Ebinop (_,a1,a2) -> aux a1 @ aux a2
		|Emux (a,b,c) -> aux a @ aux b @ aux c
		|Erom (_,_,a) -> aux a
		|Eram (_,_,a,_,_,_) -> aux a (*@ aux b @ aux c @ aux d*)
		|Econcat (a,b) -> aux a @ aux b
		|Eslice (_,_,a) -> aux a
		|Eselect (_,a) -> aux a

let schedule p = let rec noms = function
	|[] -> []
	|(a,_)::tl -> a::noms tl in
	let g = {g_nodes = []} in
	let nms = noms p.p_eqs in
	List.iter (add_node g) (nms);
	let linput = ref p.p_inputs in 
(*	List.iter (fun s -> match  s with
	|(n,Erom _) -> linput := n:: !linput
	|(n,Eram _) -> linput := n:: !linput
	| _ -> ()) p.p_eqs;*)
	let rec n_est_pas_dedans v = function
		|[] -> true
		|hd::tl -> (hd<>v)&&n_est_pas_dedans v tl in
	let lie (n,e) = let suite = read_exp e in 
		List.iter (fun nom -> if n_est_pas_dedans nom !linput then add_edge g nom n) suite
	in List.iter lie p.p_eqs;
	try let l = topological g in 
		let rec construitSortie =  function
			|[] -> []
			|hd::tl -> (List.find (fun (n,_) -> n=hd) p.p_eqs)::construitSortie tl 
		in {p_eqs = construitSortie l; p_inputs = p.p_inputs; p_outputs = p.p_outputs; p_vars = p.p_vars}
	with Is_cycle -> raise Combinational_cycle;; 
