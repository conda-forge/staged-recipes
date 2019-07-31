# if [ -f "$PREFIX/setup.sh" ]; then source $PREFIX/setup.sh; fi

mkdir build
cd build

# turn this into a catkin workspace by adding the catkin token if it doesn't
# exist already
if [ ! -f $PREFIX/.catkin ]; then
    touch $PREFIX/.catkin
fi

# NOTE: there might be undefined references occurring
# in the Boost.system library, depending on the C++ versions
# used to compile Boost and/or the piranha examples. We
# can avoid them by forcing the use of the header-only
# version of the library.
export CXXFLAGS="$CXXFLAGS -DBOOST_ERROR_CODE_HEADER_ONLY"

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX \
         -DCMAKE_PREFIX_PATH=$PREFIX \
         -DCMAKE_INSTALL_LIBDIR=lib \
         -DCMAKE_BUILD_TYPE=Release \
         -DSETUPTOOLS_DEB_LAYOUT=OFF
         # remove the following line for catkin so `setup.sh` scripts are installed!
         # -DCATKIN_BUILD_BINARY_PACKAGE="1" \

make VERBOSE=1 -j${CPU_COUNT}
make install
mkdir -p $PREFIX/etc/conda/activate.d/

cd ..
# remove prefix from setup sh so that patch works
sed -i".bak" -e "s#_CATKIN_SETUP_DIR:=$PREFIX#_CATKIN_SETUP_DIR:=ABCABCPLACEHOLDERABCABC#g" $PREFIX/setup.sh
sed -i'.bak' -e 's/setup.sh/etc\/conda\/activate.d\/setup.sh/g' $PREFIX/.rosinstall

patch $PREFIX/setup.sh < ${RECIPE_DIR}/003_ros_setup.patch
patch $PREFIX/_setup_util.py < ${RECIPE_DIR}/004_setup_util.patch

mv $PREFIX/setup.sh $PREFIX/etc/conda/activate.d/ros_setup.sh
mv $PREFIX/_setup_util.py $PREFIX/etc/conda/activate.d/ros_setup_util.py

# handled by conda activate
rm $PREFIX/setup.*
rm $PREFIX/local_setup.*
rm $PREFIX/env.sh