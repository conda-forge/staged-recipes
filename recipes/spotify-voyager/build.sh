#!/bin/bash

set -ex

cd python
rm -rf src/cpp
cp -r ../cpp src/

sed -i.bak 's/version = "2.0.10"/version = "2.1.1"/' pyproject.toml
sed -i.bak 's/m.attr("version") = nb::make_tuple(2, 1, 0);/m.attr("version") = nb::make_tuple(2, 1, 1);/' src/bindings.cpp
rm -f pyproject.toml.bak src/bindings.cpp.bak

export CMAKE_GENERATOR=Ninja
"${PYTHON}" -m pip install . -vv --no-deps --no-build-isolation
