module OrderedString = struct type t = string let compare = compare end;;
module SM = Map.Make(OrderedString);;
module SS = Set.Make(OrderedString);;

module OrderedInt = struct type t = int let compare = compare end;;
module IM = Map.Make(OrderedInt);;
module IS = Set.Make(OrderedInt);;

module MIT=CCWBTree.Make(OrderedInt);;
let rsa = Random.State.make [|1;2;3;5|];;

let config_filename = ref "config400.cfg"
let _ =
  Arg.parse
    [
      ("-c",Arg.Set_string config_filename,"config10k.cfg or config400.cfg by default")
    ]
    (fun _ ->())
    "Usage: ./lpcreate -c config10k.cfg or config400.cfg by default";
  
  Printf.printf "config=%s\n" !config_filename

                    
let fileout = ref stdout
  
let bool_of_string =
  function 
"true" -> true 
  | _   -> false
      

let map = 
  let m = ref SM.empty in
  let inch = open_in !config_filename in
  try (
    while true do
      let st = (input_line inch) in
      let sttab = Array.of_list (Str.split (Str.regexp "[ \t]+") st) in
      if (Array.length sttab) >=2 then
	m:= SM.add sttab.(0) sttab.(1) !m;
    done;
    !m)
  with
    End_of_file -> close_in inch;!m
  | x -> raise x
;;

let find_val s = 
  try (
    let res=SM.find s map in
    Printf.fprintf !fileout "%s=%s\n" s res;flush stdout;res)
  with x -> Printf.fprintf !fileout "erreur:%s\n" s;flush stdout;raise x;;

let read_config () =
  let problem_file= (find_val "problem_file")
  and model= int_of_string (find_val "model") 
  and pD = int_of_string (find_val "pD") 
  and pDmin = int_of_string (find_val "pDmin") 
  and pDmax = int_of_string (find_val "pDmax") 
  and pKm = int_of_string (find_val "pKm") 
  and pKp = int_of_string (find_val "pKp") 
  and pCmax = int_of_string (find_val "pCmax") 
  and pMin = int_of_string (find_val "pMin") 
  and pMax = int_of_string (find_val "pMax")
  and freq = int_of_string (find_val "freq")
  and q = float_of_string (find_val "q")
  and dis = int_of_string (find_val "dis")
  and phimax= float_of_string (find_val "phimax")
  and tfphi= bool_of_string (find_val "tfphi")
  and phi_file= (find_val "phi_file") 
  and usex= bool_of_string (find_val "usex")
  and example_file= (find_val "example_file") 
  and outdir = (find_val "outdir")
  in
  (problem_file,model,pD,pDmin,pDmax,pKm,pKp,pCmax,pMin,pMax,freq,q,dis,tfphi,phimax,phi_file,usex,example_file,outdir);;

let add_to m p i =
  let s =
    try SM.find p !m
    with Not_found -> IS.empty in
  m:= SM.add p (IS.add i s) !m;;

let print_map m =
  SM.iter
    (fun n s ->
      Printf.printf "%s:" n;
      IS.iter (fun e -> Printf.printf " %d" e) s;
      print_newline())
    m;;

