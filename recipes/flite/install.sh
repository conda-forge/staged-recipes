set -exou

mkdir -p "${PREFIX}/lib"

if [[ "$target_platform" == linux* ]]; then
  cp -v -P build/lib/lib*.so.* "${PREFIX}/lib/"
elif [[ "$target_platform" == osx* ]]; then
  ls -la build/lib/
  cp -v -P build/lib/lib*.*.dylib "${PREFIX}/lib/"
fi
