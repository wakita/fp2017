---
title: "K-Normalization and Alpha Conversion"
date: "Oct. 23, 2017"
---

# Overview

## Compiler Pipeline

~~~ {.ocaml}
let lexbuf outchan l =
  Emit.f outchan
    (RegAlloc.f
       (Simm.f
          (Virtual.f
             (Closure.f
                (iter !limit
                   (Alpha.f
                      (KNormal.f
                         (Typing.f
                            (Parser.exp Lexer.token l)))))))))
~~~

## Compiler Pipeline

~~~ {.ocaml}
let lexbuf outchan l =
  ...... .......
    (..........
       (......
          (.........
             (.........
                (.... !.....
                   (Alpha.f
                      (KNormal.f
                         (........
                            (.......... ........... .)))))))))
~~~

## Additions to `.ocamlinit`

~~~ {.ocaml}
let compose f g x = (* Function composition *)
  f (g x)

let fib_p   = "let rec fib n = if n < 2 then 1 else fib (n - 1) + fib (n - 1) in print(fib 5)"

let knf_p   = "print(1 + 2 + 3)"
let if_p    = "print(if 1 > 0 then 1 else 0)"

let alpha_p = "print(let x = 1 in let x = 2 in x)"

let lex     = Lexing.from_string
let ast     = compose (Parser.exp Lexer.token) Lexing.from_string
let typing  = compose Typing.f ast
let knf     = compose KNormal.f typing
let alpha   = compose Alpha.f knf
~~~

# K-Normalization

## The Syntax of KNF

![](/fp2017/mincaml/overview/knf.png)

## The Syntax of AST

![](/fp2017/mincaml/overview/ast.png)

## Differences

- Eliminattion of Nested Expressions
    - Expression → variable reference
    - Primitive operation
    - The condition part of the `if` expression
    - Function application: both the functional and arguments parts
    - Tuple constructor
    - Array constructor/modifier

- Boolean constants: false/true → 0/1

- Only two types of comparison: $=$ and $\le$

## Example: `1 + 2 + 3`

### Typed abstract syntax tree (AST)
~~~ {.ocaml}
# typing "print(1 + 2 + 3)";;
- : Syntax.t =
App (Syntax.Var "print",
 [Add (Add (Syntax.Int 1, Syntax.Int 2), Syntax.Int 3)])
~~~

### Informally
~~~ {.ocaml}
Add (Add (Int 1, Int 2), Int 3)

(* or in OCaml *)
(1 + 2) + 3
~~~

## Example: `1 + 2 + 3`, continued

### K-Normal Form
~~~ {.ocaml}
# knf "print(1 + 2 + 3)";;
- : KNormal.t =
KNormal.Let (("Ti15", Int),
 KNormal.Let (("Ti13", Int),
  KNormal.Let (("Ti11", Int), KNormal.Int 1,
   KNormal.Let (("Ti12", Int), KNormal.Int 2, KNormal.Add ("Ti11", "Ti12"))),
  KNormal.Let (("Ti14", Int), KNormal.Int 3, KNormal.Add ("Ti13", "Ti14"))),
 ExtFunApp ("print", ["Ti15"]))
~~~

### Informally
~~~ {.ocaml}
(* Type annotations are stripped and "Ti#" => Ti *)
Let(Ti5, Let(Ti3, Let (Ti1, Int 1, Let (Ti2, Int 2, Add(Ti1, Ti2))),
         Let (Ti4, Int 3, Add(Ti3, Ti4))))

(* or in OCaml *)
let t5 =
  let t3 =
    let t1 = 1 in 
    let t2 = 2 in
    t1 + t2 in
let t4 = 3 in t3 + t4
~~~

## Example: `if 1 > 0 then 1 else 0`

### Typed abstract syntax tree (AST)
~~~ {.ocaml}
# typing "print(if 1 > 0 then 1 else 0)";;
- : Syntax.t =
App (Syntax.Var "print",
 [If (Not (LE (Syntax.Int 1, Syntax.Int 0)), Syntax.Int 1, Syntax.Int 0)])
