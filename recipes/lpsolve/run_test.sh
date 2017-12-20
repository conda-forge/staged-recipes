# test the command line interface
lp_solve -mps plan.mps

# compile a small program against the library
gcc -I $PREFIX/include -L $PREFIX/lib demo.c -o demo -llpsolve55

# Required on OS X to resolve @rpath/./liblpsolve55.dylib
# If this was a real program use install_name_tool to fix the linkage
export LD_LIBRARY_PATH=$PREFIX/lib

# test the compiled program
./demo
