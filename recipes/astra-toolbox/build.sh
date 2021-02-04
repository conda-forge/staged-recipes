#!/bin/sh

case `uname` in
  Darwin*)
    CC="gcc -stdlib=libstdc++"
    ;;
esac

cd $SRC_DIR/python/
CPPFLAGS="-DASTRA_CUDA -DASTRA_PYTHON $CPPFLAGS -I$SRC_DIR/ -I$SRC_DIR/include" CC=$CC python ./builder.py build install
