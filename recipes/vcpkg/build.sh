cd toolsrc

mkdir build
cd build

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake .. \
	-G "Ninja" \
	-DCMAKE_BUILD_TYPE=Release \
	-DVCPKG_DEVELOPMENT_WARNINGS=OFF \
	${CMAKE_ARGS}

ninja

mkdir -p $PREFIX/bin/
mv vcpkg $PREFIX/bin/

cd ../
rm -rf toolsrc
mkdir -p $PREFIX/share/vcpkg

mv $SRC_DIR/ports $PREFIX/share/vcpkg/
mv $SRC_DIR/scripts $PREFIX/share/vcpkg/
mv $SRC_DIR/triplets $PREFIX/share/vcpkg/

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done