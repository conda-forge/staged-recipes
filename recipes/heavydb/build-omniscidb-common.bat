@echo on

@REM Contains a patch for arrow-cpp
@REM https://github.com/apache/arrow/pull/11806
COPY %RECIPE_DIR%\arrow_aligned_storage.h %PREFIX%\Library\include\arrow\util\aligned_storage.h
if errorlevel 1 exit 1

mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

COPY %PREFIX%\Library\lib\thriftmd.lib %PREFIX%\Library\bin\thriftmd.lib
COPY %PREFIX%\Library\lib\xerces-c_3.lib %PREFIX%\Library\lib\xerces-c.lib


:: /wd4711 and /wd4710 disables warning C4711/C4710

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DCMAKE_PREFIX_PATH=%PREFIX% ^
      -DCMAKE_LIBRARY_PATH=%PREFIX%\Library\lib ^
      -DCMAKE_INCLUDE_PATH=%PREFIX%\Library\include ^
      -DLibArchive_INCLUDE_DIR=%PREFIX\include ^
      -DLibArchive_LIBRARY=%PREFIX%\Library\lib\archive.lib ^
      -DLZMA_LIBRARY=%PREFIX%\Library\lib\liblzma.lib ^
      -DBZ2_LIBRARY=%PREFIX%\Library\lib\libbz2.lib ^
      -DGDAL_LIBRARIES=%PREFIX%\Library\lib\gdal_i.lib^
      -DGDAL_INCLUDE_DIR=%PREFIX%\Library\include ^
      -DCMAKE_CXX_FLAGS="/MP /W0 /wd4625 /wd4596 /wd4710 /wd4711 -DBOOST_ALL_DYN_LINK=1 -DBOOST_PROGRAM_OPTIONS_DYN_LINK=1" ^
      -DBoost_USE_STATIC_LIBS=OFF ^
      -DENABLE_FOLLY=OFF ^
      -DENABLE_TESTS=OFF ^
      -DENABLE_CUDA=OFF ^
      -DENABLE_GEOS=OFF ^
      -DENABLE_FSI_ODBC=OFF ^
      -DENABLE_AWS_S3=OFF ^
      -DENABLE_LDAP=OFF ^
      -DMAPD_EDITION=EE ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_VERBOSE_MAKEFILE=OFF ^
      -DENABLE_NO_WINWARNINGS=ON ^
      "%SRC_DIR%"
if errorlevel 1 exit 1

cmake --build . --target QueryEngineFunctionsTargets mapd_java_components generate_cert_target --config Release
if errorlevel 1 exit 1

cmake --install . --component "include" --prefix %PREFIX%
cmake --install . --component "doc" --prefix %PREFIX%\share\doc\omnisci
cmake --install . --component "data" --prefix %PREFIX%
cmake --install . --component "thrift" --prefix %PREFIX%
cmake --install . --component "QE" --prefix %PREFIX%
cmake --install . --component "jar" --prefix %PREFIX%
cmake --install . --component "Unspecified" --prefix %PREFIX%
if errorlevel 1 exit 1

popd
