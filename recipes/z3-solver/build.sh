env
if [[ "$target_platform" == osx-64 ]]; then
    TARGET_OS_OSX=1
    echo "Setting TARGET_OS_OSX to 1"
fi

echo "TARGET_OS_OSX is $TARGET_OS_OSX, target_platform is $target_platform"

python scripts/mk_make.py --python
cd build
make
make install
