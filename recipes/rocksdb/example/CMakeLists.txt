#Specify the version being used aswell as the language
cmake_minimum_required(VERSION 2.6)

#Name your project here
project(icetable)

#This tells CMake to fib.c and name it fibonacci
add_executable(rocks main.cpp)

# Dependencies
find_library(rocksdb rocksdb)
find_library(gflags gflags)

target_link_libraries(rocks 
	rocksdb
	gflags
	)
