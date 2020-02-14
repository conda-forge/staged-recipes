mkdir tmp-build
cd tmp-build
cmake ../pythonfmu/pythonfmu-export -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
cd ..

$PYTHON -m pip install . -vv
