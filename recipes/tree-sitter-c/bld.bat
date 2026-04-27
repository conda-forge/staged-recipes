@echo off
setlocal

rem tree-sitter-cpp 0.23.x uses #include "tree_sitter/parser.h" which is no longer
rem a public header in tree-sitter >= 0.23. Vendor it into src/ so the compiler
rem finds it via the existing -Isrc include path.
if not exist "src\tree_sitter" mkdir "src\tree_sitter"
copy "%PREFIX%\Library\include\tree_sitter\parser.h" "src\tree_sitter\parser.h"
if errorlevel 1 exit /b 1

copy "%PREFIX%\Library\include\tree_sitter\alloc.h" "src\tree_sitter\alloc.h"
if errorlevel 1 exit /b 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1