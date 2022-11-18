#! /bin/sh -ev

autoreconf --force --install

./configure --prefix=$(pwd)/build --exec-prefix=$(pwd)/build  --enable-examples

if [ -z "$NCPU" ]; then
    NCPU=$(lscpu --parse | egrep -v '^#' | wc -l || echo 1)
fi
echo "NCPU=${NCPU}"
if [ -z "$MAKEFLAGS" ]; then
    export MAKEFLAGS=-j${NCPU}
fi
echo "MAKEFLAGS=${MAKEFLAGS}"

make clean

make EXTRA_FLAGS="-O5 -DCOLPACK_DEBUG_LEVEL=0"

exit 0

# Alternative configuration:

# ./configure --prefix=$(pwd)/build --exec-prefix=$(pwd)/build  --enable-examples --enable-openmp

# Misc commentary.

# The sh -e option exits on failure, avoiding the need to guard commands.

# The sh -v option echos commands before executing them, avoiding the
# need to do so manually.

# I'm dubious about
#  (a) invoking "make" here at all,
#  (b) using make option -j instead of leaving that to the user, via ${MAKEFLAGS},
#  (c) using make option -j instead of -jX where X = #CPUs.
# The "if" stanza addresses (c), and partially addresses (b) by avoiding overriding
# or augmenting ${MAKEFLAGS} if it is already set.