let read_files problem_file tfphi phi_file usex example_file=
  let fp = open_in problem_file 
  and sep = Str.regexp "[ \t=]+" in
  ignore (input_line fp);
  let acc = ref [] in
  let parents=ref [] in
  (try while true do acc := (input_line fp):: !acc done;failwith "Unreachable"
   with End_of_file -> close_in fp);
  let size = List.length !acc in
  Printf.printf "size=%d\n" size;
  let namesij = ref SM.empty
  and namesi = ref SM.empty
  and namesj = ref SM.empty
  and tu = Array.make size 0.0
  and tsd = Array.make size 0.0
  and tlogw = Array.make size 0.0
  and tuc = Array.make size 0.0
  and tucext = Array.make size 0.0
  and tnames = Array.make size ("","") in
  List.iteri
    (fun i s ->
      match Str.split sep s  with
        p1::p2::u::sd::logw::uc::tl ->
         parents:= (p1,p2):: !parents;
         add_to namesi p1 i;
         add_to namesj p2 i;
         add_to namesij p1 i;
         add_to namesij p2 i;
         tnames.(i) <-(p1,p2);
         tu.(i)    <- float_of_string u;
         tsd.(i)   <- float_of_string sd;
         tlogw.(i) <- float_of_string logw;
         tuc.(i)   <- float_of_string uc;
         begin
           match tl with
             ucext::_ -> (tucext.(i) <- float_of_string ucext)
           | _ -> ()
         end;
      | _ -> failwith "Problem format vars1"  
    )
    (List.rev !acc);

  let fp = open_in "tab2_expected_best_order_statistic.txt" in
  ignore (input_line fp);
  let acc = ref [] in
  (try while true do acc := (input_line fp):: !acc done;failwith "Unreachable"
   with End_of_file -> close_in fp);
  let size = List.length !acc in
  let tibd = Array.make size 0.0 in
  List.iteri
    (fun i s ->
      match Str.split sep s with
        _::dij::_ ->
         tibd.(i) <- float_of_string dij
      | _ -> failwith "Problem format tab2"
    )(List.rev !acc);

  let fp = open_in "tab3_selection_intensity.txt" in
  ignore (input_line fp);
  let acc = ref [] in
  (try while true do acc := (input_line fp):: !acc done;failwith "Unreachable"
   with End_of_file -> close_in fp);
  let size = List.length !acc in
  let tqij = Array.make (size+1) 0.0 in
  List.iteri
    (fun i s ->
      match Str.split sep s with
        _::qij::_  -> 
        tqij.(i+1) <- float_of_string qij
       | _ -> failwith "Probem format tab3")
    !acc;

  let parentsphi =
    if tfphi then
      begin
        let parentsphi = ref [] in 
        let fp = open_in phi_file in
        ignore (input_line fp);
        let acc = ref [] in
        (try while true do acc := (input_line fp):: !acc done;failwith "Unreachable"
         with End_of_file -> close_in fp);
        List.iter
          (fun s ->
            match Str.split sep s with
              i::j::q::_  ->
               parentsphi:= (i,j,float_of_string q):: !parentsphi
            | _ -> failwith "Problem reading phi")
          !acc;
        Some (Array.of_list (List.rev !parentsphi))
      end
    else None in

  let example =
    if usex then
      begin
        let example = ref [] in 
        let fp = open_in example_file in
        ignore (input_line fp);
        let acc = ref [] in
        (try while true do acc := (input_line fp):: !acc done;failwith "Unreachable"
         with End_of_file -> close_in fp);
        List.iter
          (fun s ->
            match Str.split sep s with
              i::j::q::_  ->
               example:= (i,j,int_of_string q):: !example
            | _ -> failwith "Problem reading example")
          !acc;
        Some (Array.of_list (List.rev !example))
      end
    else None in

  
  (*  Array.iteri (fun i x -> Printf.printf "%d %16.14f\n" i x) tqij; *)
  (*
  print_map !namesi;
  print_newline();
  print_map !namesj;
  print_newline();
  print_map !namesij;
  print_newline();
  exit 0;
   *)
  
  let minsdnz=0.0001*. Array.fold_left (fun m x -> if x>0. then min x m else m) (1./.0.) tsd in
  let tsd=Array.map (fun x -> if x>0. then x else minsdnz) tsd in
  let parents=Array.of_list (List.rev !parents) in
  (tu,tsd,tlogw,tuc,tucext,tibd,tqij,!namesi,!namesj,!namesij,tnames,parents,parentsphi,example);;


let readsol fichname size =
  let fp = open_in fichname
  and sep = Str.regexp "[ \t=]+" in
  let acc=ref [] in
  for _=1 to 4 do ignore (input_line fp) done;
  (try
     for _=1 to size do acc := (input_line fp):: !acc done;
   with End_of_file -> close_in fp);
  let dm =ref MIT.empty  in
  List.iteri
    (fun i s ->
      match Str.split sep s with
        _::dij::[] ->
         let dij=int_of_string dij in
         if dij>0 then 
           dm:=MIT.add i dij !dm
        | _ -> failwith "Problem format vars4")
    (List.rev !acc);
  dm
  

let red   = "\x1B[31m";;
let grn   = "\x1B[32m";;
let yel   = "\x1B[33m";;
let blu   = "\x1B[34m";;
let mag   = "\x1B[35m";;
let cyn   = "\x1B[36m";;
let wht   = "\x1B[37m";;
let reset = "\x1B[0m";;

