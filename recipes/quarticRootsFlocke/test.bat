dir %LIBRARY_LIB%
Rem %CXX% %CXXFLAGS% -L"%LIBRARY_LIB%" -I "%LIBRARY_INC%/Quartic" "%RECIPE_DIR%/test_linkage.cpp" -o test_linkage /Wall -lQuartic_linux_static
%CXX% %CXXFLAGS% /I"%LIBRARY_INC%/Quartic" "%RECIPE_DIR%/test_linkage.cpp" /OUT:"test_linkage.exe" /DYNAMICBASE "%LIBRARY_LIB%\Quartic_XXX_static.lib"


test_linkage

