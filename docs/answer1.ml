let pi = 4.0 *. (atan 1.0);;

(* Q1 *)
let area_of_circle radius =
  0.0;;

(* Q2 *)
let radius_of_circle area =
  0.0;;

(* Q3 *)
let circle_areas radii =
  [];;

(* Q4 *)
type number = Int of int | Float of float | Error;;
type sign = Positive | Negative;;

let sign_int n =
  if n >= 0 then Positive
  else Negative;;

let div_num n1 n2 =
  Error;;

(* Note: div_num (Int 4) (Int 2) should give (Int 2) rather than (Float 2.0) *)

(* Q5 *)

type mutable_point = { mutable x: float; mutable y: float };;

let rotate p theta =
  { x = 0.0; y = 0.0 };;
