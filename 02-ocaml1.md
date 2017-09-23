# Introduction to OCaml

- Expressions
- Names
- Types
- Functions

## About OCaml

- [ocaml.org](https://ocaml.org/learn/description.html)
- [Cheat sheets](https://ocaml.org/docs/cheat_sheets.html)
- [Code examples](https://ocaml.org/learn/taste.html)
- [99 basic problems in OCaml](https://ocaml.org/learn/tutorials/99problems.html)
- [Official tutorial (The core languages)](http://caml.inria.fr/pub/docs/manual-ocaml/coreexamples.html): This class follows this material

## Basics

- Expression

    `1+2*3`

- Introduction of name (`let`), binding a value to a name

    `let pi = 4.0 *. atan 1.0`

- Function definition

    `let square x = x *. x`

- Function call and standard functions (*sin*, *cos*)

    `square (sin pi) +. square (cos pi)`

- Failure during type checking

    `1.0 * 2`

- Recursive defined functions (`let rec`)

    ```
    let rec fib n =
      if n < 2 then n else fib (n-1) + fib (n-2)
      fib 10
    ```

## Data types

- Logical values (`true` and `false`) and `bool` type

    ```
    # (1 < 2);;
    - : bool = true
    ```

- Characters and `char` type

    ```
    # 'a';;
    - : char = 'a'
    ```

- Strings and `string` type

    `"Hello world"

- Lists and `... list` type

    ```
    # let l = ["is"; "a"; "tale"; "told"; "etc."];;
    val l : string list = ["is"; "a"; "tale"; "told"; "etc."]
    ```

- List constructor (`::`)

    ```
    # "Life" :: l;;
    - : string list = ["Life"; "is"; "a"; "tale"; "told"; "etc."]
    ```

- Pattern matching (application to sorting)

    ```
    let rec sort lst =
      match lst with
        [] -> []
      | head :: tail -> insert head (sort tail)
    and insert elt lst =
      match lst with
        [] -> [elt]
      | head :: tail -> if elt <= head then elt :: lst else head :: insert elt tail
    sort l
    ```

## Functions as values

- `deriv`: numerical derivation, `function` syntax is used to construct an unnamed function（a λ expression.

    ```
    let deriv f dx = function x -> (f (x +. dx) -. f x) /. dx
    ```

- `sin'`: Derivative of the sin function

    Note: `'` can be a part of a name.

    ```
    let sin' = deriv sin 1e-6
    sin' pi
    ```

- Function composition (`compose`) is a typical use case of higher-order functions.

    ```
    let compose f g = function x -> f (g x)
    ```

- In the following, `cos2` denotes the square of `cos` function

    ```
    let cos2 = compose square cos
    ```

    A *higher-order function* is a function that takes a function as an argument or gives a function as its return value.  For example, a standard function `List.map` is a higher-order function that takes a function and a list and returns a list whose elements results from application of the function to each element of the list.

    ```
    # List.map (function n -> n * 2 + 1) [0;1;2;3;4];;
    - : int list = [1; 3; 5; 7; 9]
    ```

- An equivalent of `List.map` can be easily defined as follows:

    ```
    let rec map f l =
    match l with
      [] -> []
      | hd :: tl -> f hd :: map f tl
    ```

# Records

*Record*s are compound data structure that comprises of values.  Each element of a record can be dereferenced by a *label* (or *field*).  (There is another compound data type called tuples.  We will discuss about the tuple type later.)

- Declaration of a record type.  An instance of the `ratio` type consists of two integer values.  They are addressed by their names, `num` and `denom`.

    ```
    type ratio = {num: int; denom: int}
    ```

- An element of record is addressed by its label (or field name):

    ```
    let add_ratio r1 r2 =
      {num = r1.num * r2.denom + r2.num * r1.denom;
       denom = r1.denom * r2.denom}
    ```

- A record can be created and used on the fly without binding it to a name.  In the following example, two instances of the `ratio` type is created and immediately passed to the `add_ratio` function.

    ```
    add_ratio {num=1; denom=3} {num=2; denom=5}
    ```

# Variants

*Variant* type is sometimes called *tagged union*.  In the following example, we define a variant type called `number` whose instance is either an integer value, float value, or an error.

```
# type number = Int of int | Float of float | Error;;
type number = Int of int | Float of float | Error
# Int 7;;
- : number = Int 7
# Float 3.14;;
- : number = Float 3.14
# Error;;
- : number = Error
```

The tags of a variant type, such as `Int`, `Float`, and `Error`, are called *constructors* of the variant.

Some constructors take arguments.  In the above example, the `Int` constructor takes an integer, while the `Float` constructor takes a floating point number.

Some constructors do take no argument.  In the above example, the `Error` constructor takes no argument and creates an instance of the `number` variant.  A variant that consists of argument-free constructors resembles *enum* type in C programming language.

```
type sign = Positive | Negative
```

A variants is a (first class) value.  It can be bound to a name (`let n = Int 3`), passed to a function as an argument, and be a return value of a function.

```
let sign_int n = if n >= 0 then Positive else Negative
```

In C, we use the **switch** statement to test a tagged union value.  In OCaml, pattern matching is used for testing variant values.

```
let add_num n1 n2 =
  match (n1, n2) with
    (Int i1, Int i2) ->
      (* Check for overflow of integer addition *)
      if sign_int i1 = sign_int i2 && sign_int (i1 + i2) <> sign_int i1
      then Float(float i1 +. float i2)
      else Int(i1 + i2)
  | (Int i1, Float f2) -> Float(float i1 +. f2)
  | (Float f1, Int i2) -> Float(f1 +. float i2)
  | (Float f1, Float f2) -> Float(f1 +. f2)
  | (Error, _) -> Error
  | (_, Error) -> Error
```

Let's test the `add_num` function:

```
add_num (Int 123) (Float 3.14159)
```

The tree type is an important data structure but in some programming language its definition can be troublesome.  In OCaml its definition is this easy.

```
type 'a btree = Empty | Node of 'a * 'a btree * 'a btree
```

A function that manipulates of trees can be simply defined by use of pattern matching.

```
let rec member x btree =
  match btree with
    Empty -> false
  | Node(y, left, right) ->
      if x = y then true else
      if x < y then member x left else member x right
```

```
let rec insert x btree =
  match btree with
    Empty -> Node(x, Empty, Empty)
  | Node(y, left, right) ->
      if x <= y then Node(y, insert x left, right)
                else Node(y, left, insert x right)
```

-----

#Assignments

`assignment1.ml`というファイルに以下の課題の答を記述し、OCW-i を介して提出しなさい。〆切はOCW-iに記載する。

Question should be addressed on [a Github issue page](https://github.com/wakita/fp2015/issues/1) (you need a Github account to do so).

## Assignment 1: Tree manipulation (tree.ml)

- Give a definition of the `size` function, which counts the number of `Node` in the tree.

- Give a definition of the `height` function, which takes a `btree`-typed tree and gives its height.  `height Empty` should be 0.

## Assignment 2: Gray code (gray.ml)

The following is a sequence of the *N-bit gray code* for smaller *N*s.  Examine this sequence and figure out the general rule that generates gray code in the general cases.  Describe the rule in OCaml.

gray 0 = []
gray 1 = [[0]; [1]]
gray 2 = [[0; 0]; [0; 1]; [1; 1]; [1; 0]]
gray 3 = [[0; 0; 0]; [0; 0; 1]; [0; 1; 1]; [0; 1; 0]; [1; 1; 0]; [1; 1; 1]; [1; 0; 1]; [1; 0; 0]]

<!--
## Assignment 3: every2 (every2.ml)

Define a function named `every_next` that takes a tree of `'a bteee` and gives a list that consists of the elements in the tree that appears in the odd positions of the tree leaves.

```
every_next: 'a btree -> 'a list

every_next (Node(1, Node(2, Empty, Empty), Node(3, Empty, Node(4, Empty, Empty)))) = [2, 3]
```
-->
