exception Cycle
type mark = NotVisited | InProgress | Visited

type 'a graph =
    { mutable g_nodes : 'a node list }
and 'a node = {
  n_label : 'a;
  mutable n_mark : mark;
  mutable n_link_to : 'a node list;
  mutable n_linked_by : 'a node list;
}

let mk_graph () = { g_nodes = [] }

let add_node g x =
  let n = { n_label = x; n_mark = NotVisited; n_link_to = []; n_linked_by = [] } in
  g.g_nodes <- n::g.g_nodes

let node_for_label g x =
  List.find (fun n -> n.n_label = x) g.g_nodes

let add_edge g id1 id2 =
  let n1 = node_for_label g id1 in
  let n2 = node_for_label g id2 in
  n1.n_link_to <- n2::n1.n_link_to;
  n2.n_linked_by <- n1::n2.n_linked_by

let clear_marks g =
  List.iter (fun n -> n.n_mark <- NotVisited) g.g_nodes

let find_roots g =
  List.filter (fun n -> n.n_linked_by = []) g.g_nodes;;

exception Is_cycle;;

let has_cycle g = 
  let rec aux sommet = match sommet.n_mark with
    |Visited -> ()
    |InProgress -> raise Is_cycle
    |NotVisited -> begin
      sommet.n_mark <- InProgress;
      List.iter aux sommet.n_link_to;
      sommet.n_mark <- Visited;
      end
  in let rec reset sommet = match  sommet.n_mark with
  |NotVisited -> ()
  |Visited -> begin
    sommet.n_mark <- NotVisited;
    List.iter reset sommet.n_link_to;
    end
  |InProgress -> failwith "InProgress"
  in try
    List.iter (fun n -> if n.n_linked_by = [] then (aux n;reset n) else ()) g.g_nodes;
    true
  with
    |Is_cycle -> false;
    | _ -> failwith "Unknown";;

let topological g = let l = ref [] in 
  let rec aux sommet = match sommet.n_mark with
    |Visited -> ()
    |InProgress -> begin 
      print_string sommet.n_label;
      print_newline ();
      raise Is_cycle
      end
    |NotVisited -> begin
      sommet.n_mark <- InProgress;
      List.iter aux sommet.n_link_to;
      sommet.n_mark <- Visited;
      l := sommet.n_label:: !l;
      end
  in
    List.iter (fun n -> if n.n_linked_by = [] then (aux n) else ()) g.g_nodes;
    !l;;
  

