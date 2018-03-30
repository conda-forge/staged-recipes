set -x
if [ ! -z ${LIBRARY_PREFIX+x} ]; then
  PREFIX=$LIBRARY_PREFIX/usr make git-secret install
else
  make git-secret install
fi
