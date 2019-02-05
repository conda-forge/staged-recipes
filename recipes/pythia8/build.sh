set -e

if [ "$(uname)" == "Linux" ]; then
    PYTHIA_ARCH=LINUX
else
    PYTHIA_ARCH=DARWIN
fi

if [ "${ARCH}" == "64" ]; then
    EXTRAS="--enable-64bit"
else
    EXTRAS=""
fi

./configure \
    --with-python-include="$(python -c "from sysconfig import get_paths; info = get_paths(); print(info['include'])")" \
    --with-python-bin="${PREFIX}/bin/" \
    --arch=${PYTHIA_ARCH} \
    --enable-shared \
    --prefix=${PREFIX} \
    ${EXTRAS}

make install -j${CPU_COUNT}

# Make links so conda can find the bindings
ln -s "${PREFIX}/lib/pythia8.py" "${SP_DIR}/"
if [ "$(uname)" == "Linux" ]; then
    ln -s "${PREFIX}/lib/libpythia8.so" "${SP_DIR}/"
else
    ln -s "${PREFIX}/lib/libpythia8.dylib" "${SP_DIR}/"
fi
ln -s "${PREFIX}/lib/_pythia8.so" "${SP_DIR}/"

