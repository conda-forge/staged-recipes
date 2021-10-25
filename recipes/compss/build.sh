#!/usr/bin/env bash
set -e
#export JAVA_HOME=$("/usr/libexec/java_home");
echo ${CONDA_PREFIX}
export JAVA_HOME=${CONDA_PREFIX}
/bin/uname -a
java -version
echo JAVA: ${JAVA_HOME}
# Typically $GXX is set by activate.d in conda
# based on our compiler('cxx') dependency
# https://conda.io/docs/user-guide/tasks/build-packages/compiler-tools.html

#export INCLUDE_PATH="${PREFIX}/include/:${PREFIX}/include/bamtools/"
#export LIBRARY_PATH="${PREFIX}/lib"
#export LD_LIBRARY_PATH="${PREFIX}/lib"
export BOOST_INCLUDE_DIR="${PREFIX}/include"
export BOOST_LIBRARY_DIR="${PREFIX}/lib"
#export LIBS='-lboost_regex -lboost_system -lboost_filesystem -lboost_program_options -lboost_filesystem -lboost_timer'
#export CXX_INCLUDE_PATH=${PREFIX}/include
#export CPP_INCLUDE_PATH=${PREFIX}/include
#export CXX=g++
#export CC=gcc
#export LIBTOOLIZE=glibtoolize
#export CXXFLAGS="-g -O2"
export CXXFLAGS="-I$BOOST_INCLUDE_DIR"
#export LDFLAGS="-rpath ${PREFIX}/lib"

#export CFLAGS="-I$PREFIX/include"

# Make sure only Python3 bindings are installed to not
# accidentally hit /usr/bin/python2 from the base image
#sed -i 's,Bindings/python false,Bindings/python false false python3,' install

echo Package workdir: "${PREFIX} $SRC_DIR"
# Run the COMPSs install script
./install -T -A ${PREFIX}

#export TIMES=$("sed 's/.*_\(.*\)\/.*/\1/' <<< \"${SRC_DIR}\"")
TIMES=$(sed 's/\(^.*_\)\(.*\)\(\/.*$\)/\2/' <<< ${SRC_DIR})
#echo timestamp:${TIMES}
#sed -i 's/TIMES/'"${TIMES}"'/g' ${RECIPE_DIR}/post-link.sh


# TODO: Set up equivalent of /etc/profile.d/compss.sh
# in ./etc/conda/activate.d
mkdir -p "${PREFIX}/etc/conda/activate.d"
    cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/compss_activate.sh"
