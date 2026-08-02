@echo off
if defined CONDA_SWIFT_BIN call set "PATH=%%PATH:%CONDA_SWIFT_BIN%;=%%"
set "SWIFT="
set "SWIFTC="
set "SWIFT_EXEC="
set "CONDA_SWIFT_COMPILER="
set "CONDA_SWIFT_BIN="
