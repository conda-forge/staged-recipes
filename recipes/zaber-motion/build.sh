set -x
SHORT_OS_STR=$(uname -s)
cd src/zaber-motion

# Build Go package
export GO111MODULE=on
protoc -I=. --go_out="internal" protobufs/main.proto

zaber_motion_libname=zaber-motion-lib-${GOOS}-${GOARCH}
zaber_motion_lib=${zaber_motion_libname}${SHLIB_EXT}
zaber_motion_header=${zaber_motion_libname}.h
go build -buildmode=c-shared -o ./build/${zaber_motion_lib}

# Copy the files in the correct locations
cp build/${zaber_motion_lib} $PREFIX/lib/.
cp build/${zaber_motion_header} $PREFIX/include/.

# Now compile the python bindings
protoc -I=. --python_out="py/zaber_motion/zaber_motion" \
  --plugin="protoc-gen-mypy=tools/protoc-gen-mypy" \
  --mypy_out="py/zaber_motion/zaber_motion" protobufs/main.proto

# without the __init__ file, it won't install correctly
touch py/zaber_motion/zaber_motion/protobufs/__init__.py

pushd py/zaber_motion
$PYTHON -m pip install . -vv
popd
