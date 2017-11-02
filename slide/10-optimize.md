---
title: "Optimization"
date: "Nov. 1, 2017"
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

# Constant Folding

## Constant Folding Format

$$\begin {align}
{\cal F}&: \text {KNormal.t M.t} \rightarrow \text {KNormal.t} \rightarrow \text {KNormal.t} \\
\varepsilon&: v \mapsto c \\
{\cal F}_\varepsilon(e) &= e'
\end {align}$$

## Contant Folding Examples

$$\begin {align}
{\cal F}_\varepsilon(1 + 2) &\Rightarrow 3 \\
\text {let } x = 5 \text { in } x + x &\Rightarrow 10 \\
{\cal F} \varepsilon(\text {if } x = y \text { then } e_1 \text { else } e_2) &\Rightarrow
  {\cal F}_\varepsilon(e_1)\quad \varepsilon(x) \equiv \varepsilon(y) \\
\end {align}$$

## Simple CF

~~~ {.ocaml}
let constfold_p =
  "print(let x = 1 in let y = 2 in if y - 1 = x then x + y else y)"
~~~

~~~ {.ocaml}
# constfold constfold_p;;
Let (Ti11.12,
 Let (x.13, 1, Let (y.14, 2,
   Let (Ti10.15, Let (Ti9.16, 1, 1),
    IfEq (Ti10.15, x.13, 3, 2)))), ...)
~~~

## Let-Assoc + CF

~~~ {.ocaml}
# ConstFold.f (assoc constfold_p);;
Let (x.45, 1,
 Let (y.46, 2,
  Let (Ti41.48, 1,
   Let (Ti42.47, 1,
    Let (Ti43.44, 3, ...)))))
~~~

## The Essense of Constant Folding

