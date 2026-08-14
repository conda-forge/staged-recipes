#!/usr/bin/env bash
set -euxo pipefail

# PractRand 0.96 ships src/platform_specifics.cpp with CRLF line endings.
# Normalize that file before applying our LF-formatted portability patch.
sed -i 's/\r$//' src/platform_specifics.cpp
patch -p1 < "${RECIPE_DIR}/fix-non-x86-high-resolution-time.patch"

"${CXX}" ${CPPFLAGS:-} ${CXXFLAGS:-} -Iinclude -std=gnu++11 -pthread \
  -c src/*.cpp src/RNGs/*.cpp src/RNGs/other/*.cpp

"${AR:-ar}" rcs libPractRand.a ./*.o

for tool in RNG_test RNG_output RNG_benchmark; do
  "${CXX}" ${CPPFLAGS:-} ${CXXFLAGS:-} -Iinclude -std=gnu++11 \
    "tools/${tool}.cpp" ${LDFLAGS:-} libPractRand.a -pthread -o "${tool}"
done

install -d "${PREFIX}/bin"
install -m 0755 RNG_test RNG_output RNG_benchmark "${PREFIX}/bin/"
