msbuild builds\msvc\msvc10.sln /t:libzmq /property:Configuration=Release /property:Platform=x64
mkdir %PREFIX%\include
mkdir %PREFIX%\lib
rem mkdir %PREFIX%\DLLs
copy /y include\* %PREFIX%\include\
copy /y lib\x64\* %PREFIX%\lib\
copy /y bin\x64\libzmq.dll %PREFIX%\lib\