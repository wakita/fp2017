---
title: "FP: Day 4<br/>OCaml Compiler"
date: "Oct. 5, 2017"
---

# The OCaml library

## Popular modules in `min-caml` implementation

- [Core (Pervasives)](https://caml.inria.fr/pub/docs/manual-ocaml/core.html) (Plenty)

- [Pervasives: The default module](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Pervasives.html)

- [List](https://caml.inria.fr/pub/docs/manual-ocaml/libref/List.html) (16) --- list operations

- [Format](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Format.html) (10) / [Printf](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Printf.html) (4) --- pretty printing

- [Str](https://caml.inria.fr/pub/docs/manual-ocaml/libstr.html) (5) --- regular expression

- [Arg](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Arg.html) (3) --- parsing of command line arguments

## Popular functions in `min-caml` implementation

- [`Format`](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Format.html) module: eprintf (10)

- [`Printf`](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Printf.html) module: sprintf (3) / printf

- [`List`](https://caml.inria.fr/pub/docs/manual-ocaml/libref/List.html) module: map (6) / fold_left2 (2) / fold_left (2) / tl / length / iter2 / iter / hd / exists

- [`Str`](https://caml.inria.fr/pub/docs/manual-ocaml/libstr.html) module: matched_group (2) / search_forward / regexp / global_replace

- [`Arg`](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Arg.html) module: Int (2), parse

- [`Set`](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Set.html) module: Make (1)

## Some examples (`List.map`)

~~~ {.ocaml}
# List.map string_of_int [1; 2; 3]
- : string list = ["1"; "2"; "3"]

# List.map (function n -> Array.make n 3) [3; 4; 5];;
- : int array list = [[|3; 3; 3|]; [|3; 3; 3; 3|]; [|3; 3; 3; 3; 3|]]
~~~

## Some examples (`List.fold_left`)

~~~ {.ocaml}
# List.fold_left (fun a x -> a + x) 0 [2; 3; 5; 7; 11]  (* sum *);;
- : int = 28

# List.fold_left (fun a x -> a * x) 1 [2; 3; 5; 7; 11]  (* product *);;
- : int = 2310

# List.fold_left (fun l x -> List.map (function l -> x :: l) ([] :: l))
    [] [2; 3; 5; 7; 11];;    
- : int list list = [[11]; [11; 7]; [11; 7; 5]; [11; 7; 5; 3]; [11; 7; 5; 3; 2]]
  (* suffices of a list *)
~~~

# The OCaml tools

## Native-code compiler (`ocamlopt`)

- [documentation](https://caml.inria.fr/pub/docs/manual-ocaml/native.html)

~~~ {.ocaml}
(* welcome.ml *)

let print whatever =
  Printf.printf "Welcome to %s!!!\n" whatever
~~~

~~~ {.ocaml}
(* main.ml *)

Welcome.print "OCaml world"
~~~

~~~ {.bash}
ocamlopt -o main welcome.ml main.ml
~~~

## Native-code vs Byte-code compiler performance

Benchmark program

~~~ {.ocaml}
(* Takeuchi's Tarai function *)

let rec t x y z =
  if x <= y then y
  else t (t(x - 1) y z) (t (y - 1) z x) (t (z - 1) x y)

let x, y, z = (14, 7, 0);;
Printf.printf "Takeuchi(%d, %d, %d) = ...%t" x y z flush;
~~~

## Comparison

### ocamlc (byte code compiler)

~~~ {.bash}
$ ocamlc -o tak tak.ml
$ time ./tak
Takeuchi(15, 8, 0) = ... 15
./tak  72.69s user 0.27s system 99% cpu 1:13.56 total
~~~

### ocamlopt (native code compiler)

~~~ {.bash}
$ ocamlopt -o tak tak.ml
$ time ./tak
Takeuchi(15, 8, 0) = ... 15
./tak  6.46s user 0.04s system 98% cpu 6.564 total
~~~

x12 acceleration in ocamlopt!

## Lexer generator (`ocamllex`)

- [documentation](https://caml.inria.fr/pub/docs/manual-ocaml/lexyacc.html#sec296)

## Parser generator (`ocamlyacc`)

- [documentation](https://caml.inria.fr/pub/docs/manual-ocaml/lexyacc.html#sec307)
