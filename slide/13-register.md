---
title: "Register Allocation"
date: "Nov 13, 2017"
---

# Register Allocation<br/>No targetting, No Spilling

## "Register" Format

$$\newcommand\R{{\cal R}}
\newcommand\r{\mathtt {R}}
\newcommand\T{{\cal T}}
\newcommand\eps{{\varepsilon}}
\newcommand\la{{\leftarrow}}
\newcommand\ra{{\rightarrow}}
\newcommand\zdest{{z_{\text {dest}}}}
\newcommand\Econt{{E_{\text {cont}}}}
\newcommand\Econtp{{E'_{\text {cont}}}}
\newcommand\dom{{\mathit {dom}}}$$
\newcommand\FV{\mathit {FV}}

$$\begin {align}
\R^p :& \text {Asm.prog} \rightarrow \text {Asm.prog} \\
\R^f :& \text {Asm.fundef} \rightarrow \text {Asm.fundef} \\
\R^E :& \text {Id.t M.t} \rightarrow
        \text {Asm.t} \times \text {Id.t} \times \text {Asm.t} \rightarrow \\
&       \text {Asm.t} \times \text {Id.t M.t} \\
& \R^E_\varepsilon(E, \zdest, E_{\text {cont}}) = (e', \varepsilon') \\
\R^e :& \text {Id.t M.t} \rightarrow
        \text {Asm.exp} \times \text {Id.t} \times \text {Asm.t} \rightarrow \\
&       \text {Asm.t} \times \text {Id.t M.t} \\
& \R^e_\varepsilon(e, \zdest, E_{\text {cont}}) = (e', \varepsilon')
\end {align}$$

## RegAlloc for a Program

$$\begin {align}
\R^p((\{D_1, \ldots, D_n\}), E) = (&\{\R^f(D_1), \ldots, \R^f(D_n)\}, \\
& \R^E_\emptyset(E, x, ()))
\end {align}$$

- $x$ is a fresh dummy variable

## RegAlloc for a Function Definition

$$\begin {align}
\R^f&(\mathtt {L}_x(y_1, \ldots, y_n) = E) =\\
& \mathtt L_x(\r_1, \ldots, \r_n) = \R^E_{x \mapsto \r_0, y_1 \mapsto \r_1, \ldots, y_n \mapsto \r_n} (E, \r_0, \r_0)
\end {align}$$

- Function call API
    - Closure is given by $\r_0$
    - Actual arguments are passed via $\r_1, \ldots, \r_n$
    - The result of computation by the function should be passed by $\r_0$ (the second argument $\r_0$ of $\R^E$)
    - The value of function definition is the function itself (the last argument $\r_0$ of $\R^E$)

## RegAlloc for Commands

When $x$ is a register (1/2)

$$\begin {align}
\R_\eps^E&((r \la e, E), \zdest, \Econt) = ((r \la E'; E''), \eps'') \\
& \text {where } \Econtp = (\zdest \la E; \Econt) \\
& \quad \R_\eps^e(e, r, \Econtp) = (E', \eps') \\
& \quad \R_{\eps'}^E(E, \zdest, \Econt) = (E'', \eps'') \\
\end {align}$$

- $\zdest$: desitination register

- $\Econt$: the rest of the instruction sequence

- The meaning of $(E, \zdest, \Econt)$ in $\R_\eps^E(E, \zdest, \Econt)$:

    - Execute $E$; store the result in $\zdest$; and continue to $\Econt$

## RegAlloc for Commands

$$\begin {align}
\R_\eps^E&((r \la e, E), \zdest, \Econt) = ((r \la E'; E''), \eps'') \\
& \text {where } \Econtp = (\zdest \la E; \Econt) \\
& \quad \R_\eps^e(e, r, \Econtp) = (E', \eps') \\
& \quad \R_{\eps'}^E(E, \zdest, \Econt) = (E'', \eps'') \\
\end {align}$$

1. Try to allocate register: $\zdest \la (r \la e; E); \Econt$ 

1. Register allocte $e$, specifying $r$ as its destination and $\Econtp = (\zdest \la E; \Econt)$ as its continuation.

1. Register allocate $E$, specifying $\zdest$ as its destination and $\Econt$ as its continuation.

1. Combine the results

## RegAlloc for Commands

When $x$ is not a register

$$\begin {align}
\R_\eps^E&((x \la e, E), \zdest, \Econt) = \\
& ((r \la E'; E''), \eps'') \\
\\
& \text {where } \Econtp = (\zdest \la E; \Econt) \\
& \quad \R_\eps^e(e, x, \Econtp) = (E', \eps') \\
& \quad r \not\in \{\eps'(y) \,|\, y \in \FV(\Econtp)\} \\
& \quad \R_{\eps', x \mapsto r}^E(E, \zdest, \Econt) = (E'', \eps'')
\end {align}$$

- $r$ is a fresh register.

- Similar to the previous case.  Find an unused register $r$ for $x$.

## RegAlloc for References

$$\R_\eps^e(x, \zdest, \Econt) = (\eps(x), \Econt)$$

- Reference to a variable ($x$) is converted to reference to its corresponding register ($\eps(x)$).

## RegAlloc for Assignments

$$\begin {align}
\R_\eps^e(x.(y) \la z, \zdest, \Econt) &= (\eps(x).(\eps(y)) \la \eps(z), \eps) \\ \\
\R_\eps^e(\mathtt {save}(x, y), \zdest, \Econt) &= (\mathtt {save}(\eps(x), y), \eps) \\ \\
\R_\eps^e(\mathtt {restore}(y), \zdest, \Econt) &= (\mathtt {restore}(y), \eps)
\end {align}$$

- Assignments are issued for preallocated registers/stack elements and do not require additional register allocation ($\eps$ is preserved)

- $\zdest$ is not (at least explicitly) updated in these rules because assignments does not give results.

## RegAlloc for Closure Calls

$$\begin {align}
\R_\eps^e&(\mathtt {apply\_closure}(x, y_1, \ldots, y_n), \zdest, \Econt) = \\
(&(\mathtt {save}(\eps(z_1), z_1);\\
& \ldots \\
& \mathtt {save}(\eps(z_n), z_n);\\
& \mathtt {apply\_closure}(\eps(x), \eps(y_1), \ldots, \eps(y_n))), \emptyset) \\ \\
& \text {where } \{ z_1, \ldots, z_n \} = (\FV(\Econt) \setminus \{ \zdest \}) \cap \dom(\eps)
\end {align}$$

## RegAlloc for Closure Calls

$$\text {where } \{ z_1, \ldots, z_n \} = (\FV(\Econt) \setminus \{ \zdest \}) \cap \dom(\eps)$$

- The set of variables $\{z_1, \ldots, z_n\}$ that

    - are already allocated (${} \cap \dom(\eps)$),

    - are live (used in the continuation; $\FV(\Econt)$), and

    - are not the target (${} \setminus \,\{ \zdest \}$).

## RegAlloc for Conditionals

$$\begin {align}
\R_\eps(&\text {if } x = y \text { then } E_1 \text { else } E_2, \zdest, \Econt) \\
(&(\mathtt {save}(\eps(z_1), z_1); \\
& \ldots \\
& \mathtt {save}(\eps(z_n), z_n); \\
& \text {if } \eps(x) = \eps(y) \text { then } E_1' \text { else } E_2'), \eps') \\
\\
& \text {where } \R_\eps^E(E_1, \zdest, \Econt) = (E_1', \eps_1) \\
& \quad \R_\eps^E(E_2, \zdest, \Econt) = (E_2', \eps_2) \\
& \quad \eps' = \{ z \mapsto r \,|\, \eps_1(z) = \eps_2(z) = r \}, \\
& \quad \{z_1, \ldots, z_n \} = (\FV(\Econt) \setminus \{\zdest\} \setminus \dom(\eps')) \cap \dom(\eps)
\end {align}$$

## RegAlloc for Conditionals

$$\begin {align}
& \eps' = \{ z \mapsto r \,|\, \eps_1(z) = \eps_2(z) = r \}, \\
& \{z_1, \ldots, z_n \} = (\FV(\Econt) \setminus \{\zdest\} \setminus \dom(\eps')) \cap \dom(\eps)
\end {align}$$

- The set of variables $\{z_1, \ldots, z_n\}$ that

    - are already allocated (${} \cap \dom(\eps)$),

    - are live (used in the continuation; $\FV(\Econt)$),

    - are not the target (${} \setminus \,\{ \zdest \}$), and

    - are register-allocted differently along branches $E_1$ and $E_2$.

# Register Allocation<br/>Targetting

## Targetting (Register recommendation)

Suggest a set of recommended registers for register allocation: $\T_x^E(E, \zdest)$ and $\T_x^e(e, \zdest)$.

In selection of $r$ for $x$ in the previous RegAlloc algorithm, the results of $\T_x^E$ and $\T_x^e$ are consulted.

## The Format

$$\begin {align}
\T_x^E:& \text { Id.t} \ra \text {Asm.t} \times \text {Id.t} \ra \text {bool} \times \text {S.t} \\
& \T_x^E((y \la e; E), \zdest) = (c, s) \\
\T_x^e:& \text { Id.t} \ra \text {Asm.exp} \times \text {Id.t} \ra \text {bool} \times \text {S.t} \\
& \T_x^e(e, \zdest) = (c, s)
\end {align}$$

- $c$: Does $E$ or $e$ issue function application?

- $s$: the set of recommended registers for allocation

## Targetting

$$\begin {align}
\T_x^e(x, \zdest) &=
  (\mathit {false}, \{ \zdest \}) \\
\T_x^e(\text {if } y = z \text { then } E_1 \text { else } E_2, \zdest) &=
  (c_1 \wedge c_2, s_1 \cup s_2) \\
  & \text {where } \T_x^e(E_1, \zdest) = (c_1, s_1) \\
  & \text { and } \T_x^e(E_2, \zdest) = (c_2, s_2)
\end {align}$$

1. As the destination $\zdest$ is specified for $x$, $\zdest$ is the recommended register for $x$.

1. Expressions $E_1$ and $E_2$ recommend $s_1$ and $s_2$, respectively, for register allocation of $x$.  The register set $s_1 \cup s_2$ is recommended for the whole conditional expression.

## Targetting

$$
\T_x^e(\mathit {apply\_closure}(y_0, y_1, \ldots, y_n), \zdest) =
(\mathit {true}, \{ \R_i \,|\, x = y_i \})
$$

- If $x$ is passed as the $i$'th argument of the closure, we would like $x$ to be assigned to $\R_i$.

- The varialbe $x$ may be placed at more than one parameter positions.

# Register Allocation<br/>Spilling

## Issue & Idea

When we use a large number of registers, we may run out of registers.

- A function declaration that takes many formal arguments.

    $\mathtt L_x(\r_1, \ldots, \r_n) = \R^E_{x \mapsto \r_0, y_1 \mapsto \r_1, \ldots, y_n \mapsto \r_n} (E, \r_0, \r_0)$ and $n > \text {#registers}$

    Ask the programmer to rewrite the function such that it takes some of the parameters as a tuple.

- Use of many variables inside a function

    They can not be assigned to registers at the same time

    **Spilling**: Push the value of a variable out from a register to stack, while using the register to store other variable's value

## RegAlloc for Commands

The case: $\R_\eps^E((x \la e, E), \zdest, \Econt)$ ($x$ is not a register) and $\color {red} {^{\not\exists} r \text { such that } r \in \{ \eps'(y) \,|\, y \in \FV(\Econtp) \}}$

$$\begin {align}
\R_\eps^E&((x \la e, E), \zdest, \Econt) = \\
& \color {blue} {\begin {cases}
    ((save(\eps(y), y); \eps'(y) \la E'; E''), \eps'') & y \in \dom(\eps) \\
    ((\eps'(y) \la E'; E''), \eps'') & \text {otherwise}
  \end {cases}} \\
\\
& \text {where } \Econtp = (\zdest \la E; \Econt) \\
& \quad \R_\eps^e(e, x, \Econtp) = (E', \eps') \\
& \quad \color {blue}{y \in \FV(\Econtp)} \\
& \quad \R_{\color {red}{\eps' \setminus \{ y \mapsto \eps'(y) \}, x \mapsto \eps'(y)}}^E(E, \zdest, \Econt) = (E'', \eps'')
\end {align}$$

Notes
: - RegAlloc environments: $\eps$: before the command execution, $\eps'$: after the execution of $x \la e$, $\eps''$: after the execution of $(x \la e, E)$.

    - Command sequence: $E$: original command sequence, $E'$: the command sequence for $x \la e$ after its regalloc, $E''$: the command sequence for $E$ after its regalloc.

    - All the registers are occupied with live variables ($y$ scans over live variables $\FV(\Econtp)$).  The variable's value is pushed out of the allocated register and is saved in the stack ($\mathtt {save}.

        - $\eps'(y) \la E'$: Save the result of $x \la e$ in the register which was occupied with $y$ ($\eps'(y)$).

        - If the register $y$ is going to be used while executing $E$ but is not allocated, yet, we can use the register to store the value of $x$ for the moment.


## Notes

- RegAlloc environments: $\eps$: before the command execution, $\eps'$: after the execution of $x \la e$, $\eps''$: after the execution of $(x \la e, E)$.

    - Command sequence: $E$: original command sequence, $E'$: the command sequence for $x \la e$ after its regalloc, $E''$: the command sequence for $E$ after its regalloc.

    - All the registers are occupied with live variables ($y$ scans over live variables $\FV(\Econtp)$).  The variable's value is pushed out of the allocated register and is saved in the stack ($\mathtt {save}.

        - $\eps'(y) \la E'$: Save the result of $x \la e$ in the register which was occupied with $y$ ($\eps'(y)$).

        - If the register $y$ is going to be used while executing $E$ but is not allocated, yet, we can use the register to store the value of $x$ for the moment.

## Reassignment in RegAlloc for Commands

$$\R_{\eps' \setminus \{ y \mapsto \eps'(y) \}, x \mapsto \eps'(y)}^E(E, \zdest, \Econt) = (E'', \eps'')$$

- Forget about the register assignment to $y$: ${} \setminus \{ y \mapsto \eps'(y) \}$

- Replace the content of $y$'s register ($\eps'(y)$) by $x$: $x \mapsto \eps'(y)$
