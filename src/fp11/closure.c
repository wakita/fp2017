/* Closure implementation in C */

#include <stdio.h>

typedef struct {
  int (*fp)(int, int, int, int);
  int fv1; int fv2; } Closure_II_II_I;

int apply_II_II_I(int v1, int v2, Closure_II_II_I *closure) {
  int (*fp)(int, int, int, int) = closure->fp;
  int fv1 = closure->fv1, fv2 = closure->fv2;
  return fp(v1, v2, fv1, fv2);
}

int f_in_c_style(int x, int y, int a, int b) {
  return a * x + b * y;
}

int main() {
  const int a = 3, b = 4;
  Closure_II_II_I closure_f = { f_in_c_style, a, b };
  printf("%d\n", apply_II_II_I(5, 6, &closure_f));
}
