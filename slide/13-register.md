---
title: "Register Allocation"
date: "Nov 13, 2017"
---

# Register Allocation

## "Register" Format

$$\newcommand\R{{\cal R}}
\newcommand\r{\mathtt {R}}
\newcommand\eps{{\varepsilon}}
\newcommand\la{{\leftarrow}}
\newcommand\ra{{\rightarrow}}
\newcommand\zdest{{z_{\text {dest}}}}
\newcommand\Econt{{E_{\text {cont}}}}
\newcommand\dom{{\mathit {dom}}}$$

$$\begin {align}
\R^p :& \text {SparcAsm.prog} \rightarrow \text {SparcAsm.prog} \\
\R^f :& \text {SparcAsm.fundef} \rightarrow \text {SparcAsm.fundef} \\
\R^E :& \text {Id.t M.t} \rightarrow
        \text {SparcAsm.t} \times \text {Id.t} \times \text {SparcAsm.t} \rightarrow \\
&       \text {SparcAsm.t} \times \text {Id.t M.t} \\
& \R^E_\varepsilon(E, \zdest, E_{\text {cont}}) = (e', \varepsilon') \\
\R^e :& \text {Id.t M.t} \rightarrow
        \text {SparcAsm.exp} \times \text {Id.t} \times \text {SparcAsm.t} \rightarrow \\
&       \text {SparcAsm.t} \times \text {Id.t M.t} \\
& \R^e_\varepsilon(e, \zdest, E_{\text {cont}}) = (e', \varepsilon')
\end {align}$$

## Register Allocation for a Program

$$\begin {align}
\R^p((\{D_1, \ldots, D_n\}), E) = (&\{\R^f(D_1), \ldots, \R^f(D_n)\}, \\
& \R^e_\emptyset(E, x, ()))
\end {align}$$

- $x$ is a fresh dummy variable

## Simple Register Allocation for a Function Definition

$$\begin {align}
\R^f&(\mathtt {L}_x(y_1, \ldots, y_n) = E) =\\
& \mathtt L_x(\r_1, \ldots, \r_n) = \R^e_{x \mapsto \r_0, y_1 \mapsto \r_1, \ldots, y_n \mapsto \r_n} (E, \r_0, \r_0)
\end {align}$$

## Simple Register Allocation for Commands

When $x$ is a register (1/2)

$$\begin {align}
\R_\eps^E&((r \la e, E), \zdest, \Econt) = ((r \la E'; E''), \eps'') \\
& \text {where } \Econt' = (\zdest \la E; \Econt) \\
& \R_\eps^e(e, r, \Econt') = (E', \eps') \\
& \R_{\eps'}^E(E, \zdest, \Econt) = (E'', \eps'') \\
\end {align}$$

- $\zdest$: desitination register

- $\Econt$: the rest of the instruction sequence

- The meaning of $(E, \zdest, \Econt)$ in $\R_\eps^E(E, \zdest, \Econt)$:

    - Execute $E$; store the result of $E$ in $\zdest$; and execute $\Econt$

## Simple Register Allocation for Commands

$$\begin {align}
\R_\eps^E&((r \la e, E), \zdest, \Econt) = ((r \la E'; E''), \eps'') \\
& \text {where } \Econt' = (\zdest \la E; \Econt) \\
& \R_\eps^e(e, r, \Econt') = (E', \eps') \\
& \R_{\eps'}^E(E, \zdest, \Econt) = (E'', \eps'') \\
\end {align}$$

1. Trying to register allocate: $\zdest \la (r \la e; E); \Econt$ 

1. Register allocte $e$, specifying $r$ as its destination and $\Econt' = (\zdest \la E; \Econt)$ as its continuation.

1. Register allocate $E$, specifying $\zdest$ as its destination and $\Econt$ as its continuation.

1. Combine the results

## Simple Register Allocation for Commands

When $x$ is not a register

$$\begin {align}
\R_\eps^E&((x \la e, E), \zdest, \Econt) = \\
& ((r \la E'; E''), \eps'') \\
\\
& \text {where } \Econt' = (\zdest \la E; \Econt) \\
& \R_\eps^e(e, x, \Econt') = (E', \eps') \\
& r \not\in \{\eps'(y) \,|\, y \in \mathit {FV}(\Econt')\} \\
& \R_{\eps', x \mapsto r}^E(E, \zdest, \Econt) = (E'', \eps'')
\end {align}$$

- $r$ is a fresh register.

- Similar to the previous case.  Find an unused register $r$ for $x$.

## Simple Register Allocation for Conditionals

$$\begin {align}
\R_\eps(&\text {if } x = y \text { then } E_1 \text { else } E_2, \zdest, \Econt) \\
& ((\mathtt {save}(\eps(z_1), z_1); \\
& \ldots \\
& \mathtt {save}(\eps(z_n), z_n); \\
& \text {if } \eps(x) = \eps(y) \text { then } E_1' \text { else } E_2'), \eps') \\
\\
& \text {where } \R_\eps(E_1, \zdest, \Econt) = (E_1', \eps_1) \\
& \R_\eps(E_2, \zdest, \Econt) = (E_2', \eps_2) \\
& \eps' = \{ z \mapsto r \,|\, \eps_1(z) = \eps_2(z) = r \}, \\
& \{z_1, \ldots, z_n \} = (\mathit {FV}(\Econt) \setminus \{\zdest\} \setminus \dom(\eps')) \cup \dom(\eps)
\end {align}$$
