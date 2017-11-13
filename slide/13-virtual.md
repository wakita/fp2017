---
title: "Virtual Code Generation"
date: "Nov 13, 2017"
---

# Virtual Code Generation

## "Virtual" Format

$$\begin {align}
{\cal V}^p &: \text {Closure.prog} \rightarrow \text {SparcAsm.prog} \\
{\cal V}^f &: \text {Closure.fundef} \rightarrow \text {SparcAsm.fundef} \\
{\cal V}^e &: \text {Closure.t} \rightarrow \text {SparcAsm.t}
\end {align}$$

## Caption of Fig 18

- Variables that occur in RHS but not in LHS are fresh.

- $\mathtt {R_{hp}}$ is a register specifically used as heap pointer.

- $e_1; e_2$ is a short hand notation for $x \leftarrow e_1; e_2$.

- $x \leftarrow E_1; E_2$ is a short hand notation for $x_1 \rightarrow e_1; \ldots; x_n \rightarrow e_n; E_2$, where $(x_1 \rightarrow e_1; \ldots; x_n \rightarrow e_n; E_2) = E_1$.

## V-Code for a Function

$$\begin {align}
{\cal V}^F&(\mathtt {L_x}(y_1, \ldots, y_m)(z_1, \ldots, z_n) = e) = \\
& \mathtt {L_x}(y_1, \ldots, y_m) = \\
& z_1 \leftarrow \mathtt R_0.(4); \quad
  \ldots; \quad
  z=n \leftarrow \mathtt R_0.(4n); \\
& {\cal V}^e(e)
\end {align}$$

- The implementation is a bit more complicated: Offsets into $\mathtt R_0$ takes in account different sizes of `int` and `float` values (four and eight, respectively).

## V-Code for Tupple Creation

$$\begin {align}
{\cal V}^e&((x_1, \ldots, x_n)) =\\
& y \leftarrow \mathtt {R_{hp}}; \quad
  \mathtt {R_{hp}} \leftarrow \mathtt {R_{hp}} + 4n; \\
& y.(0) \leftarrow x_1; \quad
  \ldots; \quad
  y.(4(n - 1)) \leftarrow x_n; \\
& y
\end {align}$$

- $y$ is a fresh register

## V-Code for make\_closure

$$\begin {align}
{\cal V}^e&(\mathit {make\_closure}\ x = (\mathtt {L_x}, (y_1, \ldots, y_m)) \text { in } e) \\
& x \leftarrow \mathtt {R_{hp}}; \quad
  \mathtt {R_{hp}} \leftarrow \mathtt {R_{hp}} + r(n + 1); \\
& z \leftarrow \mathtt L_x; \\
& x.(0) \leftarrow z; \\
& x.(1) \leftarrow y_1; \quad
  \ldots; \quad
  x.(m) \leftarrow y_m; \\
& {\cal V}^e(e)
\end {align}$$

- $z$ is a fresh register

## V-Code for let

$$\begin {align}
{\cal V}^e &(\text {let } x = e_1 \text { in } e_2) = \\
& x \leftarrow {\cal V}(e_1) \\
& {\cal V}(e_2)
\end {align}$$

## V-Code for let tuple

$$\begin {align}
{\cal V}^e &(\text {let }(x_1, \ldots, x_n) = y \text { in } e) = \\
& x_{i_1} \leftarrow y.(4(i_1 - 1)); \\
& \ldots \\
& x_{i_m} \leftarrow y.(4(i_m - 1)); \\
& \text {where } \{x_{i_1}, \ldots, x_{i_m}\} = \{x_1, \ldots, x_n\} \cap \mathit {FV}(e)
\end {align}$$

## V-Code for Array Access

$$\begin {align}
{\cal V}& (x.(y)) = \\
& y' \leftarrow 4 y; \\
& x.(y') \\
\\
{\cal V}& (x.(y) \leftarrow z) = \\
& y' \leftarrow 4 y; \\
& x.(y') \leftarrow z
\end {align}$$
