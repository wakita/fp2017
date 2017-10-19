---
title: "Quiz (October 19)<br/>ID:<br/>Name:"
---

---

# Definitions

Explanations in this section are picked up from your reading assignment on "Unification (Computer Science)" page of Wikipedia.  They are provided for your convenience.  You do not have to read them to solve the questions that appear in the next section.

## First-order terms

Given a set $V$ of *variable symbols*, a set $C$ of *constant symbols* and sets $F_n$ of $n$-ary *function symbols*, also called operator symbols, for each natural number $n \ge 1$, the set of (unsorted first-order) *terms* $T$ is recursively defined to be the smallest set with the following properties:

- every variable symbol is a term: $V \subseteq T$,
- every constant symbol is a term: $C \subseteq T$,
- from every $n$ terms $t_1, \ldots, t_n$, and every $n$-ary function symbol $f \in F_n$, a larger term $f(t_1, \ldots,t_n)$ can be built.

## Substitution

A *substitution* is a mapping $\sigma: V \rightarrow T$ from variables to terms; the notation $\{ x_1 \mapsto t_1, \ldots, x_k \mapsto t_k \}$ refers to a substitution mapping each variable $x_i$ to the term $t_i$, for $i=1, \ldots, k$, and every other variable to itself. *Applying* that substitution to a term $t$ is written in postfix notation as $t \{x_1 \mapsto t_1, \ldots, x_k \mapsto t_k \}$; it means to (simultaneously) replace every occurrence of each variable $x_i$ in the term $t$ by $t_i$. The result $t\sigma$ of applying a substitution $\sigma$ to a term $t$ is called an *instance* of that term $t$.

## Generalization, specialization

If a term $t$ has an instance equivalent to a term $u$, that is, if $t\sigma \equiv u$ for some substitution $\sigma$, then $t$ is called *more general* than $u$, and $u$ is called *more special* than, or *subsumed* by, $t$.

A substitution $\sigma$ is *more special*, or *subsumed* by, than a substitution $\tau$ if $t\sigma$ is more special than $t\tau$ for each term $t$. We also say that $\tau$ is more general than $\sigma$.

## Unification problem, solution set

A *unification problem* is a finite set $\{ l_1 \doteq r_1, \ldots, l_n \doteq r_n \}$ of potential equations, where $l_i, r_i \in T$. A substitution $\sigma$ is a *solution* of that problem if $l_i\sigma \equiv r_i\sigma$ for $i=1, \ldots, n$. Such a substitution is also called a *unifier* of the unification problem. For example, if $\oplus$ is associative, the unification problem $\{ x \oplus a \doteq a \oplus x \}$ has the solutions $\{x \mapsto a\}$, $\{x \mapsto a \oplus a\}$, $\{x \mapsto a \oplus a \oplus a\}$, etc., while the problem $\{ x \oplus a \doteq a \}$ has no solution.

For a given unification problem, a set $S$ of unifiers is called *complete* if each solution substitution is subsumed by some substitution $\sigma \in S$; the set $S$ is called *minimal* if none of its members subsumes another one.

# Questions

In the following $a, b, c, d$ are used as constant symbols, $x, y, z, w$ as variable symbols, and $f, g, h$ as function symbols.

In the following, we assume $\equiv$ is literal (syntactic) identity of terms.

## Q1 (First-order terms)

Choose first-order terms.

| | | | |
| :------ | :----- | :----- | :----- |
| □ $()$  | □ $a, x$  | □ $f(a)$ | □ $f(a, g(x, b))$ |

## Q2 (Substitution)

Compute the result of the following substitutions

- $x \{ x \mapsto a \}$

- $f(x, y) \{ y \mapsto x, x \mapsto y \}$

## Q3 (Generalization, specialization)

For each pair of first-order terms $t$ and $u$, examine if one $t$ is more general than $u$.  If it is, find an appropriate substitution $\sigma$ and answer $t\sigma = u$.  If it is not answer "No".

- $t = a, u = b$

- $t = x, u = y$

- $t = x, u = g(y)$

## Q4 (Unification problem)

For each unification problem find a solution $\sigma$.  If the unification problem is not solvable, answer "No solution".

- $\{ x \doteq a, x \doteq b \}$

- $\{ f(x, x) \doteq f(y, g(a)) \}$

- $\{ f(a, x) \doteq f(x, g(a)) \}$
