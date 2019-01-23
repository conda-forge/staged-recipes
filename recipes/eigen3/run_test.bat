@echo ON
cl.exe /I%PREFIX%\include /Fe.\test test.cc
test
