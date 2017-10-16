- PDF export:
    `CSS += lib/reveal.js-3.5.0/css/print/pdf.css`

- undef min_caml_print on Linux

    Attemp on TSUBAME (`/home/3/wakita-k-aa/tmp/mincaml-fib`)

    ~~~ {.bash}
    ../min-caml fib
    ls
    type gcc
    gcc -m32 -O2 -Wall fib.s ../libmincaml.S ../stub.c -lm -o fib
    ./fib
    ~~~    

    - Linux version 4.4.74-92.29-default (geeko@buildhost) (gcc version 4.8.5 (SUSE Linux) ) #1 SMP Thu Jun 29 13:06:32 UTC 2017 (561ddb1)
    - SUSE Linux Enterprise Server 12 (x86_64) / VERSION = 12, PATCHLEVEL = 2

- no functional type conclusion in typeing rule

    The assumptions require that x's type is functional in e1 and e2
