#!/bin/bash
set -euf

pushd src/github.com/sylabs/${PKG_NAME}

# Create a C and CPP compiler for singularity
cat > singularity-cc <<_EOF
#!/usr/bin/env bash
exec $CC -I${PREFIX}/include -L${PREFIX}/lib \$@
_EOF
chmod 755 singularity-cc

cat > singularity-cxx <<_EOF
#!/usr/bin/env bash
exec ${CXX:-/bin/false}- -I${PREFIX}/include -L${PREFIX}/lib \$@
_EOF
chmod 755 singularity-cxx

# configure
./mconfig \
  -p $PREFIX \
  -c "${PWD}/singularity-cc" \
  -x "${PWD}/singularity-cxx"

# build
pushd builddir
export LD_LIBRARY_PATH=${PREFIX}/lib
make

# install
make install

# Add post-install script with message on how to grant the -suid piece
cp $RECIPE_DIR/post-link.sh $PREFIX/bin/.$PKG_NAME-post-link.sh

# Make Empty session dir
mkdir -p $PREFIX/var/singularity/mnt/session
touch $PREFIX/var/singularity/mnt/session/.mkdir
