set -ex

cd build
cmake --install .

rm "${PREFIX}"/lib/libjxl*.a

if [[ "${PKG_NAME}" == "libjxl" ]]
then
  rm "${PREFIX}"/bin/cjxl
  rm "${PREFIX}"/bin/djxl
  rm "${PREFIX}"/bin/cjpeg_hdr
  rm "${PREFIX}"/bin/jxlinfo
fi
