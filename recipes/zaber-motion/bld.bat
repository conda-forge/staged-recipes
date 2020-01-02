@echo ON
setlocal enabledelayedexpansion

set GOOS=windows
if %ARCH% == 64 set GOARCH=amd64
if %ARCH% == 32 set GOARCH=386
set GO111MODULE=on

protoc -I=. --go_out="internal" protobufs\main.proto
if errorlevel 1 exit 1

set zaber_motion_libname=zaber-motion-lib-%GOOS%-%GOARCH%
set zaber_motion_lib=%zaber_motion_libname%.dll
set zaber_motion_header=%zaber_motion_libname%.h
go build -buildmode=c-shared -o .\build\%zaber_motion_lib%
if errorlevel 1 exit 1

dir build

copy build\%zaber_motion_lib% %LIBRARY_BIN%\.
copy build\%zaber_motion_header% %LIBRARY_INC%\.


rem Look at gulpfil.js, protobuf_py
protoc -I=. --python_out="py\zaber_motion\zaber_motion"      ^
    --plugin="protoc-gen-mypy=tools\protoc-gen-mypy.bat"     ^
    --mypy_out="py\zaber_motion\zaber_motion" protobufs\main.proto
if errorlevel 1 exit 1

echo.> py\zaber_motion\zaber_motion\protobufs\__init__.py
if errorlevel 1 exit 1


cd py\zaber_motion
%PYTHON% -m pip install . -vv --no-build-isolation --no-deps
if errorlevel 1 exit 1
cd ..
cd ..
