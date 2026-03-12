@echo on

mkdir %PREFIX%\bin
xcopy *.exe *.dll %PREFIX%\bin\
