rem Alphabetic ordering is important here.
if not exist "%PREFIX%\etc\conda\activate.d" md "%PREFIX%\etc\conda\activate.d"
copy "%RECIPE_DIR%\activate-r-clang_win-64.bat" "%PREFIX%\etc\conda\activate.d\vs%YEAR%_z-r-clang_win-64.bat"
md "%PREFIX%\etc\conda\deactivate.d"
copy "%RECIPE_DIR%\deactivate-r-clang_win-64.bat" "%PREFIX%\etc\conda\deactivate.d\vs%YEAR%_z-r-clang_win-64.bat"
if not exist "%PREFIX%\Library\bin" md "%PREFIX%\Library\bin"
copy "%RECIPE_DIR%\r_clang_wrapper.bat" "%PREFIX%\Library\bin\r_clang_wrapper.bat"
copy "%RECIPE_DIR%\r_clangxx_wrapper.bat" "%PREFIX%\Library\bin\r_clangxx_wrapper.bat"

