// The volatile function pointer forces the compiler to emit a real
// reference to an exported symbol, so the linker must resolve it from
// libsuperiso and the loader must map the shared library at runtime.
#include <stdio.h>

#include <superiso/include.h>

int main(void) {
  // Btaunu is declared in <superiso/include.h> and defined in libsuperiso.
  double (*volatile fp)(struct parameters *) = &Btaunu;
  printf("libsuperiso link test: Btaunu %s\n", fp ? "resolved" : "missing");
  return fp ? 0 : 1;
}