$$\begin {align}
{\cal F}_\varepsilon(\text {let } x = e_1 \text { in } e_2) &=
  \text {let } x = {\cal F}_\varepsilon(e_1) \text { in } {\cal F}_{\varepsilon'}(e_2) \\
  & \text {where } \varepsilon' = {\varepsilon, x \mapsto {\cal F}_\varepsilon(e_1)} \\
& \\
{\cal F}_\varepsilon(\mathit {op}(x_1,\ldots,x_n)) &=
  c \quad \text {if } \mathit {op}(\varepsilon(x_1), \ldots, \varepsilon(x_n)) = c
\end {align}$$

## Implementation of Constant Folding

# Elimination of Redundant Definitions

## RDE Format

### Elimination

$$\begin {align}
\varepsilon &: \text {KNormal.t} \rightarrow \text {KNormal.t} \\
\varepsilon(e) &= e' \\
\end {align}$$

### Effect System (Detection of side effects)

$$\begin {align}
\mathit {effect} &: \text {KNormal.t} \rightarrow \text {bool} \\
\mathit {effect} &: e \mapsto \text {true/false} \\
\mathit {effect}(1) &= \text {false} \\
\mathit {effect}(\text {println(1)}) &= \text {true} \\
\mathit {effect}(\text {array.(0) <- 0}) &= \text {true}
\end {align}$$

## RDE Examples (Unused Variable)

$$\begin {align}
\varepsilon(\text {let x = 1 in 0})
  &\Rightarrow 0 \\
\varepsilon(\text {let x = 1 in x + 1})
  &\Rightarrow \text {let x = 1 in x + 1}
\end {align}$$

## RDE Example (Unused Function)

$$\begin {align}
\varepsilon(\text {let rec f x = 1 in 0})
  &\Rightarrow 0 \\
\varepsilon(\text {let rec f x = x + 1 in f 0})
  &\Rightarrow \text {let f x = x + 1 in f 0}
\end {align}$$

## RDE Examples (Effects of Effects)

$$\begin {align}
\varepsilon(\text {let } x = f() \text { in } 0) &= \ ??? \\
\\
^*\text {case 1} &: \text {f() = 1} \\
^*\text {case 2} &: \text {f() = y} \\
\text {case 3} &: \text {f() = array.(0) <- 0} \quad\text {// Assignment}\\
\text {case 4} &: \text {f() = println("Effect!")} \quad\text {// Input-Output}\\
\end {align}$$

## A Question

Why the `let rec` rule in RDE definition says

$$ \mathit {effect}(\text {let rec } x\ y_1\ \ldots\ y_n = e_1 \text { in } e_2) = \mathit {effect}(e_2)
$$

but not

$$ \mathit {effect}(\text {let rec } x\ y_1\ \ldots\ y_n = e_1 \text { in } e_2) = \mathit {effect}(e_1) \vee \mathit {effect}(e_2)
$$

## Implementation of Side Effect Analysis

~~~ {.ocaml}
let rec effect = function (* detection of side effects *)
  | Let(_, e1, e2) -> effect e1 || effect e2
  | LetRec(_, e)
  | LetTuple(_, _, e) -> effect e
  | IfEq(_, _, e1, e2) | IfLE(_, _, e1, e2) -> effect e1 || effect e2
  | App _ | ExtFunApp _
  | Put _ -> true
  | _ -> false
~~~

- Naming constructs (`Let*`) have no side effects

- Conditionals' side effects are those of their subcomponents

- Function applications have side effects (*conservative decision*)
    - `ExtFunApp`: external function application

- Assignments have side effects

- Others are free of side effects

## Implementation of Redundancy Elimination

For `let`:

$$\begin {align}
  \varepsilon(\text {let } &x = e_1 \text { in } e_2) = \\
& \begin {cases}
  \varepsilon(e_2) &
  \neg \mathit {effect}(\varepsilon(e_1)) \wedge \neg \mathit {effect}(\varepsilon(e_2))\, \wedge\\
  & x \not\in \mathit {free\_variables}(\varepsilon(e_2)) \\
  \text {let } x = \varepsilon(e_1) \text { in } \varepsilon(e_2) & \text {Otherwise}
\end {cases}
\end {align}$$

~~~ {.ocaml}
  | Let((x, t), e1, e2) ->
      let e1' = f e1 in
      let e2' = f e2 in
      if effect e1' || S.mem x (fv e2') then Let((x, t), e1', e2') else e2'
~~~

## Question

Is there a case such as the following?:

$$\mathit {free\_variables}(e_2) \not= \mathit {free\_variables}(\varepsilon(e_2))$$

## Implementation of Redundancy Elimination

For `let rec`:

$$\begin {align}
\varepsilon(&\text {let rec } x\ y_1\ \ldots\ y_n = e_1 \text { in } e_2) = \\
& \begin {cases}
\varepsilon(e_2) &
  \text {When } x \not\in \mathit {free\_variables}(\varepsilon(e_2)) \\
\text {let rec } x\ y_1\ \ldots\ y_n = \varepsilon(e_1) \text { in } \varepsilon(e_2) &
  \text {Otherwise}
\end {cases}
\end {align}$$

~~~ {.ocaml}
  | LetRec({ name = (x, t); args = yts; body = e1 }, e2) ->
      let e2' = f e2 in
      if S.mem x (fv e2') then
        LetRec({ name = (x, t); args = yts; body = f e1 }, e2')
      else e2'
~~~

# Closure Language

## Closure Language

![Closure Language Syntax](/fp2017/mincaml/overview/closure-lang.png)

## Closure Language vs K-Normal Form

- What's gone

    - `let rec`: locally-defined functions

- What's new

    - Top-level function declarations:
    
        $D = \{ L_{\text {fib}}(n)() = \text {if n <= 1 then 1 else fib (n - 1) + fib (n - 2)} \}$

    - *make_closure*

- What's different

    - Function application $\rightarrow$ *apply_closure* and *apply_direct*

## Example

~~~ {.ocaml}
let a = 1 in
let rec incr x = x + a in
incr 5
~~~

~~~ {.ocaml}
Prog ([{name      = (L incr.5, Fun ([Int], Int));
        args      = [x.6];
        formal_fv = [a.4];
        body      = Add (x.6, a.4)}],
 Let (...,
  Let (a.4, 1,
   MakeCls ((incr.5, Fun ([Int], Int)), {entry = L incr.5; actual_fv = [a.4]},
    Let (Ti1.7, 5, AppCls (incr.5, [Ti1.7])))),
  ...)
~~~

# Homework

## Homework

Due date
: Nov 15 (Wed.)

Method of submission
: OCW-i assignment submission system

More detail
: will be announced on the evening of Nov 3 at OCW-i

Answer either (or both) questions and submit your answer as a PDF document.  If you answer both questions the better answer will be chosen for your evaluation.

1. What's $\alpha$-conversion for?  What kind of problems we will see if $\alpha$-conversion were not applied?  Find Min-Caml programs that give incorrect answers in absence of proper $\alpha$-conversion.

1. Are optimization modules interdependent?  Yes, but in what way?  Find a pair of optimization modules $A$ and $B$ such that for a program $P$, $B$ is effective when it is applied after $A$:

    $$^\exists P. B(P) = P \text { but } B(A(P)) \not= A(P)$$
