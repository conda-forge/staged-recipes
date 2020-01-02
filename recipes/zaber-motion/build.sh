set -x
SHORT_OS_STR=$(uname -s)

# Follow upstream's naming convention, even though it is a little crazy
# TODO: detect arm build correctly when desired.
# Look at the function build_go_temp in their `gulpfile.js`
# to follow their convention
if [ "${SHORT_OS_STR:0:5}" == "Linux" ]; then
  GOOS=linux
  GOARCH=amd64
fi
if [ "${SHORT_OS_STR}" == "Darwin" ]; then
  GOOS=darwin
  GOARCH=amd64
fi

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
