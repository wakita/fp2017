---
title: "FP: Day 7<br/>Typing"
date: "Oct. 19, 2017"
---

# Types

## MinCaml Types

![MinCaml Types](/fp2017/mincaml/overview/types.png)

## MinCaml Types as 1st-order terms

![MinCaml Types](/fp2017/mincaml/overview/types.png)

$$\begin{align}
\tau & ::= \\
   | & \, \text {bool | int | float} \\
   | & \, \mathrm {FunctionalType}(\tau_1, \ldots, \tau_n, \tau) \\
   | & \, \mathrm {TupleType}(\tau_1, \ldots, \tau_n) \\
   | & \, \mathrm {ArrayType}(\tau) \\
   | & \, \alpha
\end{align}$$

## Typing Rules for `let`

![Typing Rules for `let`](/fp2017/mincaml/overview/typing-let.png)

Assumptions
: 1. The type of $e_1$ is $\tau_1$

    1. Under a typing environment, where the type of $x$ is $\tau_1$, the type of $e_2$ is $\tau_2$.

Conclusion
: The type of $\texttt {let } x = e_1 \texttt { in } e_2$ is $\tau_2$.

Semtanics of `let`
: The `let` form binds a name locally.  It introduces a varible $x$ whose value is the evaluation results of $e_1$.  The scope of $x$ is $e_2$ ($x$ is visible inside $e_2$).

## Typing `let x = 1 in x * 2`

1. $\Gamma, x:\text {int} \vdash x:\text {int}$ because $\Gamma, x: \text {int}(x) = \text {int}$.

1. $\Gamma, x:\text {int} \vdash 2: \text {int}$ because 2 is an integer constant.

1. $\Gamma, x:\text {int} \vdash \texttt {x * 2}: \text {int}$ because $\texttt *: \text {int} \times \text {int} \rightarrow \text {int}$.

1. $\Gamma \vdash 1:\text {int}$ because 1 is an integer constant.

1. $\Gamma \vdash \texttt {let x = 1 in x * 2}: \text {int}$, from the last two statements and the typing rule for *let*.

## Typing Rules for `let rec`

![Typing Rules for `let rec`](/fp2017/mincaml/overview/typing-letrec.png)

Assumptions
: 1. Under a typing environment where $x$ is a function whose type is $\tau_1 \rightarrow \ldots \tau_n \rightarrow \tau$ and the types of $y_1, \ldots, y_n$ are $\tau_1, \ldots, \tau_n$, respectively, the type of $e_1$ is $\tau$. (When the types of virtual and real arguments match the function's result type and body's type should be the same.)

    1. Under a typing environment where $x$ is a function whose type is $\tau_1 \rightarrow \ldots \tau_n \rightarrow \tau$, the type of $e_2$ is $\tau'$.

Conclusion
: The type of $\texttt {let rec } x\ y_1 \ldots y_n = e_1 \texttt { in } e_2$ is $\tau'$.

## Typing Rule for Function Application

![Typing Rules for `let rec`](/fp2017/mincaml/overview/typing-letrec.png)

Assumptions
: 1. A function $e$ takes $n$ arguments and their types are $\tau_1, \ldots \tau_n$.

    1. The types of $e_1, \ldots e_n$ are $\tau_1, \ldots, \tau_n$, respectively.
    
    These two assumption demand that the types of the formal argument and the actual arguments match.

Conclusion
: The result type of a function application $e\ e_1 \ldots e_n$ is $\tau$.

# Implementation of Typing

## `Typing.deref_...`

A series of function that replaces occurrences of type variable by its contents

`Typing.deref_typ`
: Dereferencing of type variables for `Type.t`.  The essencial code is:

    ~~~ {.ocaml}
    let rec deref_typ = function
      ...

      | Type.Var({ contents = Some(t) } as r) ->
      let t' = deref_typ t in
      r := Some(t');
      t'

      ...
    ~~~

    Other code recursively applies `deref_*` to the subcomponents.

## `occur r t`

Checks if a type varible `r` occurs in a type expression `t`.

~~~ {.ocaml}
  | Type.Var(r2) when r1 == r2        -> true
  | Type.Var({ contents = None })     -> false
  | Type.Var({ contents = Some(t2) }) -> occur r1 t2
~~~

## `unify t1 t2`

- `unify t1 t2` attempts unification on type variables to `t1` and `t2`.  Instead of computing substitution, type variables are replaced by substitution.  This is one of rare cases of using side effects throughout implementation of the MinCaml compiler.

    ~~~ {.ocaml}
    | Type.Var({ contents = None } as r1), _ -> (* t1 is an undefined type variable *)
      if occur r1 t2 then raise (Unify(t1, t2));
      r1 := Some(t2)
    | _, Type.Var({ contents = None } as r2) -> (* t2 is an undefined type variable *)
      if occur r2 t1 then raise (Unify(t1, t2));
      r2 := Some(t1)
    ~~~

- The structure of the `unify` function reflects the typing structure, namely `Type.t`.

- If it fails to unify `t1` and `t2`, it raises an exception: `raise (Unify(t1, t2))`.

## `g env e`

`g env e` examine the structure of `e`, identifies the typing rule related with that structure, then attempts to unify the assumptions and conclusions of the typing rule with the corresponding structure of `e`'s type.
