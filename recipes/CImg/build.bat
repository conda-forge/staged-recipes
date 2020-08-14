@echo off 

mkdir %PREFIX%\include\ 
mkdir %PREFIX%\include\CImg\plugins 
xcopy %SRC_DIR%\CImg.h %PREFIX%\include\ 
xcopy %SRC_DIR%\plugins\*.h %PREFIX%\include\CImg\plugins 
