cd ${SRC_DIR}/lib/

ar -x cspice.a
gcc -shared -fPIC -lm *.o -o libcspice.so

cp libcspice.so ${PREFIX}/lib
