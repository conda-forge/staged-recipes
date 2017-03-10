#! /usr/bin/env bash

cat > main.cpp <<- EOF
#include <fst/fstlib.h>

int main() {
  fst::StdVectorFst a;
  a.AddState();
  a.SetStart(0);
  a.AddArc(0, fst::StdArc(1, 1, 0, 1));
  a.AddState();
  a.SetFinal(1, 0);

  fst::Closure(&a, fst::CLOSURE_STAR);

  fst::StdVectorFst b;
  b.AddState();
  b.SetStart(0);
  b.AddArc(0, fst::StdArc(2, 2, 0, 1));
  b.AddState();
  b.SetFinal(1, 0);

  fst::Concat(&a, b);
}
EOF

$CXX -std=c++11 -lfst -I${PREFIX}/include -L${PREFIX}/lib main.cpp -o example
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PREFIX}/lib
./example
