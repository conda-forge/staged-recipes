rm -rf src/socketify/*.so
rm -rf src/socketify/*.dll

pushd src/socketify/native
CC="${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS}"
CXX="${CXX} ${CPPFLAGS} ${CXXFLAGS} ${LDFLAGS}"
if [[ "$target_platform" == "linux-"* ]]; then
  make linux
elif [[ "$target_platform" == "osx-64" ]]; then
  make macos
elif [[ "$target_platform" == "osx-arm64" ]]; then
  make macos-arm64
fi
popd
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
