:: Write python configuration, see https://github.com/boostorg/build/issues/194
@echo using python > user-config.jam
@echo : %PY_VER% >> user-config.jam
@echo : %PYTHON:\=\\% >> user-config.jam
@echo : %PREFIX:\=\\%\\include >> user-config.jam
@echo : %PREFIX:\=\\%\\libs >> user-config.jam
@echo ; >> user-config.jam
xcopy user-config.jam C:\Users\appveyor

:: Start with bootstrap
call bootstrap.bat
if errorlevel 1 exit 1

:: Build step
.\b2 install ^
    --build-dir=buildboost ^
    --prefix=%LIBRARY_PREFIX% ^
    toolset=msvc-%VS_MAJOR%.0 ^
    address-model=%ARCH% ^
    variant=release ^
    threading=multi ^
    link=static,shared ^
    --layout=system ^
    --with-python ^
    -j%CPU_COUNT%
if errorlevel 1 exit 1

:: Move dll's to LIBRARY_BIN
move %LIBRARY_LIB%\boost*.dll "%LIBRARY_BIN%"
if errorlevel 1 exit 1

cd escript
scons -j%CPU_COUNT% \
    cxx=%PREFIX%/bin/g++.exe \
    cxx_flags=" -mdll" \
    options_file=%SRC_DIR%/escript/scons/templates/stretch_options.py \
    prefix=%PREFIX% \
    build_dir=%SRC_DIR%/escript_build \
    boost_prefix=%PREFIX%/esys/boost \
    boost_libs='boost_python${py}' \
    pythonlibpath=%PREFIX%/lib \
    pythonincpath=%PREFIX%/include/python${PY_VER} \
    pythonlibname=python%PY_VER% \
    paso=1 \
    trilinos=0 \
    trilinos_prefix=%PREFIX%/esys/trilinos \
    umfpack=1 \
    umfpack_prefix=%PREFIX% \
    lapack=0 \
    lapack_prefix=[%PREFIX%/include/atlas,%PREFIX%/lib] \
    lapack_libs=['lapack'] \
    netcdf=no \
    netcdf_prefix=%PREFIX%] \
    netcdf_libs=['netcdf_c++4','netcdf'] \
    werror=0 \
    build_full