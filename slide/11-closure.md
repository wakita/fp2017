---
title: "Closure Conversion"
date: "Nov 6, 2017"
---

# Overview

## Compiler Pipeline

~~~ {.ocaml}
let lexbuf outchan l =
  ...... .......
    (..........
       (......
          (.........
             (Closure.f
                (.... !.....
                   (.......
                      (.........
                         (........
                            (.......... ........... .)))))))))
~~~

# Functions and Closures

## FP-style Functions

~~~ {.ocaml}
let a = 3 in
let b = 4 in
let rec f x y =
  a * x + b * y in
Printf.printf "%d\n" (f 5 6);;
~~~

- Assume no optimization is performed

- FP-style function: (e.g., `f`)
    - Parameters: `x` and `y`
    - Free variables: `a` and `b`

- C-like 
    - No free variables

- Problem:
    - How do we emulate FP-style function application in C-like language.

## Closure technique (OCaml version)

~~~ {.ocaml}
let apply_2arg_2fv arg1 arg2 closure =
  let a_function_implementation, (fv1, fv2) = closure in
  a_function_implementation arg1 arg2 fv1 fv2 in

let rec f_implementation x y a b =
  a * x + b * y in

let a = 3 in
let b = 4 in
let closure = (f_implementation, (a, b)) in
Printf.printf "%d\n" (apply_2arg_2fv 5 6 closure)
~~~

## Closure technique (C equivalent)

~~~ {.c}
typedef struct {
  int (*fp)(int, int, int, int);
  int fv1; int fv2; } Closure_II_II_I;

int apply_II_II_I(int v1, int v2, Closure_II_II_I *closure) {
  int (*fp)(int, int, int, int) = closure->fp;
  int fv1 = closure->fv1, fv2 = closure->fv2;
  return fp(v1, v2, fv1, fv2); }
~~~

~~~ {.c}
int f_in_c_style(int x, int y, int a, int b) { return a * x + b * y; }

int main() {
  const int a = 3, b = 4;
  Closure_II_II_I closure_f = { f_in_c_style, a, b };
  printf("%d\n", apply_II_II_I(5, 6, &closure_f)); }
~~~

# Naive Closure Conversion

## The Format of Naive Closure Conversion

$$\begin {align}
{\cal C}&: \text {KNormal.t} \rightarrow \text {Closure.t} \\
{\cal C}(e: \text {KNormal.t}) &= p: \text {Closure.t}
\end {align}$$

## Simply-Minded Conversion (Application site)

$$\begin {align}
{\cal C}(x\ y_1 \ldots y_n) =
\mathit {apply\_closure}(x, y_1, \ldots, y_n)
\end {align}$$

## Simply-Minded Conversion (Definition)

$$\begin {align}
{\cal C}(\text {let rec } &x\ y_1 \ldots y_n = e_1 \text { in } e_2 = \\
& {\cal D} \text { += } \mathtt {L}_x(y_1, \ldots, y_n)(z_1, \ldots, z_m) = e_1'; \\
& \mathit {make\_closure}\ x = (\mathtt {L}_x, (z_1, \ldots, z_m)) \text { in } e_2' \\
& \text {where } e_1' = {\cal C}(e_1), e_2' = {\cal C}(e_2),\\
& \text {and } \{z_1, \ldots, z_m\} = \mathit {FV}(e_1') \setminus \{x, y_1, \ldots, y_n\}
\end {align}$$

# Smarter Closure Conversion

## The Format of Smarter Closure Conversion

$$\begin {align}
{\cal C}&: \text {S.t} \rightarrow \text {KNormal.t} \rightarrow \text {Closure.t} \\
s&: \text {The set of known closed functions} \\
 & \quad \text {(functions that do not see free varialbes} \\
{\cal C}_s(e: \text {KNormal.t}) &= p: \text {Closure.t}
\end {align}$$

## Smarter Conversion (Definition)

$$\begin {align}
{\cal C}_s&(\text {let rec } x\ y_1 \ldots y_n = e_1 \text { in } e_2 = \\
& {\cal D} \text { += } \mathtt {L}_x(y_1, \ldots, y_n)(z_1, \ldots, z_m) = e_1'; \\
& \begin {cases}
\mathit {make\_closure}\ x = (\mathtt {L}_x, ()) \text { in } e_2' \\
\text {where } e_1' = {\cal C}_{s'}(e_1), e_2' = {\cal C}_{s'}(e_2), \\
\text {and } s' = s \cup \{ x \}
& \text {when } \mathit {FV}(e_1') \setminus \{y_1, \ldots, y_n\} = \emptyset \\
\\
\mathit {make\_closure}\ x = (\mathtt {L}_x, (z_1, \ldots, z_m)) \text { in } e_2' \\
\text {where } e_1' = {\cal C}(e_1), e_2' = {\cal C}(e_2),\\
\text {and } \{z_1, \ldots, z_m\} = \mathit {FV}(e_1') \setminus \{x, y_1, \ldots, y_n\}
& \text {otherwise}
\end {cases}
\end {align}$$

## Discussion

The condition of the first case says:
$\mathit {FV}(e_1') \setminus \{y_1, \ldots, y_n\} = \emptyset$

rather than:
$\mathit {FV}(e_1') \setminus \{x, y_1, \ldots, y_n\} = \emptyset$

## Smarter Conversion (Application)

$$\begin {align}
{\cal C}_s(x\ y_1\ldots y_n) &=
\begin {cases}
\mathit {apply\_closure}(x, y_1, \ldots, y_n) & x \not\in s \\
\mathit {apply\_direct}(\mathtt {L}_x, y_1, \ldots, y_n) & s \in s
\end {cases}
\end {align}$$

# Even Smarter Conversion

## Definition

![](/fp2017/mincaml/overview/closure2.png)

- Restraint on closure creation (less of `make_closure`)
