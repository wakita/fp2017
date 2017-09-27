---
title: "FP: Day 2<br/>Introduction to OCaml 1"
date: "Sep. 28, 2017"
---

# Basics

## Basics --- Interaction

- The prompt: `#`

- The termination mark: `;;`

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec8)

## Basics --- Definitions

Constants and functions are defined by `let`

~~~ {.ocaml}
let pi = 4.0 *. atan 1.0

let square x = x *. x
~~~

Recursive functions are defined by `let rec` (e.g., `fib`)

~~~ {.ocaml}
let rec fib n =
  if n < 2 then n
  else fib (n-1) + fib (n-2)
~~~
    
# Primitive Types and Collections

## Primitive Data Types

Primitive data types
: `bool`, `char`, `float`, `int`, `string`, `int`

Attentions
: - `1` and `1.0` are different
    - `+` vs `+.` are different.
    
        So are `-` vs `-.`, `*` vs `*.`, and `/` vs `/.`.

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec9)

## Lists

List values
: - `[]`, `[a; b; c]`

    - `let is_beautiful = ["is"; "beautiful"]`

    - `"Life" :: is_beautiful`

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec9)

## Pattern Matching on Lists

~~~ {.ocaml}
let rec sort lst =
  match lst with
      [] -> []
    | head :: tail -> insert head (sort tail)
and insert elt lst =
  match lst with
      [] -> [elt]
    | head :: tail ->
        if elt <= head then elt :: lst
        else head :: insert elt tail
~~~

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec9)

## Type Variable

~~~ {.ocaml}
val sort : 'a list -> 'a list = <fun>
val insert : 'a -> 'a list -> 'a list = <fun>
~~~

~~~ {.ocaml}
# sort is_beautiful;;
- : string list = ["beautiful"; "is"]
~~~

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec9)


## Tuples

A touple can group together values of different types.

~~~ {.ocaml}
# let data = ('I', "have", 2, "apples");;
val data : char * string * int * string = ('I', "have", 2, "apples")
~~~

Use pattern matching to retrieve elements from the tuple:

~~~ {.ocaml}
# match data with (_, _, n, thing) -> (n, thing);;
- : int * string = (2, "apples")
~~~

`_`
: don't care (or wildcard) symbol

## Arrays

Array values
: - An empty array: `[| |]`
    - A triple array: `[| 1.0, 2.0, 4.0 |]`

    - A string array: `let beautiful = [| "is"; "beautiful" |]`

Assignent
: - `beautifule.(0) <- "are"`

Retrieval
: - `beautiful.(0)` → `"are"`

# Other Compound Types

## Functions as values

~~~ {.ocaml}
let deriv f dx =
  function x ->
    (f (x +. dx) -. f x) /. dx
~~~

$$\frac {\partial f} {\partial x} (x)
  = \lim_{\Delta x \rightarrow 0} \frac {f(x + \Delta x) - f(x)} {\Delta x}$$

~~~ {.ocaml}
let compose f g = function x -> f (g x)
let cos2 = compose square cos
~~~

$$(f \circ g)(x) = f(g(x))$$

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec10)

## Records

Record type declaration

~~~ {.ocaml}
type ratio = {num: int; denom: int}
~~~

Data construction

~~~ {.ocaml}
let r = {num = 12; denom = 15}
~~~

Field retrieval

~~~ {.ocaml}
r.num
~~~

Note
: Define a function named normalize that takes a rational number of type ratio and gives its normalized form.  The normalized form of a rational number whose elements is minimized and the sign of the denominator is positive.

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec11)

## Variants

~~~ {.ocaml}
type sign = Positive | Negative;;

let sign_int n =
  if n >= 0 then Positive
  else Negative;;
~~~

- `sign` is either `Positive` or `Negative`

- *Variants* are sometimes called *tagged union*.

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec11)

## Variants and Recursive Data Types

~~~ {.ocaml}
type 'a btree =
  Empty
| Node of 'a * 'a btree * 'a btree;;
~~~

- 

# [Assignment](/fp2017/assignment1.html)<br/>Click! ↑

# Back to [Top](/fp2017/)
