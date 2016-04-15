cd src\tools\msvc

echo $config-^>{openssl} = '%LIBRARY_PREFIX%'; >> config.pl
echo $config-^>{zlib} = '%LIBRARY_PREFIX%';    >> config.pl
echo $config-^>{python} = '%PREFIX%';          >> config.pl

:: Need to move a more current msbuild into PATH.  32-bit one in particular on AppVeyor barfs on the solution that
::    Postgres writes here.  This one comes from the Win7 SDK (.net 4.0), and is known to work.
if "%ARCH%" == "32" (
   COPY C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe .\
   set "PATH=%CD%;%PATH%"
)

call build.bat
call install.bat "%LIBRARY_PREFIX%"
call vcregress check
call vcregress installcheck
call vcregress plcheck
call vcregress contribcheck
