#!/usr/bin/env bash

set -x
set -e

cd src

${CXX} -std=c++11 -pedantic -Wall -s -O3 -flto -D NDEBUG -D __cmd_jigsaw \
    -static-libstdc++ jigsaw.cpp -o jigsaw

${CXX} -std=c++11 -pedantic -Wall -s -O3 -flto -D NDEBUG -D __cmd_tripod \
    -static-libstdc++ jigsaw.cpp -o tripod

${CXX} -std=c++11 -pedantic -Wall -O3 -flto -fPIC -D NDEBUG -D __lib_jigsaw \
    -static-libstdc++ jigsaw.cpp -shared -o libjigsaw.so

install -d ${PREFIX}/bin/
for exec in jigsaw tripod
do
  install -m 755 ${exec} ${PREFIX}/bin/
done

install -d ${PREFIX}/lib/
install -m 644 libjigsaw.so ${PREFIX}/lib/

install -d ${PREFIX}/include/
install -m 644 ../inc/*.h ${PREFIX}/include/

# unit tests
cd ../uni

for test in 1 2 3 4 5
do
  ${CC} -Wall test_${test}.c -Xlinker -rpath ${PREFIX}/lib -L ${PREFIX}/lib \
      -ljigsaw -o test_${test}
  ./test_${test}
done
