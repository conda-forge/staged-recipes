env
if [[ "$target_platform" == "osx-64" ]]; then
    TARGET_OS_OSX=1
fi

python scripts/mk_make.py --python
cd build
make
make install
