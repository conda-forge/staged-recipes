if not exist %PREFIX% mkdir %PREFIX%
mkdir %LIBRARY_INC%\targets
mkdir %LIBRARY_INC%\targets\x64

move include\nvtx3 %LIBRARY_INC%\targets\x64
