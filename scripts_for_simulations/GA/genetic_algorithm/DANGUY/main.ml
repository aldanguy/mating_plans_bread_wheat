open Vars

let (problem_file,model,pD,pDmin,pDmax,pKm,pKp,pCmax,pMin,pMax,freq,q,dis,tfphi,phimax,phi_file,usex,example_file,outdir)=
  read_config ()
  
let (tu,tsd,tlogw,tuc,tucext,tibd,tqij,namesi,namesj,namesij,tnames,parents,parentsphi,example) =
  read_files problem_file tfphi phi_file usex example_file

(*  
let _ =
  Array.iteri (fun i x -> Printf.printf "%d %f\n" i x) tqij
 *)
  
let psize=Array.length tu;; 
let nbpar=(SM.cardinal namesij);;

let smin = Array.fold_left (fun x y -> min x y) (1.0/.0.0) tu;; 

let tabnamepar=
  let tab=Array.init nbpar (fun  _ -> " ") in
  let t=ref 0 in
  SM.iter (fun n _ -> tab.(!t)<-n;incr t) namesij;
  tab

  (*
let _ =
  Array.iteri (fun i n -> Printf.printf "%d %s\n" i n) tabnamepar;
  print_map namesij
   *)

  
let parentsij=
  Array.map (fun (n1,n2) ->
      let i1=ref nbpar and i2=ref nbpar and c=ref 0 in
      try 
        Array.iteri (fun i n -> if n=n1 then (incr c;i1:=i;if !c=2 then raise Exit);
                                if n=n2 then (incr c;i2:=i;if !c=2 then raise Exit);
          ) tabnamepar;
        (nbpar,nbpar)
      with
        _ -> (!i1, !i2)) parents

(*
let _ = Array.iteri (fun i (p1,p2) -> Printf.printf "%d %d %d\n" i p1 p2) parentsij;raise Exit 
 *)
  
let parentsphiij=
  match parentsphi with
    None -> None;
  | Some parentsphi ->
     begin
       let res=Array.map (fun (n1,n2,phi) ->
                   let i1=ref nbpar and i2=ref nbpar and c=ref 0 in
                   try 
                     Array.iteri (fun i n -> if n=n1 then (incr c;i1:=i;if !c=2 then raise Exit);
                                             if n=n2 then (incr c;i2:=i;if !c=2 then raise Exit);
                       ) tabnamepar;
                     (nbpar,nbpar,phi)
                   with
                     _ -> (!i1, !i2, phi)) parentsphi in
       Some res
     end

exception Found of int
        
let exampleMIT=
  match example with
    None -> None;
  | Some example ->
     begin
       let tab=Array.map (fun (n1,n2,q) ->
                   let i1=ref nbpar and i2=ref nbpar and c=ref 0 in
                   try 
                     Array.iteri (fun i n ->
                         if n=n1 then (incr c;i1:=i;if !c=2 then raise Exit);
                         if n=n2 then (incr c;i2:=i;if !c=2 then raise Exit);
                       ) tabnamepar;
                     (nbpar,nbpar,q)
                   with
                     _ -> (!i1, !i2, q)) example in

       let dm=ref MIT.empty in
       Array.iter (fun (i1,i2,q) ->
           let indice=
             try
               Array.iteri (fun i (p1,p2) -> if p1=i1 && p2=i2 then raise (Found i)) parentsij;
               failwith "Probleme construction example fourni"
             with
               Found i-> i  in
           dm:=MIT.add indice q !dm;) tab;
       Some !dm
     end

(*
let _ =
  match exampleMIT with
    None -> ()
  | Some exampleMIT ->
       MIT.iter ~f:(fun i x -> Printf.printf "%d %d\n" i x) exampleMIT; raise Exit
 *)  
    
let tabphinew=
  match parentsphiij with
    None -> None
  | Some parentsphiij ->
     let tab=Array.init nbpar (fun _ -> Array.init nbpar (fun _ -> 0.)) in
     Array.iter (fun (i,j,x) -> tab.(i).(j) <- x; tab.(j).(i)<-x) parentsphiij;
     Some tab
     
  
let tabph =
  match tabphinew with
    None -> None
  | Some tabphinew ->
     Some (Array.init psize (fun k -> let (i,j)=parentsij.(k) in tabphinew.(i).(j))) 
    
  
(* tableau des listes d'enfants d'un parent*)
let enfantsi=
  Array.map (fun n ->
      let l=ref [] in
      Array.iteri (fun i (n1,n2) -> if n=n1 || n=n2 then if not (List.mem i !l) then l:=i:: !l) parents;
      !l) tabnamepar

