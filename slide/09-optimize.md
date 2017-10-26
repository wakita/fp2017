---
title: "Optimization"
date: "Oct. 25, 2017"
---

# Overview

## Compiler Pipeline

~~~ {.ocaml}
let rec iter n e = (* Iterative optimization *)
  if n = 0 then e else
  let e' = Elim.f (ConstFold.f (Inline.f (Assoc.f (Beta.f e)))) in
  if e = e' then e else
  iter (n - 1) e'

let lexbuf outchan l =
  ...... .......
    (..........
       (......
          (.........
             (.........
                (iter !limit
                   (.......
                      (.........
                         (........
                            (.......... ........... .)))))))))
~~~

# Beta Reduction

## Beta reduction

![](/fp2017/mincaml/overview/beta.png)

## The essence of Beta reduction

$$
\beta_\varepsilon(\text {let } x =  e_1 \text { in } e_2) =
\begin {cases}
  \beta_{\color {red} {\varepsilon, x \mapsto y}}(e_2) & \beta_\varepsilon(e_1) \text { is a variable (y)}\\
  \text {let } x = \beta_\varepsilon(e_1) \text { in } \beta_\varepsilon(e_2)  & \text {Otherwise}
\end {cases}
$$

When a `let` expression is an alias/renaming ($x \mapsto y$), the `let` is removed and occurrences of $x$ in $e_2$ are substituted by $y$.

## Implementation

`Beta.g : (Id.t M.t) -> KNormal.t -> KNormal.t`

~~~ {.ocaml}
  | Let((x, t), e1, e2) -> (* Beta-reduction of `let` expressions *)
      (match g env e1 with
      | Var(y) ->
          Format.eprintf "beta-reducing %s = %s@." x y;
          g (M.add x y env) e2
      | e1' ->
          let e2' = g env e2 in
          Let((x, t), e1', e2'))
~~~

$$
\beta_\varepsilon(\text {let } x =  e_1 \text { in } e_2) =
\begin {cases}
  \beta_{\varepsilon, x \mapsto y}(e_2) & \beta_\varepsilon(e_1) \text { is a variable (y)}\\
  \text {let } x = \beta_\varepsilon(e_1) \text { in } \beta_\varepsilon(e_2)  & \text {Otherwise}
\end {cases}
$$

## Example

~~~ {.ocaml}
# beta_p
let x = 1 in
let y = x in
x + y
~~~

~~~ {.ocaml}
# alpha beta_p
Let (Ti5_6,
 Let (x_7, 1,
  Let (y_8, x_7, Add(x_7, y_8))), ...)
~~~

~~~ {.ocaml}
# beta beta_p
Let (Ti1_2,
 Let (x_3, 1, Add(x_3, x_3)), ...)
~~~

# Let Reduction based on Associativity

## Let Reduction based on Associativity

![](/fp2017/mincaml/overview/assoc.png)

## The essence of Let Reduction

$$
{\cal A}(\text {let } x = e_1 \text { in } e_2) =
\text {let ... in let } x = e_1' in {\cal A}(e_2)
$$

${\cal A}(e_1)$ is a nested `let` form ($\text {let ... in } e'$, where $\text {let ... }$ is a sequence of one or more `let`'s), and $e_1'$ is not a `let` form.

## Implementation

~~~ {.ocaml}
  | Let(xt, e1, e2) -> insert (f e1)
~~~

where

~~~ {.ocaml}
let rec insert = function
| Let(yt, e3, e4) -> Let(yt, e3, insert e4)
| LetRec(fundefs, e) -> LetRec(fundefs, insert e)
| LetTuple(yts, z, e) -> LetTuple(yts, z, insert e)
| e -> Let(xt, e, f e2) in
~~~

## Example ("let" case)

~~~ {.ocaml}
(* assoc_let_p*)
let x =
  let y = 1 in
  let z = 2 in
  y + z in
x
~~~

~~~ {.ocaml}
(* alpha assoc_let_p *)
Let (Ti1_2,
 Let (x_3,
  Let (y_4, 1,
   Let (z_5, 2, Add (y_4, z_5))),
  x.3), ...)
~~~

~~~ {.ocaml}
(* assoc assoc_let_p *)
Let (y_9, 1,
 Let (z_10, 2,
  Let (x_8, Add (y_9, z_10),
   Let (Ti6_7, x_8, ...))))
~~~

## Example ("let rec" case)

~~~ {.ocaml}
(* assoc_letrec_p *)
let x =
  let rec f x = x + 1 in
  f 1 in
x
~~~

~~~ {.ocaml}
(* alpha assoc_letrec_p *)
Let (Ti3_4,
 Let (x_5,
  LetRec
   ({name = f_6; args = [x_7];
     body = Let (Ti2_9, 1, Add (x_7, Ti2_9))},
   Let (Ti1_8, 1, App (f_6, [Ti1_8]))),
  Var x_5), ...)
~~~

~~~ {.ocaml}
(* assoc assoc_letrec_p *)
LetRec
 ({name = f_15; args = [x_16];
   body = Let (Ti11_18, 1, Add (x_16, Ti11_18))},
 Let (Ti10_17, 1,
  Let (x_14, App (f_15, [Ti10_17]),
   Let (Ti12_13, x_14, ...))))
~~~

- A $\beta$-redex appeared in the last line.

## Example ("tuple" case)

~~~ {.ocaml}
let x = (1, 2) in (* assoc_tuple_p *)
let (a, b) = x
in a + b
~~~

~~~ {.ocaml}
Let (Ti3_4, (* alpha assoc_tuple_p *)
 Let (x_5,
  Let (Ti1_8, 1,
   Let (Ti2_9, 2, Tuple [Ti1_8; Ti2_9])),
  LetTuple ([a_6; b_7], x_5, Add (a_6, b_7))), ...)
~~~

~~~ {_ocaml}
Let (Ti10_17, 1, (* assoc assoc_tuple_p *)
 Let (Ti11_18, 2,
  Let (x_14,
   Tuple [Ti10_17; Ti11_18],
   LetTuple ([a_15; b_16], x_14,
    Let (Ti12_13, Add (a_15, b_16), ...)))))
~~~

# Inline Expansion

## Inline Expansion

![](/fp2017/mincaml/overview/inline.png)

## The Essence of Inline Expansion

For a definition of smaller functions:

$$\begin {align}
&{\cal I}_\varepsilon(\text {let rec } x\ y_1 \ldots y_n = e_1 \text { in } e_2) = \\
& \text {let rec } x\ y_1 \ldots y_n =
  {\cal I}_{\color {red}{\varepsilon'}}(e_1) \text { in } {\cal I}_{\color {red}{\varepsilon'}}(e_2) \\
& \text {where } \varepsilon' = \varepsilon, x \mapsto ((y_1, \ldots, y_n), e_1)
  \end {align}$$

# Questions in My Mind

## Questions in My Mind

1. What's $\alpha$-conversion for?  What kind of problems we will see if $\alpha$-conversion were not applied?  Find Min-Caml programs that give incorrect answers in absence of proper $\alpha$-conversion.

1. Are optimization modules interdependent?  Yes, but in what way?  Find a pair of optimization modules $A$ and $B$ such that for a program $P$, $B$ is effective when it is applied after $A$:

    $$^\exists P. B(P) = P \text { but } B(A(P)) \not= A(P)$$

1. and maybe one more, thinking...

<!-- # Constant Folding -->

<!-- # Elimination of Redundant Definitions -->
