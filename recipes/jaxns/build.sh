#/usr/bin/env bash

set -ex

for file in requirements.txt requirements-examples.txt requirements-tests.txt requirements-experimental.txt
do
   if ! -f $file
   then
      echo "#" > $file
   fi
done

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
