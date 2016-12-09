CXXFLAGS = -std=c++11 -g -fPIC 
LDDFLAGS = -std=c++11 -g -bundle 

PY2ROOT = ${PREFIX}
BOOST2ROOT = ${PREFIX}
PY2FLAGS = -I${PY2ROOT}/lib/python2.7/site-packages/numpy/core/include -I${PY2ROOT}/include/python2.7 -I${BOOST2ROOT}/include
PY2LIBS = ${BOOST2ROOT}/lib/libboost_python.dylib ${PY2ROOT}/lib/python2.7/config/libpython2.7.a

all: test2.so test

test: test2.so
	 ./run.sh

test2.so: Makefile test.cpp
	clang++ ${CXXFLAGS} ${PY2FLAGS} -DMODULE_NAME=test2 -c test.cpp -o test2.o
	clang++ ${LDDFLAGS} -o test2.so test2.o  ${PY2LIBS}


clean:
	rm *.o *.so *.log
