set -x

# Build Go package
export GO111MODULE=on
protoc -I=. --go_out="internal" protobufs/main.proto

# Follow upstream's naming convention, even though it is a little crazy
export GOOS=linux
export GOARCH=amd64
export ext=so
zaber_motion_lib=zaber-motion-lib-${GOOS}-${GOARCH}.${ext}

go build -buildmode=c-shared -o ./build/${zaber_motion_lib}

# Now compile the python bindings
protoc -I=. --python_out="py/zaber_motion/zaber_motion" \
  --plugin="protoc-gen-mypy=tools/protoc-gen-mypy" \
  --mypy_out="py/zaber_motion/zaber_motion" protobufs/main.proto
# without the __init__ file, it won't install correctly
touch py/zaber_motion/zaber_motion/protobufs/__init__.py

cp ./build/${zaber_motion_lib} ./py/bindings_linux/zaber_motion_bindings_linux/.

pushd py/bindings_linux
$PYTHON -m pip install . -vv
popd
pushd py/zaber_motion
$PYTHON -m pip install . -vv
popd
