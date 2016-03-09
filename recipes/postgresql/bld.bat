cd src\tools\msvc

echo $config-^>{openssl} = '%LIBRARY_PREFIX%'; >> config.pl
echo $config-^>{zlib} = '%LIBRARY_PREFIX%';    >> config.pl
echo $config-^>{python} = '%PREFIX%';          >> config.pl

call build.bat
call install.bat "%LIBRARY_PREFIX%"
