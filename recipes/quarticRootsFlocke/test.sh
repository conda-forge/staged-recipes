#!/usr/bin/bash
if [ -n "${OSX_ARCH}" ];
then
  PLATFORM=osx
else
  PLATFORM=linux
fi

test -f "${PREFIX}/lib/libQuarticStatic.a"
test -f "${PREFIX}/include/Quartic/PolynomialRoots.hh"
${CXX} ${CXXFLAGS} \
  -L"${PREFIX}/lib" \
  -I "${PREFIX}/include/Quartic" \
  "${RECIPE_DIR}/test_linkage.cpp" \
  -o test_linkage \
  -Wall \
  -Wextra \
  -Werror \
  -lQuarticStatic
./test_linkage

cmake \
    -B build \
    -S "${RECIPE_DIR}/test-link-quarticRootsFlocke" \
    -G Ninja
cmake --build build
./build/test_linkage
