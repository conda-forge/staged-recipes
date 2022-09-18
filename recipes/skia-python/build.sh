export PATH="$PWD/depot_tools:$PATH"
cd skia
python tools/git-sync-deps
bin/gn gen out/Release --args='is_official_build=true skia_enable_tools=true skia_use_system_libjpeg_turbo=false skia_use_system_libwebp=false skia_use_system_libpng=false skia_use_system_icu=false skia_use_system_harfbuzz=false extra_cflags_cc=["-frtti"] extra_ldflags=["-lrt"]'
ninja -C out/Release skia skia.h
cd ..
export SKIA_PATH=$PWD/skia
export SKIA_OUT_PATH=$SKIA_PATH/out/Release
python setup.py bdist_wheel
