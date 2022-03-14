#!/usr/bin/env bash

export RSTUDIO_VERSION_MAJOR=$(echo ${PKG_VERSION} | cut -d. -f1)
export RSTUDIO_VERSION_MINOR=$(echo ${PKG_VERSION} | cut -d. -f2)
export RSTUDIO_VERSION_PATCH=$(echo ${PKG_VERSION} | cut -d. -f3)
export RSTUDIO_VERSION_SUFFIX="+443"
export GIT_COMMIT=fc9e217
export PACKAGE_OS=$(uname -om)

export BUILD_TYPE=Release
export RSTUDIO_TARGET=Desktop

export RSTUDIO_TOOLS_ROOT="${PREFIX}/opt/rstudio-tools/$(uname -m)"
mkdir -p $RSTUDIO_TOOLS_ROOT
export SOCI_LIBRARY_DIR=${PREFIX}/lib
export SOCI_DIR=$RSTUDIO_TOOLS_ROOT/soci
export SOCI_BIN_DIR=$SOCI_DIR/build
mkdir -p $SOCI_BIN_DIR
ln -s ${PREFIX}/* ${SOCI_BIN_DIR}
export SOCI_CORE_LIB=${PREFIX}/lib/libsoci_core.so
export SOCI_POSTGRESQL_LIB=${PREFIX}/lib/libsoci_postgresql.so
export SOCI_SQLITE_LIB=${PREFIX}/lib/libsoci_sqlite3.so

pushd dependencies/common
_pandocver=$(grep -oP "(?<=PANDOC_VERSION=\").*(?=\"$)" install-pandoc)
install -d pandoc/${_pandocver}
ln -sfT ${PREFIX}/bin/pandoc pandoc/${_pandocver}/pandoc
_nodever=$(grep -oP "(?<=NODE_VERSION=\").*(?=\"$)" ../tools/rstudio-tools.sh)
install -d node
ln -sfT ${BUILD_PREFIX} node/${_nodever}
ln -sfT ${PREFIX}/share/hunspell_dictionaries dictionaries
ln -sfT ${PREFIX}/lib/mathjax mathjax-27
#./install-soci
# ./install-gwt
#./install-dictionaries
#./install-packagesln -sfT common/dictionaries dictionaries
# ./install-boost
# ./install-pandoc
# ./install-libclang
# ./install-packages
popd

pushd dependencies
# Fix links for src/cpp/session/CMakeLists.txt
ln -sfT common/dictionaries dictionaries
ln -sfT common/mathjax-27 mathjax-27
ln -sfT common/pandoc pandoc
ln -sfT common/node node
popd

cmake -S . -B build \
      -DRSTUDIO_TARGET=Desktop \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="${PREFIX}/lib/rstudio" \
      -DRSTUDIO_USE_SYSTEM_BOOST=yes \
      -DRSTUDIO_USE_SYSTEM_YAML_CPP=yes \
      -DQT_QMAKE_EXECUTABLE="${PREFIX}/bin/make" \
      -DBoost_NO_BOOST_CMAKE=ON \
      -DQUARTO_ENABLED=FALSE \
      -DRSTUDIO_BUNDLE_QT=FALSE \
      -DRSTUDIO_USE_SYSTEM_SOCI=yes \
      -DSOCI_CORE_LIB=${PREFIX}/lib/libsoci_core.so \
      -DSOCI_POSTGRESQL_LIB=${PREFIX}/lib/libsoci_postgresql.so \
      -DSOCI_SQLITE_LIB=${PREFIX}/lib/libsoci_sqlite3.so

make -j${CPU_COUNT} -C build install

# Binary wrapper script
echo "#!/bin/env sh
export RSTUDIO_CHROMIUM_ARGUMENTS=\"--no-sandbox\"
${PREFIX}/lib/rstudio/bin/rstudio \"\$@\"
" > "${PREFIX}/bin/rstudio"
