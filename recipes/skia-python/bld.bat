set PATH=%PATH%;%CD%\depot_tools

cd skia
python tools\git-sync-deps
bin\gn gen out\Release --args='is_official_build=true skia_enable_tools=true skia_use_system_libjpeg_turbo=false skia_use_system_libwebp=false skia_use_system_libpng=false skia_use_system_icu=false skia_use_system_harfbuzz=false skia_use_system_expat=false skia_use_system_zlib=false extra_cflags_cc=[\"/GR\", \"/EHsc\", \"/MD\"] target_cpu=\"x86_64\"'
ninja -C out\Release skia skia.h
cd ..

python setup.py bdist_wheel