(* tableau des tableaux des enfants d'un parent*) 
let enfantstabi=
  Array.init nbpar (fun i -> Array.of_list enfantsi.(i))
  
(* tableau des longueur des tableaux des enfants d'un parent*) 
let enfantsnbi=
  Array.init nbpar (fun i -> List.length enfantsi.(i))

let signf x = if x<0. then -1. else if x>0. then 1. else 0. ;;
external erf : float -> float = "ml_erf";;
external erfc : float -> float = "ml_erfc";;
(* Voir https://en.wikipedia.org/wiki/Normal_distribution *)
(* m: mean, s: sigma *)
let cdf m s x = (1. +. (erf ((x -. m)/.(s*. (sqrt 2.)))))/.2.;;
(* let ccdf m s x = 1. -. (cdf m s x);; *)
let ccdf m s x = (erfc ((x -. m)/.(s*. (sqrt 2.))))/.2.;;

let compute_tqm dm =
  let epsilon=0.0001 in
  let tq=ref MIT.empty in
  let delta s =
    let acc = ref 0.0 in
    MIT.iter ~f:(fun i x ->
        let res=(ccdf tu.(i) tsd.(i) s) in
        tq:=MIT.add i res !tq;
        acc := !acc+.(float x)*.res) dm;
    !acc/.(float pD)-.q in
  
  let s_min = ref smin in
  if (delta !s_min) < 0.0 then failwith "Error s_min negatif";
  (*Printf.printf "s_min=%f\n" !s_min; flush stdout; *)
  
  let s_max = ref (max 1. (2.0*. !s_min)) in
  let res_max= ref (delta !s_max) in
  while !res_max>0.0 do
    s_max := 2.0 *. !s_max;
    res_max := delta !s_max;
  done;
  (*  Printf.printf "s_max=%f\n" !s_max; *)
  
  let s_mean = ref ((!s_min+. !s_max)/.2.0) in
  let res_mean = ref (delta !s_mean) in
  let nb_iters=ref 0 in
  while (abs_float !res_mean)>epsilon do
    if !res_mean>0.0 then s_min := !s_mean else s_max := !s_mean;
    s_mean := (!s_min+. !s_max)/.2.0;
    res_mean := delta !s_mean;
    incr nb_iters;
  done;
(*
  Printf.printf "s_mean=%f res_mean=%f nb_iters=%d\n" !s_mean !res_mean !nb_iters;
  Array.iter (fun x -> Printf.printf "%f " x) tq;
  print_newline(); *)
  !tq;;

let _ =
  match exampleMIT with
    Some exampleMIT ->
     begin
       let dm=(MIT.map ~f:(fun x -> x) exampleMIT) in
       let tq=compute_tqm dm in
       let fich=open_out "tq.txt" in
       Printf.fprintf fich "parenti parentj d_ij q q'\n";
       MIT.iter ~f:(fun i x ->
           let m=try MIT.get_exn i dm with 
                   Not_found -> 0 in
           let j1,j2=parents.(i) in
           Printf.fprintf fich "%s %s %d %f %f\n" j1 j2 m x (max x 0.001)) tq;
       close_out fich;
     end
  | None -> ()

let pDminsur2=pDmin/2
            
let norm e =
  let v = min pDmax e in
  if v<=pDminsur2 then 0 else max pDmin v;;

module L = struct
  open Ga_types
     
  let gvars = Ga_cfg.read_config "general.cfg"
            
  type data = {
      dm: int MIT.t; (*nombre d'enfants*)
      pm: int MIT.t; (*nombre de parents*)
    }
  type user_data= unit
  type result = unit
  exception Fin_AG
          
  let viol=ref 0
  let nbmodels=9
  let constante=ref 0. (*constante 1-.fitness minimale observée à la premiere generation*)
              
  let calculphi data =
    match tabphinew with
      None -> 0.
     |Some tabphinew ->
       let phi=ref 0. in
       let nbpar=ref 0 in
       MIT.iter ~f:(fun i xi ->
           nbpar:= !nbpar+xi;
           MIT.iter ~f:(fun j xj -> phi:= !phi +. (float xi)*.(float xj)*.tabphinew.(i).(j)) data.pm) data.pm;
       !phi/.(float (!nbpar* !nbpar))    

  let fitness data model=   (*la fonction a minimiser*)
    let tq = if model>=5 then compute_tqm data.dm else MIT.empty in
    let sum = ref 0. in
    MIT.iter ~f:(fun i x ->
        match model with
        | 1 -> sum := !sum+.(float x)*.tu.(i)
        | 2 -> sum := !sum-.(float x)*.tlogw.(i)
        | 3 -> sum := !sum+.(float x)*.(tu.(i)+.(tsd.(i)*.tibd.(x)));
        | 4 -> sum := !sum+.(float x)*.tuc.(i)
        | 5 ->
           let tqi=(MIT.get_exn i tq) in
           let indice=truncate (tqi*.10000.) in
           let newtuci=tu.(i)+.tsd.(i)*.tqij.(indice) in
           sum := !sum+.(newtuci*.(float x)*.tqi)/.(q*.(float pD)) 
        (*  oldversion sum := !sum+.(tuc.(i)*.(float x)*.tqi)/.(q*.(float pD)) *)
        | 6 ->
           let tqi=MIT.get_exn i tq in
           let indice=truncate (tqi*.10000.) in
           let newtuci=tu.(i)+.tsd.(i)*.tqij.(indice) in
           let fij=(float x)*.tqi in
           let fij=if fij>=1. then fij else 0.1 in
           sum := !sum+.(newtuci*.fij)/.(q*.(float pD))
        | 7 ->
           let tqi=max 0.001 (MIT.get_exn i tq) in
           let indice=truncate (tqi*.10000.) in
           let newtuci=tu.(i)+.tsd.(i)*.tqij.(indice) in
           sum := !sum+.(newtuci*.(float x)*.tqi)/.(q*.(float pD))
        | 8 ->
           let tqi=MIT.get_exn i tq in
           let indice=truncate (tqi*.10000.) in
           let newtuci=tu.(i)+.tsd.(i)*.tqij.(indice) in
           let fij=(float x)*.tqi in
           let fij=if fij>=1. then fij else 0.01*.(float x) in
           sum := !sum+.(newtuci*.fij)/.(q*.(float pD))
        | 9 -> sum := !sum+.(float x)*.tucext.(i)
        | _ -> failwith "modele inconnu")
      data.dm;
    MIT.iter ~f:(fun _ x -> if x > pCmax then sum := !sum *. (float pCmax)/.(float x)) data.pm;

    (*contrainte phi*)
    if tfphi then
      begin
        let phi=calculphi data in
        if phi>phimax then sum:= phimax/.(phi); 
      end;
    !sum;;

  
  let fitnessm data model=   (*la fonction a minimiser*)
    let res=fitness data model in
    max 0. (!constante+.res);;
  
  let eval _u _numgen data = 
    (lazy (fitnessm data model));;
  
  let addtonorm dm i y =
    let x=try MIT.get_exn i !dm with 
            Not_found -> 0 in
    let res=norm (x+y) in
    if res=0 then dm:=MIT.remove i !dm 
    else dm:=MIT.add i res !dm
    
  let addto pm i y =
    let x=try MIT.get_exn i !pm with 
            Not_found -> 0 in
    let res=(x+y) in
    if res=0 then pm:=MIT.remove i !pm 
    else pm:=MIT.add i res !pm 
    
  let verificationmred dm pm s =
    let es=ref 0 and epm=ref MIT.empty  in
    MIT.iter ~f:(fun i x ->
        if x>pDmax || (x<pDmin && x<>0) then (Printf.printf "M d_%d=%d\n" i x;flush stdout;raise Exit);
        if x>0 then
          begin
            es:= !es+x;
            let (i1,i2)=parentsij.(i) in
            addto epm i1 x;
            addto epm i2 x;
          end) dm;
    if !es<> s then (Printf.printf "M es=%d s=%d\n" !es s;flush stdout;raise Exit);
    MIT.iter ~f:(fun i x ->
        let epi=try (MIT.get_exn i !epm) with Not_found -> 0 in
        if epi<> x (*|| p.(i) > pCmax *) then (Printf.printf "M ep_%d=%d p_%d=%d\n" i epi i x;flush stdout;raise Exit)) pm;; 

  
  let norm_popm dm =
    (*s=somme des Dij, nz=Dij non nuls, pm=map des parents, np=parents non nuls*)
    (*MAJ des parametres*)
    (*    MIT.iter ~f:(fun i x -> if x=0 then dm:=MIT.remove i !dm) !dm; *)
    let s=ref 0 in
    let pm=ref MIT.empty in
    MIT.iter ~f:(fun k y ->
        s:= !s+y;
        let (i,j)=parentsij.(k) in
        addto pm i y;
        addto pm j y) !dm;
    (*trop de parents*)
    while MIT.cardinal !pm>pMax do
      let (i,_)=MIT.random_choose rsa !pm in
      let l=enfantsi.(i) in
      let qm=List.fold_left (fun s j ->
                 let q=try (MIT.get_exn j !dm) with Not_found -> 0 in
                 if q>0 then
                   begin
                     let i1,i2=parentsij.(j) in
                     dm:=MIT.remove j !dm;
                     addto pm i1 (-q);
                     addto pm i2 (-q)
                   end;
                 s+q) 0 l in
      s:= !s - qm
    done;
    (*pas assez de parents*)
    let testpMin i j _ cardpm=
      MIT.mem i !pm ||
        let i1,i2=parentsij.(j) in
        let np1=if MIT.mem i1 !pm then 0 else 1
        and np2=if MIT.mem i2 !pm then 0 else 1 in
        let nnp= cardpm+np1+np2 in
        nnp>pMax in
    let rec findpMinijq cardpm =
      let i=Random.int nbpar in
      let j=enfantstabi.(i).(Random.int enfantsnbi.(i)) in
      let q=(pDmin+Random.int (pDmax-pDmin+1)) in
      if testpMin i j q cardpm then findpMinijq cardpm else (i,j,q) in
    while MIT.cardinal !pm<pMin do
      let cardpm = (MIT.cardinal !pm) in
      let _,j,q=findpMinijq cardpm in
      dm:=MIT.add j q !dm;
      let i1,i2=parentsij.(j) in
      addto pm i1 q;
      addto pm i2 q;
      s:= !s + q;
    done;
    (*bornes des parents dépassées*)
    let testpCmax j q cardpm=
      q=0 ||
        let i1,i2=parentsij.(j) in
        let pi1=try (MIT.get_exn i1 !pm) with Not_found -> failwith "bornes des parents dep" in
        let pi2=try (MIT.get_exn i2 !pm) with Not_found -> failwith "bornes des parents dep" in
        let np1=if pi1=q then -1 else 0
        and np2=if pi2=q then -1 else 0 in
        let nnp= cardpm+np1+np2 in
        nnp<pMin in
    let rec findpCmaxjq i cardpm=
      let j=enfantstabi.(i).(Random.int enfantsnbi.(i)) in
      let dj=try (MIT.get_exn j !dm) with Not_found -> 0 in
      let qq=Random.int (1+dj) in
      let q= (dj - (norm (dj-qq))) in
      if testpCmax j q cardpm then findpCmaxjq i cardpm else (j,q) in
    let reducepCmax i x=
      let xx=ref x in 
      while (!xx>pCmax) do
        let cardpm=(MIT.cardinal !pm) in
        let j,q=findpCmaxjq i cardpm in
        let i1,i2=parentsij.(j) in
        addtonorm dm j (-q);
        s:= !s - q;
        xx:= !xx -q;
        addto pm i1 (-q);
        addto pm i2 (-q);
      done in
    MIT.iter ~f:(fun i x -> reducepCmax i x) !pm;
    (*pas assez d'enfants diff*)
    let testpKm j q cardpm e=
      let delta= e/psize in
      MIT.mem j !dm ||
        let i1,i2=parentsij.(j) in
        let pi1=try (MIT.get_exn i1 !pm) with Not_found -> 0 in
        let pi2=try (MIT.get_exn i2 !pm) with Not_found -> 0 in
        let p1=if pi1=0 then 1 else 0
        and p2=if pi2=0 then 1 else 0 in
        (p1+p2+cardpm>pMax)  || (pi1+q>pCmax+delta) || (pi2+q>pCmax+delta) in
    let rec findpKmjq cardpm e =
      let j=Random.int psize in      
      (*      let q= (pDmin+Random.int (pDmax-pDmin+1)) in *)
      let q=pDmin in
      if (testpKm j q cardpm e) then findpKmjq cardpm (e+1) else (j,q) in
    while (MIT.cardinal !dm < pKm) do
      let cardpm=(MIT.cardinal !pm) in
      let j,q=findpKmjq cardpm 0 in
      dm:=MIT.add j q !dm;
      s:= !s+ q;
      let i1,i2=parentsij.(j) in
      addto pm i1 q;
      addto pm i2 q;
    done;
    (*trop d'enfants diff*)
    let testpKp j q cardpm=
      let i1,i2=parentsij.(j) in
      let pi1=try (MIT.get_exn i1 !pm) with Not_found -> failwith "trop d'enfants diff" in
      let pi2=try (MIT.get_exn i2 !pm) with Not_found -> failwith "trop d'enfants diff" in
      let p1=if pi1=q then -1 else 0
      and p2=if pi2=q then -1 else 0 in
      (cardpm+p1+p2<pMin) in
    let rec findpKpjq cardpm=
      let (j,q)=MIT.random_choose rsa !dm in
      if (testpKp j q cardpm) then findpKpjq cardpm else (j,q) in
    while (MIT.cardinal !dm> pKp) do
      let cardpm=MIT.cardinal !pm in
      let j,q=findpKpjq cardpm in
      dm:=MIT.remove j !dm;
      s:= !s- q;
      let i1,i2=parentsij.(j) in
      addto pm i1 (-q);
      addto pm i2 (-q);
    done;
    (* pas assez d'enfants *)
    let testpDm j dj i1 i2 q carddm cardpm e=
      q=0 || !s+ q>pD || dj+q>pDmax ||
        let delta= e/psize in
        let nn=if MIT.mem j !dm then 0 else 1 in
        nn+ carddm>pKp ||
          let p1= if MIT.mem i1 !pm then 0 else 1 in
          let pi1=try (MIT.get_exn i1 !pm) with Not_found -> 0 in
          pi1+q>pCmax+delta ||
            let p2= if MIT.mem i2 !pm then 0 else 1 in
            let pi2=try (MIT.get_exn i2 !pm) with Not_found -> 0 in
            ((p1+p2+ cardpm>pMax) ||  pi2+q>pCmax+delta) in
    let rec findpDmjq carddm cardpm e=
      let j=Random.int psize in
      let i1,i2=parentsij.(j) in
      let dj=try (MIT.get_exn j !dm) with Not_found -> 0 in
      let qq=min (pD- !s) (Random.int (1+pDmax-dj)) in
      let q=(norm (dj+qq))-dj in 
      if testpDm j dj i1 i2 q carddm cardpm e then findpDmjq carddm cardpm (e+1) else (j,i1,i2,q,e) in
    while (!s<pD) do
      let carddm=MIT.cardinal !dm in
      let cardpm=MIT.cardinal !pm in
      let (j,i1,i2,q,_)=findpDmjq carddm cardpm 0 in
      addtonorm dm j q;
      s:= !s+ q;
      addto pm i1 q;
      addto pm i2 q;
    done;
    (* trop d'enfants *)
    let testpDp j q carddm cardpm=
      (!s- q<pD) || 
        let dj=try (MIT.get_exn j !dm) with Not_found -> 0 in
        let nn=if dj=q then 1 else 0 in
        (carddm-nn <pKm) ||
          let i1,i2=parentsij.(j) in
          let pi1=MIT.get_exn i1 !pm in
          let pi2=MIT.get_exn i2 !pm in
          let p1=if pi1=q then 1 else 0
          and p2=if pi2=q then 1 else 0 in
          (cardpm-p1-p2<pMin) in
    let rec findpDpjq carddm cardpm =
      let (j,dj)=MIT.random_choose rsa !dm in
      let q=if dj= pDmin then pDmin else 1 in 
      if testpDp j q carddm cardpm then findpDpjq carddm cardpm else (j,q) in 
    while (!s>pD) do
      let carddm=MIT.cardinal !dm in
      let cardpm=MIT.cardinal !pm in
      let j,q=findpDpjq carddm cardpm in
      addtonorm dm j (-q);
      s:= !s- q;
      let i1,i2=parentsij.(j) in
      addto pm i1 (-q);
      addto pm i2 (-q);
    done;
    (*affichage*)
    let maxp=ref 0 in
    MIT.iter ~f:(fun _ x -> maxp:=max !maxp x) !pm;
    if !maxp>pCmax then incr viol;
    (*    verificationmred !dm !pm !s; *)
    {dm= !dm;pm= !pm};;

  (* indice non utilisé*)
  let rec ff dm dim =
    let i=Random.int dim in
    if MIT.mem i dm then ff dm dim else i

  let generaterandom () =
    let nz=pKm + Random.int (1+pKp-pKm) in
    let moy2=(2*pD)/nz+1 in
    let dm=ref MIT.empty in
    for _=1 to nz do
      let y=max pDmin (norm (Random.int moy2)) in
      let k=ff !dm psize in
      dm:=MIT.add k y !dm;
    done;
(*    let d=Array.make psize 0 in
    MIT.iter ~f:(fun i x -> d.(i)<-x) !dm; *)
    norm_popm dm;;


  let generatefromexample exampleMIT =
    let dm=ref (MIT.map ~f:(fun x -> x) exampleMIT) in
    for _=0 to Random.int (pD/10) do
      let im=ff !dm psize in
      let jm,_=MIT.random_choose rsa !dm in
      let q=1+Random.int pDmin in
      addtonorm dm im q;
      addtonorm dm jm (-q);
    done;
    norm_popm dm;;

  let first=ref true
  
  let generate _u _numgen =
    match exampleMIT with
      Some exampleMIT ->
       if !first then
         begin
           first:=false;
           let dm=ref (MIT.map ~f:(fun x -> x) exampleMIT) in
           let d=norm_popm dm in
           (*           Printf.printf "%f\n" (fitness d 5); flush stdout; raise Exit; *)
           d
         end
       else if Random.int 2 > 0 then 
         generatefromexample exampleMIT 
       else generaterandom ()
      | _ -> generaterandom ()
         
  (*
  let generate10kbestmodel1 u numgen =
    let dm=readsol "toto1" psize in
    let data=norm_popm dm in
    Printf.printf "fitness 5 de l'optimum 1=%f\n" (fitness data  5);
    data;;
   *)
  (*
  let first=ref true 
  let generate10k u numgen =
    if true || !first then (first:=false;generate10k u numgen)
    else generaterandom u numgen
   *)

  let gebmoinsalphaphi dij=
    match tabphinew with
      None -> 0.
     |Some tabphinew ->
       let (i,j)=parentsij.(dij) in
       let ph=tabphinew.(i).(j) in
       (*    Printf.printf "tu.(%d)=%f (%d,%d) %f\n" dij tu.(dij) i j ph;flush stdout; *)
       0.*.tu.(dij)-.10.*.ph
       
  let cross _u _numgen a b =
    let newa_dm = ref (MIT.empty) 
    and newb_dm = ref (MIT.empty) in
    if Random.int 2=0 then
      begin
        let alpha=(Random.float 0.2) -.0.1 in
        MIT.iter ~f:(fun i xa ->
            let xb=try MIT.get_exn i b.dm with Not_found -> 0 in
            let na=norm (int_of_float (alpha*. (float xb) +. (1.-.alpha)*. (float xa))) in
            let nb=norm (int_of_float (alpha*. (float xa) +. (1.-.alpha)*. (float xb))) in
            if na>0 then newa_dm:=MIT.add i na !newa_dm;
            if nb>0 then newb_dm:=MIT.add i nb !newb_dm;
          ) a.dm;
        MIT.iter ~f:(fun i xb ->
            let xa=try MIT.get_exn i a.dm with Not_found -> 0 in
            let na=norm (int_of_float (alpha*. (float xb) +. (1.-.alpha)*. (float xa))) in
            let nb=norm (int_of_float (alpha*. (float xa) +. (1.-.alpha)*. (float xb))) in
            if na>0 then newa_dm:=MIT.add i na !newa_dm;
            if nb>0 then newb_dm:=MIT.add i nb !newb_dm;
          ) b.dm;
      end
    else
      begin
        MIT.iter ~f:(fun i x -> newa_dm:=MIT.add i x !newa_dm) a.dm;
        MIT.iter ~f:(fun i x -> newb_dm:=MIT.add i x !newb_dm) b.dm;
        MIT.iter ~f:(fun i x ->
            if Random.int 5 =0 then newa_dm:=MIT.add i x !newa_dm) b.dm;
        MIT.iter ~f:(fun i x ->
            if Random.int 5 =0 then newb_dm:=MIT.add i x !newb_dm) a.dm;
      end;
    let newa_d=Array.make psize 0
    and newb_d=Array.make psize 0 in
    MIT.iter ~f:(fun i x -> newa_d.(i)<-x) !newa_dm;
    MIT.iter ~f:(fun i x -> newb_d.(i)<-x) !newb_dm;
    (norm_popm newa_dm,norm_popm newb_dm);;

  
  let rec fnmaxm dm=
    let i=Random.int psize in
    let x=try MIT.get_exn i dm with Not_found -> 0 in
    if x<pDmax then (i,x)
    else fnmaxm dm
    
  let mutate0 _u _numgen a =
    let newa_dm=ref (MIT.map ~f:(fun x -> x) a.dm) in
    let f=ref (fitnessm a model) in
    let bestam=ref (MIT.map ~f:(fun x -> x) a.dm) in
    let tot=1+Random.int 10 in
    for _=1 to tot do
      let im,_=fnmaxm !newa_dm in
      let jm,_=MIT.random_choose rsa !newa_dm in
      let q=1+Random.int pDmin in
      addtonorm newa_dm im q;
      addtonorm newa_dm jm (-q);
      let newam=  norm_popm newa_dm in
      let nf= fitnessm newam model in
      if nf> !f then
        (f:=nf;bestam:=MIT.map ~f:(fun x -> x) newam.dm)
    done;
    norm_popm bestam;;

  let rec findioverphi dm c=
    match tabph with
      None -> 0
    | Some tabph ->
       let im,qi=MIT.random_choose rsa dm in
       if (tabph.(im)<phimax) && (c < 100) then findioverphi dm  (c+1)
       else im

  let rec findunderphi c =
    match tabph with
      None -> 0
    | Some tabph ->
       let i=Random.int psize in
       if tabph.(i) > phimax && (c < 100) then findunderphi (c+1)
       else i
       
  let mutatephi _u _numgen a =
    let newa_dm=ref (MIT.map ~f:(fun x -> x) a.dm) in
    for _=0 to Random.int 10 do
      let i=findioverphi a.dm 0 in
      let j=findunderphi 0 in
      let q=1+Random.int pDmin in
      (*      Printf.printf "i:%d j:%d q:%d\n" i j q; *)
      addtonorm newa_dm i (-q);
      addtonorm newa_dm j (q);
    done;
    let newam=  norm_popm newa_dm in
    newam;;

  let mutate u numgen a =
    if tfphi then 
      begin
        if calculphi a>phimax then mutatephi u numgen a else mutate0 u numgen a 
      end
    else
      mutate0 u numgen a
    
let distance1  _u d1 d2 =
  let sum=ref 0 in
  MIT.iter ~f:(fun i _ -> if not (MIT.mem i d2.dm)  then incr sum) d1.dm;
  MIT.iter ~f:(fun i _ -> if not (MIT.mem i d1.dm) then incr sum) d2.dm; 
  (float !sum)

let middle=pDmax/2
         
let distance2  _u d1 d2 =
  let sum=ref 0 in
  MIT.iter ~f:(fun i x -> if x>middle && not (MIT.mem i d2.dm) then incr sum) d1.dm; 
  MIT.iter ~f:(fun i x -> if x>middle && not (MIT.mem i d1.dm) then incr sum) d2.dm; 
  (float !sum)/.(float pKp)
  
let distance =
  match dis with
  |2 -> distance2
  |_ -> distance1
    
let barycenter _u d1 _n1 d2 _n2 =
  if Random.int 2=0 then d1 else d2
  
let init _u = 
  Random.init gvars.seed
  
let fileevol=(outdir^"/evolution"^(string_of_int model)^".csv")

let prepare_ag _u pop =
  let (mini,maxi)= Array.fold_left (fun (smin,smax) x -> let res=fitness x.data model in (min smin res,max smax res)) (0.,0.) pop in
  constante:= if maxi>0. then 0. else 1.-.mini;
  let _= Unix.system ("rm -rf "^outdir^"\nmkdir "^outdir) in ();
  let fichevol=open_out_gen [Open_append;Open_creat] 0o777 fileevol in
  Printf.fprintf fichevol "num_gen,";
  for m=1 to nbmodels do
    Printf.fprintf fichevol "fitness_%d," m 
  done;
  Printf.fprintf fichevol "\n";
  close_out fichevol                                                             
                                        
let prepare_gen _u _numgen pop =
  pop;;

let after_scale (*PRINT*) _u numgen _pop best =
  (*        Printf.fprintf fich "fitness,%f\n" (Lazy.force best.r_fit); *)
  let fichevol=open_out_gen [Open_append;Open_creat] 0o777 fileevol in
  Printf.fprintf fichevol "%d," numgen;
  for m=1 to nbmodels do
    Printf.fprintf fichevol"%f," (fitness best.data m);
  done;
  Printf.fprintf fichevol "\n";
  close_out fichevol;

  if numgen mod freq=0 then
    begin
      Printf.printf "\ngen:%d r_fit=%f s_fit=%f dep_cont=%d constante=%f\n"
        numgen (Lazy.force best.r_fit) best.s_fit !viol !constante;
      for m=1 to nbmodels do
        Printf.printf "fitness_%d %f\n" m (fitness best.data m)
      done;
      (*    mesure best.data.d; *)
      MIT.iter  ~f:
        (fun _ x->
          if x=0 then  Printf.printf "%s%d%s " blu x reset
          else if x< (pDmax/10) then  Printf.printf "%s%d%s " grn x reset
          else if x> ((9*pDmax)/10) then  Printf.printf "%s%d%s " yel x reset
          else Printf.printf "%d " x
        )
        best.data.dm;
      print_newline ();
      Array.iteri (fun i n ->
          let sum=try MIT.get_exn i best.data.pm with Not_found -> 0 in 
          if sum> pCmax then Printf.printf "%s(%s,%d)%s " red n sum reset
          else if sum > int_of_float ((float pCmax)/.1.2) then Printf.printf "%s(%s,%d)%s " yel n sum reset
          else if sum>0 then Printf.printf "(%s,%d)" n sum) tabnamepar;
      
      Printf.printf "\nnombre d'enfants=%d nombre de parents=%d\n"
        (MIT.cardinal best.data.dm) (MIT.cardinal best.data.pm);
      print_newline();

      let fich=open_out (outdir^"/resag"^(string_of_int model)^".csv") in
      (*        Printf.fprintf fich "fitness,%f\n" (Lazy.force best.r_fit); *)
      for m=1 to nbmodels do
        Printf.fprintf fich "fitness_%d,%f\n" m (fitness best.data m);
      done;
      if tfphi then Printf.printf "phi=%f\n" (calculphi best.data);
      Printf.fprintf fich "P1,P2,nbprogeny\n";
      MIT.iter ~f:(fun i di ->
          if di>0 then
            let p1,p2= parents.(i) in
            Printf.fprintf fich "%s,%s,%d\n" p1 p2 di) best.data.dm;
      close_out fich;
    end
  
let after_scaleNOPRINT _u numgen _pop best =
  if numgen mod freq=0 then
      begin
        Printf.printf "\ngen:%d r_fit=%f s_fit=%f dep_cont=%d\n"
          numgen (Lazy.force best.r_fit) best.s_fit !viol;
      end
    
    
let printfileshare numgen pop bestlist freq rate filename long=
  if numgen mod freq=0 then
    begin
      let bests=List.sort (fun i j ->
                    if (Lazy.force pop.(i).r_fit)<(Lazy.force pop.(j).r_fit) then 1 else -1) bestlist in
      let cut=rate*.(Lazy.force pop.(List.hd bests).r_fit) in
      let best_elems=
        let ll,_=List.fold_left (fun (acc,cp) i ->
                     if (Lazy.force pop.(i).r_fit)>cut && cp<long then (i::acc,cp+1) else (acc,cp+1))
                   ([],0) bests in
        List.rev ll in
      let nbb=List.length best_elems in
      let tabx=Array.init psize (fun _ -> Array.init nbb (fun _ -> 0)) in
      let tabf=Array.init (nbmodels+1) (fun _ -> Array.init nbb (fun _ -> 0.)) in
      let tabmin=Array.init (nbmodels+1) (fun _ -> 0.) in
      let tabmax=Array.init (nbmodels+1) (fun _ -> 0.) in
      let tabsum=Array.init (nbmodels+1) (fun _ -> 0.) in
      let tabmoy=Array.init (nbmodels+1) (fun _ -> 0.) in
      let tabsig=Array.init (nbmodels+1) (fun _ -> 0.) in
      let tabni=Array.init nbb (fun _ -> 0) in
      let tabna=Array.init nbb (fun _ -> 0) in
      let tabnz=Array.init nbb (fun _ -> 0) in
      let tabnpu=Array.init nbb (fun _ -> 0) in
      let tabpar=Array.init nbpar (fun _ -> Array.init nbb (fun _->0)) in
      List.iteri (fun j k->
          tabf.(0).(j) <- (Lazy.force pop.(k).r_fit);
          for m=1 to nbmodels do
            tabf.(m).(j) <- (fitness pop.(k).data m);
            tabsum.(m)<- tabsum.(m)+.tabf.(m).(j)
          done;
          MIT.iter ~f:(fun _ x-> if x=pDmin then tabni.(j)<-tabni.(j)+1) pop.(k).data.dm;
          MIT.iter ~f:(fun _ x-> if x=pDmax then tabna.(j)<-tabna.(j)+1) pop.(k).data.dm;  
          tabnz.(j) <- MIT.cardinal pop.(k).data.dm;
          tabnpu.(j)<-MIT.cardinal pop.(k).data.pm;      
          MIT.iter ~f:(fun i x-> tabx.(i).(j) <- x) pop.(k).data.dm;
        ) best_elems;
      for m=1 to nbmodels do
        tabmoy.(m)<- tabsum.(m)/.(float nbb);
        tabmin.(m)<- Array.fold_left (fun q x -> min q x) (1./.0.) tabf.(m);
        tabmax.(m)<- Array.fold_left (fun q x -> max q x) (0.) tabf.(m)
      done;
      for i=0 to nbb-1 do
        for m=1 to nbmodels do
          tabsig.(m)<- tabsig.(m)+.(tabf.(m).(i)-.tabmoy.(m))*.(tabf.(m).(i)-.tabmoy.(m))
        done;
      done;
      for m=1 to nbmodels do tabsig.(m)<- sqrt (tabsig.(m)/.(float nbb)) done;
      let fichrecap=open_out (outdir^"/"^filename^"_recap.csv") in
      let fichfitness=open_out (outdir^"/"^filename^"_fitness.csv") in
      let fichdij=open_out (outdir^"/"^filename^"_Dij.csv") in
      let fichpar=open_out (outdir^"/"^filename^"_parents.csv") in
      Printf.fprintf fichrecap "model,nombre,min,max,moy,ecart-type\n";
      for m=1 to nbmodels do
        Printf.fprintf fichrecap "%d,%d,%f,%f,%f,%f\n" m nbb tabmin.(m) tabmax.(m) tabmoy.(m) tabsig.(m) 
      done;
      close_out fichrecap;
      for m=1 to nbmodels do
        Printf.fprintf fichfitness "fitness_modele_%d," m;
        Array.iter (fun x -> Printf.fprintf fichfitness "%f," x) tabf.(m);
        Printf.fprintf fichfitness "\n";
      done;
      Printf.fprintf fichfitness  "nb_de_dij_non_nuls,";
      Array.iter (fun x -> Printf.fprintf fichfitness "%d," x) tabnz;
      Printf.fprintf fichfitness "\n";
      Printf.fprintf fichfitness "nb_de_parents_utilises,";
      Array.iter (fun x -> Printf.fprintf fichfitness "%d," x) tabnpu;
      Printf.fprintf fichfitness "\n";
      Printf.fprintf fichfitness "nb_de_dij_non_nuls_au_minimum,";
      Array.iter (fun x -> Printf.fprintf fichfitness "%d," x) tabni;
      Printf.fprintf fichfitness "\n";
      Printf.fprintf fichfitness "nb_de_dij_non_nuls_au_maximum,";
      Array.iter (fun x -> Printf.fprintf fichfitness "%d," x) tabna;
      Printf.fprintf fichfitness "\n";
      close_out fichfitness;
      (*        Printf.fprintf fich "dij,P1,P2\n"; *)
      Array.iteri
        (fun i t->
          Printf.fprintf fichdij "%d," i;
          let p1,p2= parents.(i) in
          Printf.fprintf fichdij "%s,%s," p1 p2;
          Array.iter (fun x -> Printf.fprintf fichdij "%d," x) t;
          Printf.fprintf fichdij "\n") tabx;
      close_out fichdij;
      Array.iteri
        (fun i t->
          Printf.fprintf fichpar "%s,%s," "nb appel_parent" tabnamepar.(i);
          Array.iter (fun x -> Printf.fprintf fichpar "%d," x) t;
          Printf.fprintf fichpar "\n") tabpar;
      close_out fichpar
    end
  
let after_share _u numgen pop clus = 
  if gvars.sharing>0. && numgen mod freq=0 then
    begin
      let nbbest=20 in
      Printf.printf "nbclus=%d optima=%d\n" clus.clusters clus.optima;
      printfileshare numgen pop clus.protected freq 0.
        ("resshare_"^(string_of_int model)^"_"^(string_of_int nbbest)^"best") nbbest;
      printfileshare numgen pop clus.protected freq 0. ("resshare_"^(string_of_int model)^"_all") max_int
    end

let after_shareNOPRINT _u numgen _pop clus = 
  if gvars.sharing>0. && numgen mod freq=0 then
    begin
      Printf.printf "nbclus=%d optima=%d\n" clus.clusters clus.optima;
    end
  
let after_reproduce _u _numgen _pop _prot = ()
                                        
let after_gen _u _numgen _pop = ()
                           
let terminate_ag _u _pop _best_elems _nb_done =
  ()

end
         
module M = Ga_optimize.Make(L);;

let start_ag  = M.opti () ;;


