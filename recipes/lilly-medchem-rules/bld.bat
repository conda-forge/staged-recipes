@echo off

set "-ex"

make

mkdir "-p" "%PREFIX%/bin/"
COPY  "mc_first_pass" "%PREFIX%/bin/"
COPY  "tsubstructure" "%PREFIX%/bin/"
COPY  "iwdemerit" "%PREFIX%/bin/"
COPY  "mc_summarise" "%PREFIX%/bin/"
