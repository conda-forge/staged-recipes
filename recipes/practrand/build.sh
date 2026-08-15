#!/usr/bin/env bash
set -euxo pipefail

"${CXX}" ${CPPFLAGS:-} ${CXXFLAGS:-} -Iinclude -std=gnu++11 -pthread \
  -c src/*.cpp src/RNGs/*.cpp src/RNGs/other/*.cpp

"${AR:-ar}" rcs libPractRand.a ./*.o

for tool in RNG_test RNG_output RNG_benchmark; do
  "${CXX}" ${CPPFLAGS:-} ${CXXFLAGS:-} \
    -Iinclude -Itools -std=gnu++11 \
    "tools/${tool}.cpp" \
    ${LDFLAGS:-} libPractRand.a -pthread \
    -o "${tool}"
done

"${CXX}" ${CPPFLAGS:-} ${CXXFLAGS:-} \
  -Iinclude -Itools -I"${PREFIX}/include" -std=gnu++11 \
  tools/RNG_to_TestU01.cpp \
  ${LDFLAGS:-} libPractRand.a \
  -L"${PREFIX}/lib" \
  -ltestu01 -lprobdist -lmylib -lm \
  -pthread \
  -o RNG_to_TestU01

install -d "${PREFIX}/bin"
install -m 0755 \
  RNG_test \
  RNG_output \
  RNG_benchmark \
  RNG_to_TestU01 \
  "${PREFIX}/bin/"
