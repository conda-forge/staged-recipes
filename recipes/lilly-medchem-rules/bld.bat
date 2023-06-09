@echo off

set "-ex"

make

mkdir "-p" "%PREFIX%/bin/"

COPY  "%CD%\..\mc_first_pass" "%PREFIX%/bin/"
COPY  "%CD%\..\tsubstructure" "%PREFIX%/bin/"
COPY  "%CD%\..\iwdemerit" "%PREFIX%/bin/"
COPY  "%CD%\..\mc_summarise" "%PREFIX%/bin/"
