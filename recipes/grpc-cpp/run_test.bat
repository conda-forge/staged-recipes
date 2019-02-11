@echo on

@rem Compile a trivial service definition to C++

protoc -I%RECIPE_DIR% --plugin=protoc-gen-grpc=%PREFIX%/bin/grpc_cpp_plugin.exe --grpc_out=. hello.proto || exit /B

if errorlevel 1 exit 1

if not exist hello.grpc.pb.h exit 1
if not exist hello.grpc.pb.cc exit 1
