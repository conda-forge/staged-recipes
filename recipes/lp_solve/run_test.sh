lp_solve -h

cc -I ${PREFIX}/include -L ${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib -o demo demo.c -llpsolve55
./demo

