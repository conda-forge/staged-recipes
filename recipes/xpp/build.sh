
# They overwrite CFLAGS so unless we redefine them, they will use some
# wonky defaults for CC and CFLAGS
export CFLAGS="$CFLAGS -DHAVEDLL -DMYSTR1=8.0 -DMYSTR2=0"

make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" -j${CPU_COUNT}

mkdir -p $PREFIX/bin
install xppaut $PREFIX/bin/.

