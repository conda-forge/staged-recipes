@echo on

mkdir %PREFIX%\bin
xcopy *.exe %PREFIX%\bin\
xcopy *.dll %PREFIX%\bin\
