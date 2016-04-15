cd src\tools\msvc

echo $config-^>{openssl} = '%LIBRARY_PREFIX%'; >> config.pl
echo $config-^>{zlib} = '%LIBRARY_PREFIX%';    >> config.pl
echo $config-^>{python} = '%PREFIX%';          >> config.pl

:: Need to move a more current msbuild into PATH.  32-bit one in particular on AppVeyor barfs on the solution that
::    Postgres writes here.  This one comes from the Win7 SDK (.net 4.0), and is known to work.
if "%ARCH%" == "32" (
   COPY C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe .\
   set "PATH=%CD%;%PATH%"
   set ARCH=Win32
) else (
   set ARCH=x64
)

call perl mkvcbuild.pl
call msbuild pgsql.sln /p:Configuration=Release /p:Platform="%ARCH%"
if errorlevel 1 exit 1
call install.bat "%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
call vcregress check
if errorlevel 1 exit 1
call vcregress installcheck
if errorlevel 1 exit 1
call vcregress plcheck
if errorlevel 1 exit 1
call vcregress contribcheck
