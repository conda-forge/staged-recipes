#!bin/bash
set -ex

echo "pymunk build.sh"
echo 1 $LD
echo 2 $LDFLAGS
echo 3 $PREFIX
echo 4 ${PREFIX}
echo 5 ${!PREFIX}
echo "......"
echo 9 $CONDA_PREFIX
if [[ $(uname) == "Darwin" ]]; then
  export LD=clang
else  
  export LD=gcc
fi
$PYTHON -c "import os; print('os', os.environ['PREFIX'])"
$PYTHON -c "import os; print('os', os.environ['LDFLAGS'])"
$PYTHON -c "import os; print('os', os.environ['PREFIX'].split('_'))"
$PYTHON -m pip install . --no-deps -vv
