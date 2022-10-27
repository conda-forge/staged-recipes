@echo ON

rmdir /Q /S build
mkdir build
cd build

if /I "%PKG_NAME%" == "libthermo" (
	cmake .. ^
	    %CMAKE_ARGS% ^
		-GNinja ^
		-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
		-DCMAKE_PREFIX_PATH=%PREFIX% ^
		-DCMAKE_BUILD_TYPE="Release" ^
		-DLIBTHERMO_USE_XTENSOR=ON ^
		-DXTENSOR_USE_XSIMD=ON  ^
		-DXTENSOR_USE_TBB=ON
)
if /I "%PKG_NAME%" == "pythermo" (
	cmake .. ^
	    %CMAKE_ARGS% ^
		-GNinja ^
		-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
		-DCMAKE_PREFIX_PATH=%PREFIX% ^
		-DCMAKE_BUILD_TYPE="Release" ^
		-DLIBTHERMO_USE_XTENSOR=ON ^
		-DXTENSOR_USE_XSIMD=ON  ^
		-DXTENSOR_USE_TBB=ON  ^
		-DBUILD_PY=ON
)
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

if /I "%PKG_NAME%" == "pythermo" (
	cd ../pythermo
	rmdir /Q /S build
	%PYTHON% -m pip install . --no-deps -vv
	del *.pyc /a /s
)
