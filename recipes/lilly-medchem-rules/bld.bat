@echo off

nmake

mkdir "-p" "%PREFIX%/bin/"

COPY  "%CD%\bin\mc_first_pass" "%PREFIX%/bin/"
COPY  "%CD%\bin\tsubstructure" "%PREFIX%/bin/"
COPY  "%CD%\bin\iwdemerit" "%PREFIX%/bin/"
COPY  "%CD%\bin\mc_summarise" "%PREFIX%/bin/"
