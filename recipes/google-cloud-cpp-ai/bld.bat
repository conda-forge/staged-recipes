@echo on
setlocal EnableDelayedExpansion

:: CMake does not like paths with \ characters
set LIBRARY_PREFIX="%LIBRARY_PREFIX:\=/%"
set BUILD_PREFIX="%BUILD_PREFIX:\=/%"
set SRC_DIR="%SRC_DIR:\=/%"

FOR %%G IN (
  aiplatform
  automl
  discoveryengine
  dialogflow_es
  dialogflow_cx
  dlp
  speech
  timeseriesinsights
  translate
  videointelligence
  vision) DO (
    cmake -G "Ninja" ^
        -S . -B .build/%%G ^
        -DGOOGLE_CLOUD_CPP_ENABLE=%%G ^
        -DGOOGLE_CLOUD_CPP_USE_INSTALLED_COMMON=ON ^
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
