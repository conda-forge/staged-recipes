$CC ./pstree.c -o pstree

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/man/man1/

cp pstree $PREFIX/bin/
cp pstree.1 $PREFIX/share/man/man1/