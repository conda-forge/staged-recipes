%PYTHON% -m pip install --no-deps . -vv
if errorlevel 1 exit 1

cd build
bazel clean
cd ..
