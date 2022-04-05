make CC=$CC CXX=$CXX GUI=no all

mkdir -p $PREFIX/{bin,lib,include}

find linux/ -type f -executable -exec cp {} ${PREFIX}/bin/ \;
find linux/ -name '*so' -or -name '*.a' -exec cp {} ${PREFIX}/lib/ \;
cp -r dim/* ${PREFIX}/include/

