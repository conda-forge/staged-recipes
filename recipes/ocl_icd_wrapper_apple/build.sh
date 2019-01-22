autoreconf -i
chmod +x configure
./configure
make LDFLAGS+="-framework OpenCL"

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/etc/OpenCL/vendors

cp .libs/libocl_icd_wrapper.0.dylib ${PREFIX}/lib/libocl_icd_wrapper_apple.dylib
${INSTALL_NAME_TOOL} -id ${PREFIX}/lib/libocl_icd_wrapper_apple.dylib ${PREFIX}/lib/libocl_icd_wrapper_apple.dylib
${OTOOL} -L ${PREFIX}/lib/libocl_icd_wrapper_apple.dylib

echo ${PREFIX}/lib/libocl_icd_wrapper_apple.dylib > ${PREFIX}/etc/OpenCL/vendors/apple.icd
