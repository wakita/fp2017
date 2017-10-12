---
title: "FP: Day 5<br/>Min-Caml Compiler Organization"
date: "Oct. 12, 2017"
---

# Building `min-caml`

## Building on Mac

~~~
git clone https://github.com/esumii/min-caml.git
cd min-caml
./to_x86
make min-caml
~~~

- For IS people: The above procedure works on Macs at IS computer room, West-7 building.

- I think it also works on Linux and "Bash on Ubuntu on Windows".

## Building on classic Windows

If you are a Windows user and still unable to upgrade your Windows to recent edition (Anniversary edition or Community edition):

- Install Cygwin

- Install `gcc-core`, `make`, and `ocaml` using cygwin setup tool.

- Follow the [same procedure](#building-on-mac).


## A Healthy Build Log

~~~
☁  min-caml  make min-caml
ocamllex  lexer.mll
82 states, 2498 transitions, table size 10484 bytes
ocamlyacc  parser.mly
...
ocamlc -c -cc "gcc" -ccopt "-g -O2 -Wall -o float.o " float.c ocamlc \
 float.o -custom -g -warn-error -31 -o min-caml \
 ...
File "parser.cmo", line 1:
Warning 31: files parser.cmo and /usr/local/lib/ocaml/compiler-libs/ocamlcommon.cma(Parser) both define a module named Parser
File "lexer.cmo", line 1:
Warning 31: files lexer.cmo and /usr/local/lib/ocaml/compiler-libs/ocamlcommon.cma(Lexer) both define a module named Lexer
~~~

## The Build Result

~~~
☁  min-caml  ls -F
LICENSE			constFold.cmi		lexer.cmo		simm.cmi
Makefile		constFold.cmo		lexer.ml		simm.cmo
OCamlMakefile		constFold.ml		lexer.mll		simm.ml

...

anchor.ml		emit.ml			main.mli		to_sparc*
asm.cmi			emit.mli		min-caml*		to_x86*
asm.cmo			fdpe05.ppt		min-caml.top*		tutorial-mincaml.doc
asm.ml			float.c			min-rt/			tutorial-ml.doc

...
~~~

Many files added.  Among them is the `min-caml` compiler.  The `ls -F` command puts `*` marks after the names of executable files.

# Playing with Min-Caml

## Min-Caml Command Line Arguments

~~~
☁  min-caml  ./min-caml --help
Mitou Min-Caml Compiler (C) Eijiro Sumii
usage: ./min-caml [-inline m] [-iter n] ...filenames without ".ml"...
  -inline maximum size of functions inlined
  -iter maximum number of optimizations iterated
  -help  Display this list of options
  --help  Display this list of options
~~~

- Prepare a min-caml program such as `fib.ml`.  Min-caml program names must end with `.ml`.

- But do not put `.ml` when you execute `min-caml` command.

## Compiling `fib.ml` with Min-Caml

~~~
☁  kw  pwd; ls -F
/Users/wakita/Dropbox/projects/fp/min-caml/kw
fib.ml

☁  kw  ../min-caml fib
free variable print_int assumed as external
free variable print_newline assumed as external
iteration 1000
iteration 999
directly applying fib.17
directly applying fib.17
directly applying loop.19
directly applying fib.17
directly applying loop.19
eliminating closure(s) loop.19
eliminating closure(s) fib.17
register allocation: may take some time (up to a few minutes, depending on the size of functions)
generating assembly...

☁  kw  ls -F
fib.ml  fib.s
~~~

## Linking `fib` Using a C Compiler

~~~
☁  kw  clang -m32 -O2 -Wall fib.s ../libmincaml.S ../stub.c -lm -o fib
ld: warning: PIE disabled. Absolute addressing (perhaps -mdynamic-no-pic) not allowed in code signed PIE, but used in _min_caml_start from /var/folders/6l/z36pjysn4zx7hpfzmcfv4xqh0000gn/T/fib-fd883b.o. To fix this warning, don't compile with -mdynamic-no-pic or link with -Wl,-no_pie

☁  kw  ls -FC
fib*	fib.ml	fib.s
~~~

Use the standard C compiler on your platform.  The above example uses `clang`: the standard on macOS.  Users of other platforms may want to use other compilers, like `gcc`, `icc`.

## Running `fib`

~~~
☁  kw  ./fib
sp = 0xbff0afc0, hp = 0x200000
1346269
1346269
1346269
1346269
1346269
...
1346269
1346269
1346269
~~~

# Anatomy of Min-Caml

## Main Driver Routine (`main.ml`)

~~~ {.ocaml}
let () = (* Main function (caml2html: main_entry) *)
  let files = ref [] in
  Arg.parse
    [("-inline", Arg.Int(fun i -> Inline.threshold := i), "maximum size of functions inlined");
     ("-iter", Arg.Int(fun i -> limit := i), "maximum number of optimizations iterated")]
    (fun s -> files := !files @ [s])
    ("Mitou Min-Caml Compiler (C) Eijiro Sumii\n" ^
     Printf.sprintf "usage: %s [-inline m] [-iter n] ...filenames without \".ml\"..." Sys.argv.(0));
  List.iter
    (fun f -> ignore (file f))
    !files
~~~

## Main Driver Core

~~~ {.ocaml}
let file f =
  let inchan = open_in (f ^ ".ml") and outchan = open_out (f ^ ".s") in
  try
    lexbuf outchan (Lexing.from_channel inchan);
    (* lexbuf is defined above *)
    ...
  with e -> ...

let () = (* Main function (caml2html: main_entry) *)
  let files = ref [] in
  ...
  List.iter
    (fun f -> ignore (file f))
    !files
~~~

## Compiler pipeline

~~~ {.ocaml}
let lexbuf outchan l = (* Compilation: input=lexical buffer, output=outchan (caml2html: main_lexbuf) *)
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

## Tokenization and Parsing

- Lexer.token: Tokenization

- Parser.exp: Parsing

~~~ {.ocaml}
let lexbuf outchan l = (* Compilation: input=lexical buffer, output=outchan (caml2html: main_lexbuf) *)
  ...... .......
    (..........
       (......
          (.........
             (.........
                (.... !.....
                   (.......
                      (.........
                         (........
                            (Parser.exp Lexer.token l)))))))))
~~~

## Name / Module / File

`Lexer.token` (`token` function defined in the `Lexer` module, which is defined in `lexer.ml`, which is generated by `ocamllex` from `lexer.mll`)

:   `Lexer.token` reads a min-caml program buffer (*l*) and converts it into a stream of tokens.

`Parser.exp` (`exp` function defined in the `Parser` module, which is defined in `parser.ml`, which is generated by `ocmalyacc` from `parser.mly`)

:   `Parser.exp` parses a stream of tokens and constructs an abstract syntax tree.

[More on OCaml module system](https://caml.inria.fr/pub/docs/manual-ocaml/moduleexamples.html)

## Construction of Typed Intermediate Representation

~~~ {.ocaml}
let lexbuf outchan l = (* Compilation: input=lexical buffer, output=outchan (caml2html: main_lexbuf) *)
  ...... .......
    (..........
       (......
          (.........
             (.........
                (.... !.....
                   (Alpha.f
                      (KNormal.f
                         (Typing.f
                            ........... ..............))))))))
~~~

## 

- Typing.f: `f` function defined in the `Typing` module, whose definition is found in `typing.ml`

    Type inference and type checking

- KNormal.f: `f` function defined in the `KNormal` module, whose definition is found in `kNormal.ml`

    Conversion of the parse tree into an expression that resembles typed lambda-expression called *K-normal form*

- Alpha.f: `f` function defined in the `Alpha` module, whose definition is found in `alpha.ml`

    Unique renaming

## Optimization

- Series of optimization (`iter`) applied for `limit` times, 1,000 times by default.

~~~ {.ocaml}
let lexbuf outchan l = (* Compilation: input=lexical buffer, output=outchan (caml2html: main_lexbuf) *)
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

## Optimizers

~~~ {.ocaml}
let rec iter n e = (* Iterative optimization *)
  if n = 0 then e else
  let e' = Elim.f (ConstFold.f (Inline.f (Assoc.f (Beta.f e)))) in
  if e = e' then e else
  iter (n - 1) e'
~~~

Input
: `e`: A program representation in typed-KNF

Output
: `e'`: More efficient version of e

Do this `n` times:

- Apply Beta reduction
- Reduce based on associativity equality
- Apply inline expansion
- Apply constant folding
- Remove unused name

## Conversion to Virtual Machine Instructions

~~~ {.ocaml}
let lexbuf outchan l = (* Compilation: input=lexical buffer, output=outchan (caml2html: main_lexbuf) *)
  ...... .......
    (..........
       (......
          (Virtual.f
             (Closure.f
                (.... !.....
                   (.......
                      (.........
                         (........
                            (.......... ........... .)))))))))
~~~

- `Closure.f`: Closure conversion.  Elimination of inner function and first-class uses of functions.

- `Virtual.f`: Conversion to a virtual machine instruction sequence.

## Code Generation

~~~ {.ocaml}
let lexbuf outchan l = (* Compilation: input=lexical buffer, output=outchan (caml2html: main_lexbuf) *)
  Emit.f outchan
    (RegAlloc.f
       (Simm.f
          (.........
             (.........
                (.... !.....
                   (.......
                      (.........
                         (........
                            (.......... ........... .)))))))))
~~~

- `Simm.f`: Optimization on short immediate values

- `RegAlloc.f`: Register allocation.  Assignment of hardware register names to virtual register names.

- `Emit.f`: Assembly code generation.  `outchan` refers to an output port connected to an output assembly file, such as `fib.s`.

## Source Code (lines of code)

Tokenization and Parsing
: lexer.mll (100) / parser.mly (173) / syntax.ml (27)

Construction of typed, intermediate representation
: alpha.ml (46) / kNormal.ml (179) / type.ml (11) / typing.ml (163)

Optimization
: 18 assoc.ml (18) / beta.ml (38) / constFold.ml (50) / elim.ml (32) / inline.ml (32)

Conversion to virtual machine instructions
: 106 closure.ml (106) / virtual.ml (154)

Code generation
: x86/asm.ml (88) / x86/emit.ml (291) / x86/regAlloc.ml (233) / x86/simm.ml (37) / x86/virtual.ml (154)

Others
: anchor.ml (22) / id.ml (25) / m.ml (12) / main.ml (45) / s.ml (11)

Total (1,893)
: 

# More on Min-Caml

## Min-Caml Information

- [Code](https://github.com/esumii/min-caml)

- [Japanese Web page](http://esumii.github.io/min-caml/ )

- [Japanese academic paper](http://esumii.github.io/min-caml/jpaper.pdf)

- [English Web page](http://esumii.github.io/min-caml/index-e.html)

- [English academic paper](http://esumii.github.io/min-caml/paper.pdf)

- [An Overview](/fp2017/mincaml/overview.pdf)
