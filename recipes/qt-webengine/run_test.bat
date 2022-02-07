pushd test
if exist .qmake.stash del /a .qmake.stash

:: Only test that this builds
if %ErrorLevel% neq 0 exit /b 1
qmake qtwebengine.pro
if %ErrorLevel% neq 0 exit /b 1
nmake
if %ErrorLevel% neq 0 exit /b 1
popd
