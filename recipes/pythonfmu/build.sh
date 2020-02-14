mkdir tmp-build
cd tmp-build
cmake ../pythonfmu/pythonfmu-export -DCMAKE_PREFIX_PATH:FILEPATH=$PREFIX -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
cd ..

$PYTHON -m pip install . -vv
