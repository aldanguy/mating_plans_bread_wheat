#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include <math.h>
/* #include <stdio.h> */

value ml_erf(value a)
{
  return(caml_copy_double(erf(Double_val(a))));
}

value ml_erfc(value a)
{
  return(caml_copy_double(erfc(Double_val(a))));
}
