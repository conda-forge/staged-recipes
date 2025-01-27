#! /bin/sh
#
# PKG_CONFIG_PATH
if [ ! -d "$PKG_CONFIG_PATH" ]
then
	echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
	echo 'Environment setting for PKG_CONFIG_PATH does not exist'
	PKG_CONFIG_PATH=''
fi
for dir in lib share
do
	PKG_CONFIG_PATH+=":$BUILD_PREFIX/$dir/pkgconfig"
done
echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
#
# extra_cxx_flags
extra_cxx_flags='-Wpedantic -std=c++11 -Wall -Wshadow -Wconversion'
if [[ "${target_platform}" == osx-* ]]; then
   # https://conda-forge.org/docs/maintainer/knowledge_base.html#
   #  newer-c-features-with-old-sdk
   extra_cxx_flags="${extra_cxx_flags} -D_LIBCPP_DISABLE_AVAILABILITY"
fi
#
# build
mkdir build && cd build
#
# cmake
cmake -S $SRC_DIR -B . \
   -G 'Unix Makefiles' \
   -D CMAKE_CROSSCOMPILING=$CONDA_BUILD_CROSS_COMPILATION \
   -D CMAKE_CROSSCOMPILING_EMULATOR=$CONDA_BUILD_CROSS_COMPILATION \
   -D CMAKE_BUILD_TYPE=Release \
   -D cmake_install_prefix="$PREFIX" \
   -D extra_cxx_flags="$extra_cxx_flags" \
   -D cmake_libdir=lib \
   -D ldlt_cholmod=yes \
   -D optimize_cppad_function=yes \
   -D for_hes_sparsity=yes 
#
# check
make -j4 check
#
# install
make install
