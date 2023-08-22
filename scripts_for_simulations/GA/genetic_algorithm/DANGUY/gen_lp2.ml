open Vars

let (problem_file,model,pD,pDmin,pDmax,pKm,pKp,pCmax,pMin,pMax,freq,q,dis,tfphi,phimax,phi_file,usex,example_file,outdir)=
  read_config ()
  
let (tu,tsd,tlogw,tuc,tucext,tibd,tqij,namesi,namesj,namesij,tnames,parents,parentsphi,example) =
  read_files problem_file tfphi phi_file usex example_file

let psize=Array.length tu
  
let _ =
  Printf.printf "model=%d\n" model;
  let fp = open_out "alice.lp" in
  
  if model=2 then Printf.fprintf fp "min: "
  else Printf.fprintf fp "max: ";
  for i = 0 to psize-1 do
    (match model with
    | 1 -> Printf.fprintf fp "%.15e x%d" tu.(i) i;
    | 2 -> Printf.fprintf fp "%.15e x%d" tlogw.(i) i; 
    | 4 -> Printf.fprintf fp "%.15e x%d" tuc.(i) i;
    | 9 -> Printf.fprintf fp "%.15e x%d" tucext.(i) i;
    | _ -> failwith "Modele non lineaire ou Unreachable");
    if i<> (psize-1) then Printf.fprintf fp " + "
    else Printf.fprintf fp ";\n\n"
  done;
  
  for i = 0 to psize-1 do
    Printf.fprintf fp "x%d" i;
    if i<> (psize-1) then Printf.fprintf fp " + "
    else Printf.fprintf fp "=%d;\n\n" pD
  done;

  for i = 0 to psize-1 do
    Printf.fprintf fp "y%d" i;
    if i<> (psize-1) then Printf.fprintf fp " + "
    else Printf.fprintf fp ">=%d;\n\n" pKm
  done;

  for i = 0 to psize-1 do
    Printf.fprintf fp "y%d" i;
    if i<> (psize-1) then Printf.fprintf fp " + "
    else Printf.fprintf fp "<=%d;\n\n" pKp
  done;

  for i=0 to psize-1 do
    Printf.fprintf fp "y%d >= 0;\n" i ;
    Printf.fprintf fp "y%d <= 1;\n" i;
  done;
  Printf.fprintf fp "\n";
  
  for i=0 to psize-1 do
    Printf.fprintf fp "%d y%d - x%d >= 0;\n" pDmax i i;
    Printf.fprintf fp "x%d - %d y%d >= 0;\n" i pDmin i;
  done;
  Printf.fprintf fp "\n";

  SM.iter
    (fun _ s ->
      let start = ref true in
      IS.iter
        (fun i ->
          if !start then Printf.fprintf fp "x%i" i
          else Printf.fprintf fp " + x%i" i;
          start := false)
        s;
      Printf.fprintf fp "<=%d;\n" pCmax
    )
    namesij;

  let k = ref 0 in
  SM.iter
    (fun _ s ->
      let start = ref true in
      IS.iter
        (fun i ->
          if !start then Printf.fprintf fp "y%i" i
          else Printf.fprintf fp " + y%i" i;
          start := false)
        s;
      Printf.fprintf fp ">=z%d;\n"  !k;
      start:=true;
      IS.iter
        (fun i ->
          if !start then Printf.fprintf fp "y%i" i
          else Printf.fprintf fp " + y%i" i;
          start := false)
        s;
      Printf.fprintf fp "<=%d * z%d;\n"  psize !k;
      Printf.fprintf fp "z%d<=1;\n" !k;
      Printf.fprintf fp "z%d>=0;\n" !k;
      incr k
    )
    namesij;

  Printf.fprintf fp "\n";
  for i = 0 to !k -1 do
    if i=0 then Printf.fprintf fp "z%d" i
    else Printf.fprintf fp "+z%d" i;
  done;
  Printf.fprintf fp "<=%d;\n\n" pMax;
  
  for i = 0 to !k -1 do
    if i=0 then Printf.fprintf fp "z%d" i
    else Printf.fprintf fp "+z%d" i;
  done;
  Printf.fprintf fp ">=%d;\n\n" pMin;
  
  Printf.fprintf fp "int ";
  for i=0 to psize-1 do
    Printf.fprintf fp "x%d" i;
    if i<> (psize-1) then Printf.fprintf fp ","
    else Printf.fprintf fp ";\n\n"
  done;

  Printf.fprintf fp "int ";
  for i=0 to psize-1 do
    Printf.fprintf fp "y%d" i;
    if i<> (psize-1) then Printf.fprintf fp ","
    else Printf.fprintf fp ";\n\n"
  done;

  Printf.fprintf fp "int ";
  for i=0 to !k-1 do
    Printf.fprintf fp "z%d" i;
    if i<> (!k-1) then Printf.fprintf fp ","
    else Printf.fprintf fp ";\n\n"
  done;

  close_out fp;;
