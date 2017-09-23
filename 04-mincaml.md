What we see in the distribution of MinCaml system

# Documents

- LICENSE
- README

# The build system

- Makefile: The build rule.  It describes the dependencies among packages.
- OCamlMakefile: OCamlMakefile is a popular build system for OCaml.

# Data structures

- Id: Identifiers (or names)
- M: Map
- S: Set

# CPU-independent code

- Main: Driver routine of the compiler
- Syntax: Abstract syntax tree
- Type: Types

## Lexer and parser

- Lexer (Ken Wakita)
- Parser (Ken Wakita)

## Types and typing rules

- Typing (Nagayama Kanato): Type-inference rules

## Conversion to k-Normal form

- KNormal (Osako Kayo): Conversion to \(k\)-Normal form
- Alpha (Soga Mitsuaki): \(\alpha\) conversion

## Optimizers

- Beta (Sarocha Sothornprapakorn): Reduction of name aliases (e.g., `let x = y in M` → `[y/x]M`)
- Assoc (Anthony Dubucq): Reduction of nested `let`
- Inline (Ling Tan): Removal of function calls
- ConstFold (Mark Bo Jensen): Evaluation of operators that take constants
- Elim (Jonathan Golan): Elimination of unused variables

## Backend

- Closure: Closure conversion: Translation of nested function definisions to a program that consists solely of top-level function definitions
- Virtual: Virtual machine code generation.  The virtual machine code differs from real machine code in the following aspects
    1. Infinite number of registers
    1. high-level function definitions and calls
    1. conditional expressions

## CPU-dependent code

Signatures of the following three packages are given as part of the CPU-independent code by their implementation is placed under CPU-specific sub-directories (PowerPC / SPARC / and x86).

- Simm: Optimization of arithmetics that deal with small immediate numbers
- RegAlloc: Register allocation
- Emit: Assembly code generation

- to_ppc / to_sparc / to_x86: Scripts to target the build system for specific CPU architectures.  The codebase supports PowerPC (ppc), Sparc (sparc), and x86

- PowerPC, SPARC, x86: Directories that contain CPU specific code.  Each directory containes the following set of packages
    - Asm: Data structure that represents the instruction set architecture
    - Virtual: Virtual machine code generation
    - Simm: Optimization of arithmetics that deal with small immediate numbers
    - RegAlloc: Register allocation
    - Emit: Assembly code generation
    - libmincaml.S: Implementation of some standard library APIs (`print_newline`, `print_int`, `print_byte`, `prerr_int`, `prerr_byte`, `prerr_float`, `read_int`, `read_float`, `create_array`, `create_float_array`, `abs_float`, `sqrt`, `floor`, `int_of_float`, `truncate`, `float_of_int`, `cos`, `sin`, `atan`, `fnegd`, `hp`)

## Runtime system

- float.c: Save/load floating point numbers to/from memory locations
- stub.c: A small C code that prepare the runtime system for the generated `mincaml` code.  It prepares the stack and heap area and calls the code generated from `mincaml` compiler.

# Benchmark suite

- bytemark/: A Benchmark
- min-rt/: A simple ray-tracing program
- shootout/: Various benchmark testing programs
- test/: Test cases
