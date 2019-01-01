#!bin/bash
set -ex

echo "pymunk build.sh"
echo 1 $LD
echo 2 $LDFLAGS
echo 3 $PREFIX
echo 4 ${PREFIX}
echo 5 ${!PREFIX}
echo 6 ${LDFLAGS/'$PREFIX'/$PREFIX}
export LDFLAGS=${LDFLAGS/'$PREFIX'/$CONDA_PREFIX}
echo 7 $LDFLAGS
export PYMUNK_PREFIX="$PREFIX"
echo 8 $LDFLAGS
echo 9 $PYMUNK_PREFIX
echo "......"
echo "$PREFIX" >> "var.tmp"
cat var.tmp
echo 9 $CONDA_PREFIX
if [[ $(uname) == "Darwin" ]]; then
  export LD=clang
else  
  export LD=gcc
fi
$PYTHON -m pip install . --no-deps -vv
