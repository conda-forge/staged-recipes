%PYTHON% -m pip install . -vv --no-deps
if errorlevel 1 exit 1

cd build
bazel clean
cd ..
