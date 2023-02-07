set -exou

mkdir -p "${PREFIX}/include/"
mkdir -p "${PREFIX}/lib"

cp -a build/include/flite "${PREFIX}/include/"
if [[ "$target_platform" == linux* ]]; then
  cp -v -P build/lib/lib*.so "${PREFIX}/lib/"
elif [[ "$target_platform" == osx* ]]; then
  cp -v -P build/lib/lib*.dylib "${PREFIX}/lib/"
  rm -v "${PREFIX}"/lib/lib*.*.dylib
fi
