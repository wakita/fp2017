---
author: "Ken Wakita"
title: "FP: Assignment (optimization)"
---

# Submission

Published date
: Nov. 6, 2017

Due date
: Nov. 13, 2017



Method of Submission
: [OCW-i](https://secure.ocw.titech.ac.jp/ocwi/)

    Please convert/save your essay as a PDF file and upload it at the respective page of OCW-i

Delayed Submission
: Each submission is weighed according to half-value period of 10 days.  That means if you submit a perfect answer 30 days after the due date, you will receive $1/8$ the full points.  In other words, you lose $1 - 1/2^{1/10} \approx 6.7\text {%}$ points each day after the due date has passed.  It is very wise to keep the due date.^[この半減期はトイチ金融よりも遥かに非情なので気をつけて下さい．/ This half-value period is much worse than the interest rate of the meanest loan office; time is money.]

# Assignment

Answer either (or both) questions and submit your answer as a PDF document.  If you answer both questions the better answer will be chosen for your evaluation.

1. What's $\alpha$-conversion for?  What kind of problems we will see if $\alpha$-conversion were not applied?  Find Min-Caml programs that give incorrect answers in absence of proper $\alpha$-conversion.

    Hint: You may want to consider the reason why `inline.ml` refers to `Alpha.g`.

1. Are optimization modules interdependent?  Yes, but in what way?  Find a pair of optimization modules $A$ and $B$ such that for a program $P$, $B$ is effective when it is applied after $A$:

    $$^\exists P. B(P) = P \text { but } B(A(P)) \not= A(P)$$

---

The questions seem simple.  If you think that they can be described in a short paragraph please think little bit more.  Please at least take time to understand the schematic definitions.  The implementation may give insight to those who are more implementation-oriented people.  If you think enough you may discover more profound issues being questioned on you.
