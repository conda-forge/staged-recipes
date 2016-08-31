#!/usr/bin/env bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  # other
  libext=".dylib"
  export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  export LINKFLAGS="${LDFLAGS}"
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"
else
  libext=".so"
  export LDFLAGS=" ${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
  export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
  export LINKFLAGS="${LDFLAGS}"
  skiprpath=""
fi

# Install Cycamore
export VERBOSE=1
${PYTHON} install.py --prefix="${PREFIX}" \
  --build_type="Release" \
  --dont-allow-milps \
  --deps-root="${PREFIX}" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
  ${skiprpath} \
  --clean -j "${CPU_COUNT}"
