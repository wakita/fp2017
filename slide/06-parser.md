---
title: "FP: Day 5<br/>Lexer / Parser / AST"
date: "Oct. 16, 2017"
---

# From Text to Tree

## Lexer and Parser

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

~~~ {.ocaml}
val Lexer.token : Lexing.lexbuf -> Parser.token

val exp : (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Syntax.t
~~~

## Schematic View of the Frontend

~~~ {.ocaml}
let rec fib n = if n < 2 then ... : Lexing.lexbuf (* Source code *)

[Parser.LET; Parser.REC;
 Parser.IDENT("fib"); Parser.IDENT("n"); Parser.EQUAL;
 Parser.IF; Parser.IDENT("n"); Parser.INT(2); Parser.THEN;
 ...] : Parser.token list (* Tokens *)

Syntax.LetRec({name = ("fib", Type.Fun([Type.Int], Type.Int)),
               args = [("n", Type.Int)],
               body = Syntax.If(Syntax.LE(Syntax.Var("n"),
                                          Syntax.Int(2),
                                then_expression,
                                else_expression))}) : Syntax.t (* Abstract Syntax Tree *)
~~~

## Parser.token

Tokens are declared in the parser specification (`parser.mly`).

~~~ {.ocaml}
%token <bool> BOOL
%token <int> INT
%token <float> FLOAT
%token NOT
%token MINUS
...
~~~

`ocamlyacc` generates `parser.{mli,ml}` and translates token declarations as members of the `token` variant type declaration (`parser.mli`).  

~~~ {.ocaml}
type token =
  | BOOL of (bool) | INT of (int) | FLOAT of (float)
  | NOT | MINUS | PLUS
  | MINUS_DOT | PLUS_DOT | AST_DOT | SLASH_DOT
  | EQUAL | LESS_GREATER | LESS_EQUAL | GREATER_EQUAL | LESS | GREATER
  | IF | THEN | ELSE
  | IDENT of (Id.t)
  | LET | IN | REC
  | COMMA | SEMICOLON | LPAREN | RPAREN
  | ARRAY_CREATE | DOT | LESS_MINUS
  | EOF
~~~

## Abstract Syntax (`Syntax.t`)

`Syntax.t` is declared according to the abstract syntax of MinCaml.

~~~ {.ocaml}
type t = (* The data structure that represents the syntax tree of MinCaml *)
  | Unit | Bool of bool | Int of int | Float of float (* constant *)
  | Not of t | Neg of t (* primitive operations *)
  | Add of t * t | Sub of t * t
  | FNeg of t | FAdd of t * t | FSub of t * t | FMul of t * t | FDiv of t * t
  | Eq of t * t | LE of t * t
  | If of t * t * t (* conditional *)
  | Let of (Id.t * Type.t) * t * t | Var of Id.t (* variable declaration/reference *)
  | LetRec of fundef * t | App of t * t list (* Recursive function *)
  | Tuple of t list | LetTuple of (Id.t * Type.t) list * t * t
  | Array of t * t | Get of t * t | Put of t * t * t
and fundef = { name : Id.t * Type.t; args : (Id.t * Type.t) list; body : t }
~~~

![Abstract syntax of MinCaml](/fp2017/mincaml/overview/ast.png)

# Lexer Implementation

## `lexer.mll`

Regular expression aliases

~~~ {.ocaml}
let space = [' ' '\t' '\n' '\r']
let digit = ['0'-'9']
let lower = ['a'-'z']
let upper = ['A'-'Z']
~~~

Token rules

~~~ {.ocaml}
| '(' { LPAREN }
| ')' { RPAREN }
| "true" { BOOL(true) }
| "false" { BOOL(false) }
  ...
~~~

## Valued Token Rule

Token rules

~~~ {.ocaml}
let digit = ['0'-'9']
...

rule token = parse
  ...
| '(' { LPAREN }
| ')' { RPAREN }
| "true" { BOOL(true) }
| "false" { BOOL(false) }
  ...
| digit+ (* non-negative integer number *)
    { INT(int_of_string (Lexing.lexeme lexbuf)) }
~~~

- `Lexing.lexeme lexbuf` gives the `string` that matched the pattern (`digit+` in this case).

- The resulting value of this rule for `"0123"` will be `Syntax.Int(0123)`.

## Nested Block Comments

~~~ {.ocaml}
rule token = parse
  ...
| "(*" { comment lexbuf; (* For handling nested comments *)
         token lexbuf    (* Going back to look for tokens *) }

and comment = parse
| "*)" { ()              (* Finished!  It may continue with the outer block comment. *) }

| "(*" { comment lexbuf; (* Nested block comment!  Handle the inner block comment. *)
         comment lexbuf  (* Continue handing the outer block comment. *) }

| eof  { Format.eprintf "warning: unterminated comment@." }

| _    { comment lexbuf  (* Ignore other symbols (_) *) }
~~~

# Parser Implementation

## `Parser.mly`

~~~ {.ocaml}
/* Tokens */
%token <bool> BOOL
%token <int> INT
%token <float> FLOAT

/* Precedence order */
%nonassoc IN
%right prec_let
%right SEMICOLON

/* The Starting Symbol of Context Free Grammar */
%type <Syntax.t> exp
%start exp
~~~

~~~ {.ocaml}
/* Syntax Derivation Rules */
exp: /* Expressions */
| simple_exp { $1 }
| NOT exp %prec prec_app { Not($2) }
| ...

/* Rules for fundef, formal_args, actual_args, elems, and pat */
~~~

## Precedence Rules

~~~ {.ocaml}
/* Precedence (lower to higher) and associativity */
%nonassoc IN
%right prec_let
%right SEMICOLON
%right prec_if
%right LESS_MINUS
%nonassoc prec_tuple
%left COMMA
%left EQUAL LESS_GREATER LESS GREATER LESS_EQUAL GREATER_EQUAL
%left PLUS MINUS PLUS_DOT MINUS_DOT
%left AST_DOT SLASH_DOT
%right prec_unary_minus
%left prec_app
%left DOT
~~~

- `prec_let`, `prec_if`, `prec_tuple`, `prec_unary_minus`, `pre_app` are named precedence ranks.  They are attached to some derivation rules.

## Associativity

`%left PLUS MINUS PLUS_DOT MINUS_DOT`
: `1 - 3 - 5` is treated as $(1 - 3) - 5$ but not as $1 - (3 - 5)$.

`%left prec_app`
: `f 1 2` is treated as `(f 1) 2` rather than `f (1 2)`, which raises type error during type analysis.

    `f g x` is treated as `(f g) x` rather than `f (g x)`.  If you meant the latter, you need to explicitly use parentheses.

`%right prec_unary_minus`
: `- -1` is treated as `- (-1)` rather than `(- -) 3`, which is a syntax error.

## Precedence Ranks

Q. How `1 - - 3` will be parsed?

- The first occurrence of `-` is considered a *binary* `MINUS` but the second occurrence is considered a *unary* `MINUS`.

- If binary and unary `MINUS`es are given the same precedence rank, we get `(1 - -) ...` as `-` associates to the left and this result is a syntax error.

- We give a higher precedence to the unary `MINUS` (`#83@parser.mly`) such that `1 - - 3` be parsed as `1 - (-3)`.

- Also `prec_unary_minus` associates to the right: `1 - - - 3` is parsed as `1 - (- (-3))`.  If it associates to the left the result would be `1 - ((- -) 3)`, a syntax error.

## Derivation Rules

~~~ {.ocaml}
non_terminal_symbol:
| symbol1 symbol2 ... { action }
~~~

The value of the $n$-th occurrence of the symbol is the abstract syntax subtree that matches the symbol.  It is referenced in the action part by `$n`.

### Example

~~~ {.ocaml}
exp: /* General Expressions */
| ...
| exp PLUS exp  { Add($1, $3) }
~~~

- `$1` corresponds to the first occurrence of `exp`, the left hand side of `+`, and `$2` to the second occurrence, the right hand side of `+`.  The action in this example combines the abstract syntax subtrees of LHS and RHS by the `Add` constructor:

    `| exp PLUS exp { let left = $1 and right = $2 in Add(left, right) }`

## Initial Type Assignment

~~~ {.ocaml}

let addtyp x = (x, Type.gentyp ())

exp:
| ...
| LET IDENT EQUAL exp IN exp
    %prec prec_let
    { Let(addtyp $2, $4, $6) }

fundef:
| IDENT formal_args EQUAL exp
    { { name = addtyp $1; args = $2; body = $4 } }
~~~

# Testing the parser

## Running `min-caml.top`

~~~ {.ocaml}
☁ ./min-caml.top
         OCaml version 4.05.0

 # open Id;; open Parser;; open Lexer;; open Type;;
 # let program = "let rec fib n = if n < 2 then 1 else fib(n - 1) + fib(n - 2) in fib(5)";;
 val program : string = "..."
~~~

~~~ {.ocaml}
 # Parser.exp Lexer.token (Lexing.from_string program);;
 - : Syntax.t =
 Syntax.LetRec
 ({Syntax.name = ("fib", Var {contents = None});
   args = [("n", Var {contents = None})];
   body =
    Syntax.If (Syntax.Not (Syntax.LE (Syntax.Int 2, Syntax.Var "n")),
     Syntax.Int 1,
     Syntax.Add
      (Syntax.App (Syntax.Var "fib",
        [Syntax.Sub (Syntax.Var "n", Syntax.Int 1)]),
      Syntax.App (Syntax.Var "fib",
       [Syntax.Sub (Syntax.Var "n", Syntax.Int 2)])))},
 Syntax.App (Syntax.Var "fib", [Syntax.Int 5]))
~~~

## Some comments

~~~ {.ocaml}
 # Parser.exp Lexer.token (Lexing.from_string program);;
 - : Syntax.t =
 Syntax.LetRec
 ({Syntax.name = ("fib", Var {contents = None});
   args = [("n", Var {contents = None})];
   body =
    Syntax.If (Syntax.Not (Syntax.LE (Syntax.Int 2, Syntax.Var "n")),
     Syntax.Int 1,
     Syntax.Add
      (Syntax.App (Syntax.Var "fib",
        [Syntax.Sub (Syntax.Var "n", Syntax.Int 1)]),
      Syntax.App (Syntax.Var "fib",
       [Syntax.Sub (Syntax.Var "n", Syntax.Int 2)])))},
 Syntax.App (Syntax.Var "fib", [Syntax.Int 5]))
~~~

- Types are not assigned to variables, yet: `Var {contents = None}`

    `Type.t = | Unit | ... | Var of t option ref`

    `type 'a option = None | Some of 'a`

- The comparison `n < 2` has been converted to `not (2 >= n)`

    `Syntax.Not (Syntax.LE (Syntax.Int 2, Syntax.Var "n"))`

## A Handy Setting

Save the following under the `min-caml` directory by the name `.ocamlinit` and you do not need to `open` them explicitly when you launch `min-caml.top` next time.

~~~ {.ocaml}
open Alpha;; open Asm;; open Assoc;; open Beta;; open Closure;; open ConstFold;;
open Elim;; open Emit;; open Id;; open Inline;; open KNormal;; open Lexer;; open M;;
open Main;; open Parser;; open RegAlloc;; open S;; open Simm;; open Syntax;;
open Type;; open Typing;; open Virtual;;
~~~

Then you can start `min-caml.top` and skip openning bunch of `*.ml`.

~~~ {.ocaml}
 ☁  ./min-caml.top
         OCaml version 4.05.0
 
 # let program = "let rec fib n = if n < 2 then 1 else fib(n - 1) + fib(n - 2) in fib(5)";;
 val program : string =
   "let rec fib n = if n < 2 then 1 else fib(n - 1) + fib(n - 2) in fib(5)"
 # Parser.exp Lexer.token (Lexing.from_string program);;
 - : Syntax.t =
 LetRec
  ...
~~~

# Reading Assignment

## Unification

Read the following sections of the Unification page of Wikipedia

- Common formal definitions
    - Prerequisites
    - First-order term
    - Substituion
    - Generalization, specialization
    - Unification problem, solution set
- Syntactic unification of first-order terms
    - A unification algorithm (you may skip "Proof of termination")
    - Examples of syntactic unification of first-order terms

There will be a quiz on unification at the beginning of the next class

# Next Day

Typing
