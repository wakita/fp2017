---
author: "Ken Wakita"
title: "FP: Assignment 1 (Sept. 28)"
---

# Assignment

Published date
: Oct. 2, 2017

Due date
: Oct. 12, 2017

Method of Submission
: [OCW-i](https://secure.ocw.titech.ac.jp/ocwi/)

    Upload `answer2.ml` at the respective page of OCW-i.

    You need to register for this class to open the OCW-i assignment page.

Delayed Submission
: Each submission is weighed according to half-value period of 10 days.  That means if you submit a perfect answer 30 days after the due date, you will receive $1/8$ the full points.  In other words, you lose $1 - 1/2^{1/10} \approx 6.7\text {%}$ points each day after the due date has passed.  It is very wise to keep the due date.^[この半減期はトイチ金融よりも遥かに非情なので気をつけて下さい．/ This half-value period is much worse than the interest rate of the meanest loan office; time is money.]

# Your Mission

Download the template OCaml file  [answer2.ml](/fp2017/answer2.ml) for this assignment.

Your mission is to correctly modify `answer2.ml`.


## Problem 1. `values`

Define a function named `values` that takes a binary tree and gives a list of values contained in the tree following the order that occur from left to right in the tree.

`values Node(3, Node(2, Node(1, Empty, Empty), Node(4, Empty, Empty)), Empty)` should give `[1, 2, 3, 4]`.

## Problem 2. `is_sorted`

It is important for the binary tree data structure that its elements are sorted.  If it is not the case the `member` and `insert` do not work as we expect: e.g. `member 1 (Node(2, Empty, (Node(1, Empty, Empty))))` fails to find `1` contained in the tree.

Define a function name `is_sorted` that takes a tree and tells if it is a binary tree.

## Problem 3. `reverse`

Define a function named `reverse` that takes a binary tree and construct a *reversed* tree which is the mirror image of the given binary tree.

`reverse Node(3, Node(2, Node(1, Empty, Empty), Empty), Node(4, Empty, Empty)))` should give `Node(3, Empty, Node(2, Node(4, Empty, Empty), Node(1, Empty, Empty)))`
