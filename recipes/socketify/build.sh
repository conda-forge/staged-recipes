pushd src/socketify/native
if [[ "$target_platform" == "linux-"* ]]; then
  make linux
elif [[ "$target_platform" == "osx-64" ]]; then
  make macos
elif [[ "$target_platform" == "osx-arm64" ]]; then
  make macos-arm64
fi
popd
$PYTHON -m pip install . -vv --no-deps --no-build-isolation
