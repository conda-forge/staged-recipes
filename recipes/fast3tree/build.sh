#!/usr/bin/env

$PYTHON -m pip install . -vv

# you have to import the code to force it to compile the libraries
# that's fun
# do in a weird dir to avoid importing the local copy
mkdir blah
pushd blah
for dim in 2 3 4 5 6; do
  for tp in "True" "False"; do
    $PYTHON -c "from fast3tree.make import make_lib; make_lib(${dim}, ${tp})"
  done
done
popd
