#!/usr/bin/env bash

set -x
set -e

if [ "$(uname)" == "Darwin" ]; then
  SHARED="-dynamiclib"
elif [ "$(uname)" == "Linux" ]; then
  SHARED="-shared"
fi

cd src

${CXX} ${CXXFLAGS} -D NDEBUG -D __cmd_jigsaw jigsaw.cpp -o jigsaw

${CXX} ${CXXFLAGS} -D NDEBUG -D __cmd_tripod jigsaw.cpp -o tripod

${CXX} ${CXXFLAGS} ${SHARED} -D NDEBUG -D __lib_jigsaw jigsaw.cpp -o \
    libjigsaw${SHLIB_EXT}

install -d ${PREFIX}/bin/
for exec in jigsaw tripod
do
  install -m 755 ${exec} ${PREFIX}/bin/
done

install -d ${PREFIX}/lib/
install -m 644 libjigsaw${SHLIB_EXT} ${PREFIX}/lib/

install -d ${PREFIX}/include/
install -m 644 ../inc/*.h ${PREFIX}/include/

# unit tests
cd ../uni

for test in 1 2 3 4 5
do
  ${CC} ${CFLAGS} test_${test}.c ${LDFLAGS} -ljigsaw -o test_${test}
  ./test_${test}
done
