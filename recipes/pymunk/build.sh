#!bin/sh
set -ex

echo "pymunk build.sh"
echo $LD
echo $LDFLAGS
echo $PREFIX
echo ${!PREFIX}
echo ${LDFLAGS/'$PREFIX'/$PREFIX}
# export LDFLAGS=${LDFLAGS/'$PREFIX'/$PREFIX}
echo $LDFLAGS
# export LDFLAGS="$LDFLAGS"
echo $LDFLAGS
if [[ $(uname) == "Darwin" ]]; then
  export LD=clang
else
  export LD=gcc
fi
$PYTHON -m pip install . --no-deps -vv