~~~

### Informally
~~~ {.ocaml}
 If (Not (LE (Syntax.Int 1, Syntax.Int 0)), Syntax.Int 1, Syntax.Int 0)

(* or in OCaml *)
if not (1 <= 0) then 1 else 0
~~~

## Example: `if x > y then x else y`, continued

### K-Normal Form
~~~ {.ocaml}
# knf "print(if x > y then x else y)";;
- : KNormal.t =
KNormal.Let (("Ti3", Int),
 KNormal.Let (("Ti1", Int), KNormal.Int 1,
  KNormal.Let (("Ti2", Int), KNormal.Int 0,
   IfLE ("Ti1", "Ti2", KNormal.Int 0, KNormal.Int 1))),
 ExtFunApp ("print", ["Ti3"]))
~~~

### Informally
~~~ {.ocaml}
Let (t3,
 Let (t1, 1,
  Let (t2, 0,
   IfLE (t1, t2, 0, 1))),
 ...)

(* or in OCaml *)
let t3 =
  let t1 = 1 in
  let t2 = 0 in
  If t1 < t2 then 0 else 1 in
...
~~~

## Implementation (1/2)

![](/fp2017/mincaml/overview/knf1.png)

- Optimization: `not` elimination
- Conversion of comparison to `if`
- `if`-conversion with comparison with `false` (*reason why*)

## Implementation (2/2)

![](/fp2017/mincaml/overview/knf2.png)

Series of simple conversion rules.

# Alpha Conversion

## Alpha Conversion

Unique naming scheme

![](/fp2017/mincaml/overview/alpha.png)

## Example: `let x = 1 in let x = 2 in x`

### K-Normal Form
~~~ {.ocaml}
# knf "print(let x = 1 in let x = 2 in x)"
- : KNormal.t =
KNormal.Let (("Ti1", Int),
 KNormal.Let (("x", Int), KNormal.Int 1,
  KNormal.Let (("x", Int), KNormal.Int 2, KNormal.Var "x")),
 ...
~~~

### Informally
~~~ {.ocaml}
Let (t1,
 Let (x, 1,
  Let (x, 2, x)),
 ...
~~~


## Example: `let x = 1 in let x = 2 in x`, continued

### Alpha conversion
~~~ {.ocaml}
# alpha "print(let x = 1 in let x = 2 in x)"
- : KNormal.t =
KNormal.Let (("Ti2.3", Int),
 KNormal.Let (("x.4", Int), KNormal.Int 1,
  KNormal.Let (("x.5", Int), KNormal.Int 2, KNormal.Var "x.5")),
 ...)
~~~

### Informally
~~~ {.ocaml}
Let (t2_3,
 Let (x_4, 1,
  Let (x_5, 2, x_5),
 ...)
~~~

- Outer and inner `x` are renamed to `x_4` and `x_5`, respectively.

## Alpha Conversion

Unique naming scheme

![](/fp2017/mincaml/overview/alpha.png)

## Implementation

~~~ {.ocaml}
let rec g env = function (* alpha conversion *)
  | ...
  | FAdd(x, y) -> FAdd(find x env, find y env)
  | Let((x, t), e1, e2) ->
      let x' = Id.genid x in
      Let((x', t), g env e1, g (M.add x x' env) e2)
  | Var(x) -> Var(find x env)
  | LetRec({ name = (x, t); args = yts; body = e1 }, e2) ->
      let env = M.add x (Id.genid x) env in
      let ys = List.map fst yts in
      let env' = M.add_list2 ys (List.map Id.genid ys) env in
      LetRec({ name = (find x env, t);
               args = List.map (fun (y, t) -> (find y env', t)) yts;
               body = g env' e1 },
             g env e2)
  | ...
  | LetTuple(xts, y, e) ->
      let xs = List.map fst xts in
      let env' = M.add_list2 xs (List.map Id.genid xs) env in
      LetTuple(List.map (fun (x, t) -> (find x env', t)) xts,
               find y env,
               g env' e)
  | ...
~~~

# Next Day: Optimizations
