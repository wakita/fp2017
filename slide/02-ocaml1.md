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
: `bool`, `char`, `float`, `int`, `string`

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

    - `is_beautiful @ is_beautiful`

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec9)

## Pattern Matching on Lists (1/3)

- To retrieve an element from a list, we use **pattern matching**.

~~~ {.ocaml}
# match [1; 2; 3; 4; 5] with
    a :: rest -> a;;
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
[]
- : int = 1
~~~

## Pattern Matching on Lists (2/3)

- Multiple parts of a list can be retrieved by a pattern match.

- An arbitrary expression is allowed for the result of pattern matching: e.g. `(a + b + c, rest)`.

~~~ {.ocaml}
# match [1; 2; 3; 4; 5] with
    a :: b :: c :: rest -> (a + b + c, rest);;
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
(_::_::[]|_::[]|[])
- : int * int list = (6, [4; 5])
~~~

- This example retrieves four parts `a = 1`, `b = 2`, `c = 3`, `rest = [4, 5]` and computes `a + b + c = 6` and pairs this result with the value of `rest`.

## Pattern Matching on Lists (3/3)

- Why OCaml keeps alerting us with Warning?

- OCaml presents anti-patterns, like `_::_::[]`, `_::[]`, `[]`, for the last example.

- Fix is easy.  Just deal with anti-patterns.

~~~ {.ocaml}
# match [1; 2; 3; 4; 5] with
    a :: rest -> a
  | _ -> raise (Failure("Can't get value out of an empty list."));;
- : int = 1
# match [1; 2; 3; 4; 5] with
    a :: b :: c :: rest -> (a + b + c, rest)
  | _ -> raise (Failure("I don't care about short lists"))
- : int * int list = (6, [4; 5])
~~~

- As you see, a pattern match can contain multiple patterns: e.g., `a :: rest` and `[]` in the first example.

## Recursing on Lists

~~~ {.ocaml}
# let rec last l =
    match l with
      [] -> raise (Failure("Empty list"))
    | [last_element] -> last_element
    | the_head :: the_rest -> last the_rest;;
val last : 'a list -> 'a = <fun>
# last [1; 2; 3; 4; 5];;
- : int = 5
~~~

## Mutually Recursive Definition

- Mutually recursive functions can be collective defined using the `let rec f x = ... and g y = ... and ...` syntax.

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
    - A triple array: `[| 1.0; 2.0; 4.0 |]`

    - A string array: `let beautiful = [| "is"; "beautiful" |]`

Assignent
: - `beautiful.(0) <- "are"`

Retrieval
: - `beautiful.(0)` → `"are"`

## Lists vs Arrays

| | Arrays | Lists |
| --------------------- |----------------------- | ---------------------------------- |
| Elements modification | Mutable | Immutable |
| Size                  | Fixed                  | Can grow with `::` |
| Accessing Elements    | O(1) for every element | O(1) for the head, O(n) in average |


# Other Compound Types

## Functions as values

~~~ {.ocaml}
let deriv f dx =
  function x ->
    (f (x +. dx) -. f x) /. dx;;
~~~

$$\frac {\mathrm {d} f} {\mathrm {d} x} (x)
  = \lim_{\Delta x \rightarrow 0} \frac {f(x + \Delta x) - f(x)} {\Delta x}$$

~~~ {.ocaml}
let compose f g = function x -> f (g x)
let cos2 = compose square cos
~~~

$$(f \circ g)(x) = f(g(x))$$

[manual](https://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html#sec10)

## Partial Application

- In case you feed less values than the function requests, the function returns a partially applied function, which given the rest of the arguments, evalates the body of the function.

~~~ {.ocaml}
# let max a b =
  if a > b then a else b;;
val max : 'a -> 'a -> 'a = <fun>

# max 5 7;;
- : int = 7

# let max5 = max 5;;
val max5 : int -> int = <fun>

# max5 7;;
- : int = 7
~~~

## Functions in OCaml

- The `let f x y z` syntax is a syntax sugar of `function a -> ...`:

    ~~~ {.ocaml}
    let f x y z =
      the_body_of_f

    let f =
      function x ->
        function y ->
          function z ->
            the_body_of_f
    ~~~

- Therefore `f a b` creates the following function:

    ``` {.ocaml}
    let x = a and y = b in
    function z -> the_body_of_f
    ```

## Usage of `deriv`

~~~ {.ocaml}
# let sin' = deriv sin 1e-8;;
val sin' : float -> float = <fun>

# sin' pi;;
- : float = -0.999999993922529

# sin' (pi /. 3.0);;
- : float = 0.499999996961264515
~~~

# [Assignment](/fp2017/page/assignment1.html)<br/>Click! ↑

