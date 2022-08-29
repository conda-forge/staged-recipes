#!/usr/bin/env bash

set -ex

export EXTRA_CMAKE_OPTIONS="-GNinja"

export INSTALL_BASE=opt/hdk
export BUILD_EXT=cpu

# Set flags
case "$PKG_NAME" in

    libhdk)
        export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_CONDA=ON -DENABLE_PYTHON=OFF"        
        ;;

    pyhdk)
        export EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS -DENABLE_CONDA=ON -DENABLE_PYTHON=ON"
        ;;

    *)
        echo "No specific flags set for $PKG_NAME"
        ;;
esac

. ${RECIPE_DIR}/get_cxx_include_path.sh
export CPLUS_INCLUDE_PATH=$(get_cxx_include_path)

mkdir -p build
cd build

set_maven_proxy() {
    mkdir -p ~/.m2

    cat <<EOF >~/.m2/settings.xml
<settings>
  <proxies>
    <proxy>
      <active>true</active>
      <protocol>https</protocol>
      <host>$1</host>
      <port>$2</port>
    </proxy>
  </proxies>
</settings>
EOF
    cat ~/.m2/settings.xml
}

# Set Maven proxy if any
test -z "$HTTPS_PROXY" || set_maven_proxy $(echo $HTTPS_PROXY | sed -e 's#.*/##g; s#:# #')

# Run configure
case "$PKG_NAME" in

    libhdk | pyhdk)

        cmake -Wno-dev \
              -DCMAKE_PREFIX_PATH=$PREFIX \
              -DCMAKE_INSTALL_PREFIX=$PREFIX/$INSTALL_BASE \
              -DCMAKE_BUILD_TYPE=Release \
              -DENABLE_AWS_S3=off \
              -DENABLE_FOLLY=off \
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

    libhdk)

        # ninja
        make -j && make install
        ;;

    pyhdk)

        # cd python
        # $PYTHON setup.py build_ext -g -f install
        # cd python
        # $PYTHON setup.py build_ext -g -f install
        # cd ..
        ninja
        # cd python
        # $PYTHON setup.py build_ext -g -f install
        # cd ..
        # ninja pyhdk        
        # make -j && make install
        ;;

esac
cd ..

# Run install
case "$PKG_NAME" in
    pyhdk)
        # ninja pyhdk-install
        cmake --install build --prefix $PREFIX/$INSTALL_BASE        

        # create activate/deactivate scripts
        mkdir -p "${PREFIX}/etc/conda/activate.d"
        cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOF
#!/bin/bash

# Backup environment variables (only if the variables are set)
if [[ ! -z "\${HDK_ROOT_PATH+x}" ]]
then
  export HDK_ROOT_PATH_BACKUP="\${HDK_ROOT_PATH:-}"
fi

# HDK_ROOT_PATH is requires for hdk's *.so to determine the
# the hdk root path correctly.
export HDK_ROOT_PATH=\${CONDA_PREFIX}/${INSTALL_BASE}

EOF

        mkdir -p "${PREFIX}/etc/conda/deactivate.d"
        cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOF
#!/bin/bash

# Restore environment variables (if there is anything to restore)
if [[ ! -z "\${HDK_ROOT_PATH_BACKUP+x}" ]]
then
  export HDK_ROOT_PATH="\${HDK_ROOT_PATH_BACKUP}"
  unset HDK_ROOT_PATH_BACKUP
fi

EOF

        ;;

    *)
        echo "Nothing installed for $PKG_NAME"
        ;;
esac
