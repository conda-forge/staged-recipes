set -ex

pushd zaber-motion-lib

# Look at gulpfil.js, protobuf_py
protocGenMypy=tools/protoc-gen-mypy
protoc -I=. --python_out="py/zaber_motion/zaber_motion" \
    --plugin="protoc-gen-mypy=${protocGenMypy}" \
    --mypy_out="py/zaber_motion/zaber_motion" protobufs/main.proto

touch py/zaber_motion/zaber_motion/protobufs/__init__.py


pushd py/zaber_motion
${PYTHON} -m pip install . -vv --no-build-isolation --no-deps
popd

popd

pushd bindings
# TODO: make this dependent on OSX/Linux/ARM
SHORT_OS_STR=$(uname -s)
if [ "${SHORT_OS_STR:0:5}" == "Linux" ]; then
    rm -f zaber_motion_bindings_linux/zaber-motion-lib-linux-386.so
    if [ `uname -m` == "x86_64" ]; then
        rm -f zaber_motion_bindings_linux/zaber-motion-lib-linux-arm.so
    else  # == "arm"
        rm -f zaber_motion_bindings_linux/zaber-motion-lib-linux-amd64.so
    fi
fi

${PYTHON} -m pip install . -vv --no-build-isolation --no-deps
popd
