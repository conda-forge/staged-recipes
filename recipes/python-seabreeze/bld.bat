REM download and compile libseabreeze
cd extra\libseabreeze\SeaBreeze
if %ARCH% == 32 (
  set SBARCH=Win32
  set WDDKSBPATH="C:\\WinDDK\\7600.16385.1\\lib\\wxp\\i386"
  set SBPATH="os-support\\windows\\VisualStudio2008\\VSProj\\"
) else (
  set SBARCH=x64
  set WDDKSBPATH="C:\\WinDDK\\7600.16385.1\\lib\\wlh\\amd64"
  set SBPATH="os-support\\windows\\VisualStudio2008\\VSProj\\x64\\"
)
REM update the old project files
if %VS_MAJOR% == 9 (
  REM py27
  vcbuild.exe /platform:%SBARCH% "os-support\\windows\\VisualStudio2008\\VSProj\\SeaBreeze.vcproj" Release
  cp "%SBPATH%Release\\SeaBreeze.dll" %LIBRARY_BIN%
  cp "%SBPATH%Release\\SeaBreeze.lib" %LIBRARY_LIB%
) else (
  REM py35 py36
  msbuild.exe /t:SeaBreeze /p:Configuration=Release /p:Platform=%SBARCH% "os-support\\windows\\VisualStudio2015\\SeaBreeze.sln"
  cp lib\SeaBreeze.dll %LIBRARY_BIN%
  cp lib\SeaBreeze.lib %LIBRARY_LIB%
)
cd ../../..
REM at this stage it needs to be in 
"%PYTHON%" setup.py build_ext --library-dirs="%LIBRARY_LIB%;%WDDKSBPATH%"
if errorlevel 1 exit 1
"%PYTHON%" setup.py build
if errorlevel 1 exit 1
"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
