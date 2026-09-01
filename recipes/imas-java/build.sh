#!/bin/bash
set -euxo pipefail

# The upstream build system expects:
#  * an `idsinfo` command that reports the location of a built Data
#    Dictionary (IDSDef.xml) -- normally provided by the imas-data-dictionary
#    PyPI package, which is not (yet) available on conda-forge;
#  * a Python venv with `saxonche` (SaxonC-HE, PyPI-only) to run the XSLT 2.0
#    transformations that generate the IDS classes. Creating that venv would
#    `pip install` from the network, which is not possible in conda-forge CI.
#
# We avoid both without patching the sources:
#  1. build IDSDef.xml from the bundled Data Dictionary sources with Saxon-HE;
#  2. provide a minimal `idsinfo` stand-in pointing at it;
#  3. replace common/xsltproc.py with a Saxon-HE (Java) based drop-in;
#  4. pre-create the venv so the build system skips venv creation and pip.

# Classpath with the Saxon-HE jars from the saxon-he conda package
SAXON_CLASSPATH=$(printf '%s:' "${BUILD_PREFIX}"/lib/SaxonHE/*.jar "${BUILD_PREFIX}"/lib/SaxonHE/lib/*.jar)
export SAXON_CLASSPATH="${SAXON_CLASSPATH%:}"

# 1. Generate IDSDef.xml from the Data Dictionary sources (same command that
#    the upstream build system runs when building the DD from source)
pushd data-dictionary
java -cp "${SAXON_CLASSPATH}" net.sf.saxon.Transform \
    -xsl:dd_data_dictionary.xml.xsl \
    -s:dd_data_dictionary.xml.xsd \
    -o:IDSDef.xml \
    DD_GIT_DESCRIBE="${DD_VERSION}"
popd

# Assemble the layout expected by ALBuildDataDictionary.cmake:
# IDSDef.xml with the identifier XML files in per-IDS subdirectories next to it
mkdir -p dd
cp data-dictionary/IDSDef.xml dd/
for f in data-dictionary/schemas/*/*_identifier.xml; do
    d="dd/$(basename "$(dirname "${f}")")"
    mkdir -p "${d}"
    cp "${f}" "${d}/"
done

# 2. Minimal `idsinfo` stand-in: only `idsinfo idspath` is used by the build
mkdir -p shim-bin
cat > shim-bin/idsinfo << EOF
#!/bin/bash
echo "${SRC_DIR}/dd/IDSDef.xml"
EOF
chmod +x shim-bin/idsinfo
export PATH="${SRC_DIR}/shim-bin:${PATH}"

# 3. Saxon-HE based replacement for the saxonche-based xsltproc.py
cp "${RECIPE_DIR}/xsltproc.py" common/xsltproc.py

# 4. Pre-create the venv expected at <builddir>/dd_build_env so that the build
#    system does not attempt to create it and `pip install saxonche`
mkdir -p build
python -m venv build/dd_build_env

# The build system requires find_package(Python): point it explicitly at the
# python interpreter in the build environment, as the restricted search paths
# used in conda builds prevent FindPython from locating it on its own
PY_EXE="$(which python)"
PY_INC="$("${PY_EXE}" -c 'import sysconfig; print(sysconfig.get_path("include"))')"

# Point FindJNI/FindJava at the JDK from the openjdk package in the host env
export JAVA_HOME="${PREFIX}/lib/jvm"

# CMAKE_JAVA_COMPILE_FLAGS: target Java 11 bytecode so the jars run on any
# JRE >= 11 (matching the `openjdk >=11` run requirement)
cmake ${CMAKE_ARGS} \
    -G Ninja \
    -B build \
    -S "${SRC_DIR}" \
    -D CMAKE_BUILD_TYPE=Release \
    -D Python_EXECUTABLE="${PY_EXE}" \
    -D Python_INCLUDE_DIR="${PY_INC}" \
    -D "CMAKE_JAVA_COMPILE_FLAGS=--release;11" \
    -D AL_DOWNLOAD_DEPENDENCIES=OFF \
    -D AL_DEVELOPMENT_LAYOUT=OFF \
    -D AL_PLUGINS=OFF \
    -D AL_TESTS=OFF \
    -D AL_EXAMPLES=OFF

cmake --build build --target install
