#!/usr/bin/bash
test -f "${PREFIX}/lib/libQuartic_linux_static.a"
test -f "${PREFIX}/include/Quartic/PolynomialRoots.hh"
${CXX} ${CXXFLAGS} -L"${PREFIX}/lib" -I "${PREFIX}/include/Quartic" "${RECIPE_DIR}/test_linkage.cpp" -o test_linkage -Wall -Wextra -Werror -lQuartic_linux_static
./test_linkage
