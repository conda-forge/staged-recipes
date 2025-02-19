cmake -GNinja ^
      -DBoost_NO_BOOST_CMAKE=ON ^
      -DBUILD_SHARED_LIBS=OFF ^
      -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DBOOST_ROOT=%LIBRARY_PREFIX% ^
      -DBOOST_LINK_STATIC=OFF ^
      -DCMAKE_C_FLAGS="/DGLOG_NO_ABBREVIATED_SEVERITIES /DNOMINMAX" ^
      -DCMAKE_CXX_FLAGS="/DGLOG_NO_ABBREVIATED_SEVERITIES /DNOMINMAX" ^
      %SRC_DIR%
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
