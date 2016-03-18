cc -I $PREFIX/include -L $PREFIX/lib test.c -lglpk -o test.out
# Required on OS X to resolve @rpath/./libglpk.40.dylib
# If this was a real program use install_name_tool to fix the linkage
export LD_LIBRARY_PATH=$PREFIX/lib
./test.out
