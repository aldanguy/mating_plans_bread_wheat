(*==============================================================================

    A Genetic Algorithm library, written in Objective Caml

    Copyright (C) 2010 Direction Générale de l'Aviation Civile (France)

    Authors: Jean-Marc Alliot, Nicolas Durand, David Gianazza,
             Pascal Brisset, Cyril Allignol

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received, along with this program, a copy of the
    GNU General Public License (GPL) and the GNU Lesser General Public
    License (LGPL), which is a set of  additional permissions on top
    of the GPL. If not, see <http://www.gnu.org/licenses/>.

==============================================================================*)

(* $Id: ga_optimize.ml 3262 2010-11-15 16:43:27Z allignol $ *)

module type LOCAL = sig

  open Ga_types

  type data
  type user_data
  type result

  exception Fin_AG

  val gvars : gvars
  val eval : user_data -> int -> data -> float Lazy.t
  val generate : user_data -> int -> data
  val cross : user_data -> int -> data -> data -> data * data
  val mutate : user_data -> int -> data -> data
  val distance : user_data -> data -> data -> float
  val barycenter : user_data -> data -> int -> data -> int -> data
  val init : user_data -> unit
  val prepare_ag : user_data -> data population -> unit
  val prepare_gen : user_data -> int -> data population -> data population
  val after_scale : user_data -> int -> data population
    -> data chromosome -> unit
  val after_share : user_data -> int -> data population -> sharing -> unit
  val after_reproduce : user_data -> int -> data population -> int list
    -> unit
  val after_gen : user_data -> int -> data population -> unit
  val terminate_ag : user_data -> data population -> int list -> int ->
    result

end

module Make(L : LOCAL) = struct

  open Ga_types

  exception Sortie_boucle of int

  let opti = fun user ->
    L.init user;
    let distance = L.distance user and barycenter = L.barycenter user
    and eval = L.eval user
    and cross = L.cross user and mutate = L.mutate user in
    let pop = Array.init L.gvars.nbelems
	(fun i ->
	  let elt = L.generate user i in
	  {r_fit = eval 0 elt; s_fit = 0.0; data = elt}
	) in
    L.prepare_ag user pop;
    let nb_done = try
      for numgen = 1 to L.gvars.nbgens do
	try
          (*	  Printf.printf "Before prepare\n";flush stdout; *)
      	  let pop= L.prepare_gen user numgen pop in
          (*	  Printf.printf "Before scale\n";flush stdout; *)
      	  let best = Ga_scale.scale numgen pop L.gvars in
          (*	  Printf.printf "Before after_scale\n";flush stdout; *)
      	  L.after_scale user numgen pop best;
          (*	  Printf.printf "Before share\n";flush stdout; *)
      	  let share = Ga_share.share distance barycenter L.gvars pop in
          (*	  Printf.printf "Before after_share\n";flush stdout; *)
      	  L.after_share user numgen pop share;
          (*	  Printf.printf "Before reproduce\n";flush stdout; *)
      	  let newprotected, pool = Ga_reproduce.reproduce pop share.protected in
          (*	  Printf.printf "Before after_reproduce\n";flush stdout; *)
      	  L.after_reproduce user numgen pool newprotected;
          (*	  Printf.printf "Before crossmut\n";flush stdout;*)
      	  Ga_crossmut.crossmut numgen eval cross mutate
			       pool pop newprotected L.gvars;
          (*	  Printf.printf "Before after_gen\n";flush stdout; *)
      	  L.after_gen user numgen pop
	with
	  L.Fin_AG -> raise (Sortie_boucle numgen)
      done;
      L.gvars.nbgens
    with
      Sortie_boucle n -> n in
    let share = Ga_share.share distance barycenter L.gvars pop in
    let best_elems = List.sort
	(fun i j -> -(compare pop.(i).r_fit pop.(j).r_fit))
	share.protected in
    L.terminate_ag user pop best_elems nb_done
end
