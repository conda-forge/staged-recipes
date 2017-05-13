# download and compile libseabreeze
cd extra/libseabreeze/SeaBreeze
if [ "$(uname)" == "Darwin" ]; then
    echo "Platform: Mac"
    make logger=0 install_name="${PREFIX}/lib/libseabreeze${SHLIB_EXT}" lib/libseabreeze${SHLIB_EXT}
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Platform: Linux"
    # we need libusb headers on circleci
    yum install -y libusb-devel
    make logger=0 lib/libseabreeze${SHLIB_EXT}
fi
cd ../../..
cp extra/libseabreeze/SeaBreeze/lib/libseabreeze${SHLIB_EXT} ${PREFIX}/lib
# the shared object should have been copied to "${PREFIX}/lib"
python setup.py install --single-version-externally-managed --record record.txt
