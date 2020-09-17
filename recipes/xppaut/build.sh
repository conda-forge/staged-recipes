set -ex
# They overwrite CFLAGS so unless we redefine them, they will use some
# wonky defaults for CC and CFLAGS
export CFLAGS="$CFLAGS -DHAVEDLL -DMYSTR1=8.0 -DMYSTR2=0 -DAUTO -DCVODE_YES"

if [ "${SHORT_OS_STR}" == "Darwin" ]; then
    export CFLAGS="$CFLAGS -DMACOSX"
fi

make CC=$CC CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" -j${CPU_COUNT}

mkdir -p $PREFIX/bin
install xppaut $PREFIX/bin/.
