set -e -x

CHOST=$(${SRC_DIR}/.build/*-*-*-*/build/build-cc-gcc-final/gcc/xgcc -dumpmachine)

pushd ${SRC_DIR}/.build/${CHOST}/build/build-duma
  make prefix=${PREFIX} HOSTCC=$(uname -m)-build_pc-linux-gnu-gcc CC=${CHOST}-gcc CXX=${CHOST}-g++ RANLIB=${CHOST}-ranlib OS=linux DUMA_CPP=1 install
popd
