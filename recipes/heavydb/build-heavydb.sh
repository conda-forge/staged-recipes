#!/usr/bin/env bash

set -ex

export EXTRA_CMAKE_OPTIONS="-GNinja"

export INSTALL_BASE=opt/heavyai
export BUILD_EXT=cpu
export RUN_DBE_TESTS=1

# Set flags
case "$PKG_NAME" in

    heavydb-common)
        export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_IMPORT_PARQUET=OFF"
        ;;

    heavydbe)
        export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_DBE=ON"
        ;;

    pyheavydbe)
        export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_DBE=ON"
        ;;

    heavydb)
        # Make sure -fPIC is not in CXXFLAGS (that some conda packages may
        # add), otherwise heavydb server will crash when executing generated
        # machine code:
        export CXXFLAGS="`echo $CXXFLAGS | sed 's/-fPIC//'`"

        ;;

    *)
        echo "No specific flags set for $PKG_NAME"
        ;;
esac

# Remove --as-needed to resolve undefined reference to `__vdso_clock_gettime@GLIBC_PRIVATE'
export LDFLAGS="`echo $LDFLAGS | sed 's/-Wl,--as-needed//'`"

export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DCMAKE_C_COMPILER=${CC} -DCMAKE_CXX_COMPILER=${CXX}"

# Run tests labels:
#   0 - disable building and running sanity tests
#   1 - build and run the sanity tests
#   2 - detect if sanity tests can be run, then set 1, otherwise set 0
#
# Ideally, this should be 2. However, the available conda-forge CI
# disk space resourses are not sufficient for running the heavydb
# sanity tests in full. Hence we disable the tests:
export RUN_TESTS=0

if [[ ! -z "${cuda_compiler_version+x}" && "${cuda_compiler_version}" != "None" && "$PKG_NAME" != "heavydb-common" ]]
then
    export BUILD_EXT=cuda
    export RUN_DBE_TESTS=0
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

# As clang is used in the build process to compile bytecode,
# we need to make clang aware of the C++ headers provided by
# conda's GCC toolchain.
. ${RECIPE_DIR}/get_cxx_include_path.sh
export CPLUS_INCLUDE_PATH=$(get_cxx_include_path)

mkdir -p build
cd build

# Run configure
case "$PKG_NAME" in

    heavydb | heavydbe | pyheavydbe | heavydb-common)

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

        ;;

    *)
        echo "Nothing configured for $PKG_NAME"
        ;;

esac

# Run build
case "$PKG_NAME" in

    heavydb-common)
        echo "Building heavydb-common"
        ninja QueryEngineFunctionsTargets mapd_java_components generate_cert_target
        ;;

    heavydbe)
        echo "Building heavydbe"
        ninja DBEngine
        ;;

    pyheavydbe)
        echo "Installing pyheavydbe"
        cd Embedded
        $PYTHON -m pip install .
        cd ..
        ;;

    heavydb)
        echo "Building heavydb"
        ninja initheavy heavydb heavysql StreamImporter KafkaImporter
        ;;

    *)
        echo "Nothing build for $PKG_NAME"
        ;;

esac
cd ..

# Run install
case "$PKG_NAME" in

    heavydb-common)
        echo "Installing heavydb-common"
        cmake --install build --component "include" --prefix $PREFIX/$INSTALL_BASE
        cmake --install build --component "doc" --prefix $PREFIX/share/doc/heavyai
        cmake --install build --component "data" --prefix $PREFIX/$INSTALL_BASE
        cmake --install build --component "thrift" --prefix $PREFIX/$INSTALL_BASE
        cmake --install build --component "QE" --prefix $PREFIX/$INSTALL_BASE
        cmake --install build --component "jar" --prefix $PREFIX/$INSTALL_BASE
        cmake --install build --component "Unspecified" --prefix $PREFIX/$INSTALL_BASE

        mkdir -p $PREFIX/include/
        cd $PREFIX/include
        ln -s ../$INSTALL_BASE heavydb
        cd -

        mkdir -p $PREFIX/$INSTALL_BASE/bin
        cd $PREFIX/$INSTALL_BASE/bin
        ln -s ../startheavy startheavy
        ln -s ../insert_sample_data heavydb_insert_sample_data
        cd -

        ;;

    heavydbe)
        echo "Installing heavydbe"
        cmake --install build --component "DBE" --prefix $PREFIX/$INSTALL_BASE

        mkdir -p $PREFIX/lib
        cd $PREFIX/lib
        ln -s ../$INSTALL_BASE/lib/libDBEngine.so .
        cd -

        # create activate/deactivate scripts
        mkdir -p "${PREFIX}/etc/conda/activate.d"
        cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOF
