#!/usr/bin/env bash
set -euxo pipefail

# Build in-tree intentionally. Upstream generates public headers from TeX sources
# by executing ./tcode from the source tree before building the libraries.
./configure \
  --prefix="${PREFIX}" \
  --disable-static \
  --enable-shared

make -j"${CPU_COUNT:-1}"
make install

# libtool archive files are not useful to conda consumers.
rm -f "${PREFIX}"/lib/*.la

# Compile and run a tiny consumer against the installed public API and all three
# installed TestU01 libraries. This validates generated headers, linking, and the
# runtime loader without running an expensive statistical battery.
cat > conda-forge-smoke.c <<'SMOKE_EOF'
#include <stddef.h>
#include <math.h>
#include <unif01.h>

static double constant_half(void)
{
    return 0.5;
}

int main(void)
{
    unif01_Gen *gen = unif01_CreateExternGen01("conda-forge-smoke", constant_half);
    double value;

    if (gen == NULL) {
        return 1;
    }

    value = unif01_StripD(gen, 0);
    unif01_DeleteExternGen01(gen);

    return fabs(value - 0.5) < 1.0e-12 ? 0 : 1;
}
SMOKE_EOF

"${CC}" ${CPPFLAGS:-} ${CFLAGS:-} conda-forge-smoke.c \
  -I"${PREFIX}/include" \
  -L"${PREFIX}/lib" \
  ${LDFLAGS:-} \
  -ltestu01 -lprobdist -lmylib -lm \
  -o conda-forge-smoke

./conda-forge-smoke
