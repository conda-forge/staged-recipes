set -ex

cd zaber-motion-lib

rem Look at gulpfil.js, protobuf_py
protoc -I=. --python_out="py/zaber_motion/zaber_motion" ^
    --plugin="protoc-gen-mypy=tools\protoc-gen-mypy" ^
    --mypy_out="py/zaber_motion/zaber_motion" protobufs\main.proto

echo.> py\zaber_motion\zaber_motion\protobufs\__init__.py


cd py\zaber_motion
%PYTHON% -m pip install . -vv --no-build-isolation --no-deps
cd ..

cd ..

cd bindings
%PYTHON% -m pip install . -vv --no-build-isolation --no-deps
cd ..
