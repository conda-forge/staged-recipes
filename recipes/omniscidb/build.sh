#!/usr/bin/env bash

set -ex

export EXTRA_CMAKE_OPTIONS=""

# Make sure -fPIC is not in CXXFLAGS (that some conda packages may
# add), otherwise omniscidb server will crash when executing generated
# machine code:
export CXXFLAGS="`echo $CXXFLAGS | sed 's/-fPIC//'`"

# Fixes https://github.com/Quansight/pearu-sandbox/issues/7
#       https://github.com/omnisci/omniscidb/issues/374
export CXXFLAGS="$CXXFLAGS -Dsecure_getenv=getenv"

# Fixes `error: expected ')' before 'PRIxPTR'`
export CXXFLAGS="$CXXFLAGS -D__STDC_FORMAT_MACROS"

# Remove --as-needed to resolve undefined reference to `__vdso_clock_gettime@GLIBC_PRIVATE'
export LDFLAGS="`echo $LDFLAGS | sed 's/-Wl,--as-needed//'`"

export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}"

# Run tests labels:
#   0 - disable building and running sanity tests
#   1 - build and run the sanity tests
#   2 - detect if sanity tests can be run, then set 1, otherwise set 0
export RUN_TESTS=0  # set to 2 when in feedstock

if [[ ! -z "${cuda_compiler_version+x}" && "${cuda_compiler_version}" != "None" ]]
then
    export INSTALL_BASE=opt/omnisci-cuda
    if [[ -z "${CUDA_HOME+x}" ]]
    then
        echo "cuda_compiler_version=${cuda_compiler_version} CUDA_HOME=$CUDA_HOME"
        CUDA_GDB_EXECUTABLE=$(which cuda-gdb || exit 0)
        if [[ -n "$CUDA_GDB_EXECUTABLE" ]]
        then
            CUDA_HOME=$(dirname $(dirname $CUDA_GDB_EXECUTABLE))
        else
            echo "Cannot determine CUDA_HOME: cuda-gdb not in PATH"
            return 1
        fi
    fi
    export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_CUDA=on"
    export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME"
    # Fixes NOTFOUND CUDA_CUDA_LIBRARY
    export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_SYSROOT=$CONDA_BUILD_SYSROOT"

    if [[ "$RUN_TESTS" == "2" ]]
    then
        if [[ -x "$(command -v nvidia-smi)" ]]
        then
            export RUN_TESTS=1
        else
            export RUN_TESTS=0
        fi
    fi
else
    export INSTALL_BASE=opt/omnisci-cpu
    export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_CUDA=off"
    if [[ "$RUN_TESTS" == "2" ]]
    then
        export RUN_TESTS=1
    fi
fi

if [[ "$RUN_TESTS" == "0" ]]
then
   export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_TESTS=off"
else
   export RUN_TESTS=1
   export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_TESTS=on"
fi

export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DBoost_NO_BOOST_CMAKE=on"

mkdir -p build
cd build

cmake -Wno-dev \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX/$INSTALL_BASE \
    -DCMAKE_BUILD_TYPE=release \
    -DMAPD_DOCS_DOWNLOAD=off \
    -DENABLE_AWS_S3=off \
    -DENABLE_FOLLY=off \
    -DENABLE_JAVA_REMOTE_DEBUG=off \
    -DENABLE_PROFILER=off \
    -DPREFER_STATIC_LIBS=off \
    $EXTRA_CMAKE_OPTIONS \
    ..

make -j $CPU_COUNT

if [[ "$RUN_TESTS" == "1" ]]
then
    # Omnisci UDF support uses CLangTool for parsing Load-time UDF C++
    # code to AST. If the C++ code uses C++ std headers, we need to
    # specify the locations of include directories:
    . ${RECIPE_DIR}/get_cxx_include_path.sh
    export CPLUS_INCLUDE_PATH=$(get_cxx_include_path)

    mkdir tmp
    $PREFIX/bin/initdb tmp
    make sanity_tests
    rm -rf tmp
else
    echo "Skipping sanity tests"
fi

make install

# Remove build directory to free about 2.5 GB of disk space
cd -
rm -rf build

cd $PREFIX/$INSTALL_BASE/bin
ln -s initdb omnisci_initdb
ln -s ../startomnisci startomnisci
ln -s ../insert_sample_data omnisci_insert_sample_data
cd -

mkdir -p "${PREFIX}/etc/conda/activate.d"
cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOF
#!/bin/bash

# Avoid cuda and cpu variants of omniscidb in the same environment.
if [[ ! -z "\${PATH_CONDA_OMNISCIDB_BACKUP+x}" ]]
then
  echo "Unset PATH_CONDA_OMNISCIDB_BACKUP(=\${PATH_CONDA_OMNISCIDB_BACKUP}) when activating ${PKG_NAME} from \${CONDA_PREFIX}/${INSTALL_BASE}"
  export PATH="\${PATH_CONDA_OMNISCIDB_BACKUP}"
  unset PATH_CONDA_OMNISCIDB_BACKUP
fi

# Backup environment variables (only if the variables are set)
if [[ ! -z "\${PATH+x}" ]]
then
  export PATH_CONDA_OMNISCIDB_BACKUP="\${PATH:-}"
fi

export PATH="\${PATH}:\${CONDA_PREFIX}/${INSTALL_BASE}/bin"
EOF


mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOF
#!/bin/bash

# Restore environment variables (if there is anything to restore)
if [[ ! -z "\${PATH_CONDA_OMNISCIDB_BACKUP+x}" ]]
then
  export PATH="\${PATH_CONDA_OMNISCIDB_BACKUP}"
  unset PATH_CONDA_OMNISCIDB_BACKUP
fi

EOF

# Free some disk space
rm -v /opt/conda/pkgs/*.tar.bz2
