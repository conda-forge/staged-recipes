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

mkdir -p /usr/local/lib
mkdir -p /usr/local/include

cp $PREFIX/lib/libz.a /usr/local/lib
cp $PREFIX/include/zlib.h /usr/local/include

./configure --prefix=$PREFIX --with-zlib=$PREFIX
make install -j${CPU_COUNT} 

make -j${CPU_COUNT}
