@echo on
setlocal EnableDelayedExpansion

:: CMake does not like paths with \ characters
set LIBRARY_PREFIX="%LIBRARY_PREFIX:\=/%"
set BUILD_PREFIX="%BUILD_PREFIX:\=/%"
set SRC_DIR="%SRC_DIR:\=/%"

:: Compile the common libraries. These are shared by other feedstocks
:: and by the subpackages in this feedstock.
cmake -G "Ninja" ^
    -S . -B .build/common ^
    -DGOOGLE_CLOUD_CPP_ENABLE=__common__ ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_MODULE_PATH="%LIBRARY_PREFIX%/lib/cmake" ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DGOOGLE_CLOUD_CPP_ENABLE_EXAMPLES=OFF ^
    -DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF
if %ERRORLEVEL% neq 0 exit 1

cmake --build .build/common --config Release
if %ERRORLEVEL% neq 0 exit 1

cmake --install .build/common --prefix stage
if %ERRORLEVEL% neq 0 exit 1

set STAGE="%cd:\=/%"

:: These subpackages are the most commonly used features of google-cloud-cpp.
:: We want to compile them in the core feedstock.
FOR %%G IN (oauth2 bigtable storage spanner) DO (
    cmake -G "Ninja" ^
        -S . -B .build/%%G ^
        -DGOOGLE_CLOUD_CPP_ENABLE=%%G ^
        -DGOOGLE_CLOUD_CPP_USE_INSTALLED_COMMON=ON ^
        -DCMAKE_PREFIX_PATH="%STAGE%/stage" ^
        -DBUILD_TESTING=OFF ^
        -DBUILD_SHARED_LIBS=OFF ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DCMAKE_CXX_STANDARD=17 ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
        -DCMAKE_MODULE_PATH="%LIBRARY_PREFIX%/lib/cmake" ^
        -DCMAKE_INSTALL_LIBDIR=lib ^
        -DGOOGLE_CLOUD_CPP_ENABLE_EXAMPLES=OFF ^
        -DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF
    if %ERRORLEVEL% neq 0 exit 1

    cmake --build .build/%%G --config Release
    if %ERRORLEVEL% neq 0 exit 1
)

:: `pubsub` must to be compiled with `iam` and policytroubleshooter with `iam`
cmake -G "Ninja" ^
    -S . -B .build/pubsub ^
    -DGOOGLE_CLOUD_CPP_ENABLE=pubsub,iam,policytroubleshooter ^
    -DGOOGLE_CLOUD_CPP_USE_INSTALLED_COMMON=ON ^
    -DCMAKE_PREFIX_PATH="%STAGE%/stage" ^
    -DBUILD_TESTING=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_MODULE_PATH="%LIBRARY_PREFIX%/lib/cmake" ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DGOOGLE_CLOUD_CPP_ENABLE_EXAMPLES=OFF ^
    -DGOOGLE_CLOUD_CPP_ENABLE_WERROR=OFF
if %ERRORLEVEL% neq 0 exit 1

cmake --build .build/pubsub --config Release
if %ERRORLEVEL% neq 0 exit 1
