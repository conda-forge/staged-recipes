case $( uname -s ) in
 Darwin)
  alias vwlibtool=glibtoolize
  if [ -z $AC_PATH ]; then
    if [ -d /opt/local/share ]; then
      AC_PATH="/opt/local/share"
    else
      AC_PATH="/usr/local/share"
    fi
  fi
  ;;
 Linux)
  AC_PATH=/usr/share
  alias vwlibtool=libtoolize
  ;;
 *)
  alias vwlibtool=libtoolize
  ${AC_PATH:=/usr/share}
  ;;
esac

vwlibtool -f -c && aclocal -I ./acinclude.d -I $AC_PATH/aclocal && autoheader && touch README && automake -ac -Woverride && autoconf

ls $PREFIX/include
ls $PREFIX/lib

rm -f $PREFIX/lib/libboost_program_options.dylib
rm -f $PREFIX/lib/libboost_program_options.so

./configure --prefix=$PREFIX --with-zlib=$PREFIX || cat config.log
make install -j${CPU_COUNT} 

make -j${CPU_COUNT}
