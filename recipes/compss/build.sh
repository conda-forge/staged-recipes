#!/usr/bin/env bash
set -x

export JAVA_HOME=$BUILD_PREFIX/lib/jvm
export BOOST_INCLUDE_DIR="${BUILD_PREFIX}/include"
export BOOST_LIBRARY_DIR="${BUILD_PREFIX}/lib"
export CFLAGS="$CFLAGS -std=c11 -D_GNU_SOURCE"
export CXXFLAGS="$CXXFLAGS -std=c++11 -I$BOOST_INCLUDE_DIR -I$BUILD_PREFIX/lib/jvm/include -I$BUILD_PREFIX/lib/jvm/include/linux -D_GNU_SOURCE -Wno-write-strings"

echo Package workdir: "${PREFIX} $SRC_DIR"
# Run the COMPSs install script
./install ${PREFIX}/lib/COMPSs

# Link the user and utils scripts to bin
mkdir -p ${PREFIX}/bin
ln -sf ${PREFIX}/lib/COMPSs/Runtime/scripts/user/* ${PREFIX}/bin/
ln -sf ${PREFIX}/lib/COMPSs/Runtime/scripts/utils/* ${PREFIX}/bin/
# Move the python bindings to site-packages
mkdir -p ${SP_DIR}/pycompss/
mv ${PREFIX}/lib/COMPSs/Bindings/python/3/* ${SP_DIR}
ln -sf ${PREFIX}/lib/COMPSs/Bindings/bindings-common/lib/libbindings_common.so.0.0.0 ${PREFIX}/lib/libbindings_common.so.0

# Create the activation and deactivation scripts for the environment variables
{ cat <<EOF
#!/bin/bash
export COMPSS_HOME_OLD="\${COMPSS_HOME:-}"
export COMPSS_HOME="\$CONDA_PREFIX/lib/COMPSs"

export LD_LIBRARY_PATH_OLD="\${LD_LIBRARY_PATH:-}"
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$COMPSS_HOME/Bindings/bindings-common/lib:\$CONDA_PREFIX/lib/jvm/lib/server

export CLASSPATH_OLD="\${CLASSPATH:-}"
export CLASSPATH="\${CLASSPATH:+\$CLASSPATH:}\$COMPSS_HOME/Runtime/compss-engine.jar"
EOF
} > "${PREFIX}/etc/conda/activate.d/compss_activate.sh"

{ cat <<EOF
#!/bin/bash
export COMPSS_HOME="\${COMPSS_HOME_OLD:-}"
unset COMPSS_HOME_OLD

export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH_OLD:-}"
unset LD_LIBRARY_PATH_OLD

export CLASSPATH="\${CLASSPATH_OLD:-}"
unset CLASSPATH_OLD
EOF
} > "${PREFIX}/etc/conda/deactivate.d/compss_deactivate.sh"

chmod +x "${PREFIX}/etc/conda/activate.d/compss_activate.sh"
chmod +x "${PREFIX}/etc/conda/deactivate.d/compss_deactivate.sh"