#!/bin/bash

# Backup environment variables (only if the variables are set)
if [[ ! -z "\${HEAVYAI_ROOT_PATH+x}" ]]
then
  export HEAVYAI_ROOT_PATH_BACKUP="\${HEAVYAI_ROOT_PATH:-}"
fi

# HEAVYAI_ROOT_PATH is requires for libDBEngine.so to determine the
# the heavyai root path correctly.
export HEAVYAI_ROOT_PATH=\${CONDA_PREFIX}/${INSTALL_BASE}

EOF

        mkdir -p "${PREFIX}/etc/conda/deactivate.d"
        cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOF
#!/bin/bash

# Restore environment variables (if there is anything to restore)
if [[ ! -z "\${HEAVYAI_ROOT_PATH_BACKUP+x}" ]]
then
  export HEAVYAI_ROOT_PATH="\${HEAVYAI_ROOT_PATH_BACKUP}"
  unset HEAVYAI_ROOT_PATH_BACKUP
fi

EOF
        ;;

    heavydb)
        echo "Installing heavydb"
        cmake --install build --component "exe" --prefix $PREFIX/$INSTALL_BASE

        cd $PREFIX/$INSTALL_BASE/bin
        cd -

        # create activate/deactivate scripts
        mkdir -p "${PREFIX}/etc/conda/activate.d"
        cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOF
#!/bin/bash

# Avoid cuda and cpu variants of heavydb in the same environment.
if [[ ! -z "\${PATH_CONDA_HEAVYDB_BACKUP+x}" ]]
then
  echo "Unset PATH_CONDA_HEAVYDB_BACKUP(=\${PATH_CONDA_HEAVYDB_BACKUP}) when activating ${PKG_NAME} from \${CONDA_PREFIX}/${INSTALL_BASE}"
  export PATH="\${PATH_CONDA_HEAVYDB_BACKUP}"
  unset PATH_CONDA_HEAVYDB_BACKUP
fi

# Backup environment variables (only if the variables are set)
if [[ ! -z "\${PATH+x}" ]]
then
  export PATH_CONDA_HEAVYDB_BACKUP="\${PATH:-}"
fi

export PATH="\${CONDA_PREFIX}/${INSTALL_BASE}/bin:\${PATH}"

EOF

        mkdir -p "${PREFIX}/etc/conda/deactivate.d"
        cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOF
#!/bin/bash

# Restore environment variables (if there is anything to restore)
if [[ ! -z "\${PATH_CONDA_HEAVYDB_BACKUP+x}" ]]
then
  export PATH="\${PATH_CONDA_HEAVYDB_BACKUP}"
  unset PATH_CONDA_HEAVYDB_BACKUP
fi

EOF

        ;;

    *)
        echo "Nothing installed for $PKG_NAME"
        ;;
esac

# Run tests
case "$PKG_NAME" in

    heavydb)
        echo "Testing heavydb"
        if [[ "$RUN_TESTS" == "1" ]]
        then
            echo "Sanity tests"
            cd build
            mkdir tmp
            $PREFIX/$INSTALL_BASE/bin/initheavy tmp
            make sanity_tests
            rm -rf tmp
            cd -
        else
            echo "Skipping sanity tests"
        fi
        ;;

    pyheavydbe)
        echo "Testing pyheavydbe"
        if [[ "$RUN_DBE_TESTS" == "1" ]]
        then
            echo "Starting Python DBE tests"
            cd Embedded/test
            $PYTHON test_fsi.py
            $PYTHON test_readcsv.py
            cd -
        else
            echo "Skipping Python DBE tests"
        fi
        ;;

    *)
        echo "Nothing tested for $PKG_NAME"
        ;;
esac

# Remove build directory to free about 2.5 GB of disk space
rm -rf build
