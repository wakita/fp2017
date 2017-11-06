(* FP-style function application *)

let a = 3 in
let b = 4 in
let rec f x y =
  a * x + b * y in
Printf.printf "%d\n" (f 5 6);;

(* C-style emulation using the closure technique *)

(* Application of a function closure that takes
 *  - two arguments explicitly passed as function parameters (arg1, arg2) and
 *  - two arguments that correspond to free variables.  They are saved in the closure structure at the function calling site
 **)
let apply_2arg_2fv arg1 arg2 closure =
  let a_function_implementation, (fv1, fv2) = closure in
  a_function_implementation arg1 arg2 fv1 fv2 in

let rec f_implementation x y a b =
  a * x + b * y in

let a = 3 in
let b = 4 in
let closure = (f_implementation, (a, b)) in
Printf.printf "%d\n" (apply_2arg_2fv 5 6 closure)
