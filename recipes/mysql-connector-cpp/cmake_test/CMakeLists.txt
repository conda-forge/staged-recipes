cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(cmake_test)

set(CMAKE_MODULE_PATH "$ENV{CONDA_PREFIX}/lib/cmake")

find_package(MySQLConnectorCPP REQUIRED)

if(NOT TARGET MySQLConnectorCPP::cppconn)
    message(FATAL_ERROR "MySQLConnectorCPP::cppconn not found")
endif()

if(NOT TARGET MySQLConnectorCPP::cppconn::static)
    message(FATAL_ERROR "MySQLConnectorCPP::cppconn::static not found")
endif()
