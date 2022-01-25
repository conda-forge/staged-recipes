#!/bin/bash

# catch2 uses features only available in osx >=10.12
export MACOSX_DEPLOYMENT_TARGET="10.12"

# build test files
mkdir "test/build"
cd "test/build"

cmake -G "Ninja" \
  -DCMAKE_BUILD_TYPE=Release \
  ..

cmake --build .
ctest

# run python tests
pytest ..


cd $SRC_DIR

# build example files
mkdir "example/build"
cd "example/build"

cmake -G "Ninja" \
  -DCMAKE_BUILD_TYPE=Release \
  ..

cmake --build .
ctest

cd ..
python example_reader.py
python example_writer.py