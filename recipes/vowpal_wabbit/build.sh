BOOST_DIR_ARG=$LIBRARY_PREFIX/lib

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

./configure "$@" $BOOST_DIR_ARG --prefix=$LIBRARY_PREFIX --with-zlib=$LIBRARY_PREFIX
make install -j${CPU_COUNT}