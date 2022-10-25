@echo on

md "%PREFIX%\Library" "%PREFIX%\Scripts"
copy "%RECIPE_DIR%\symlink-exe.c" "%PREFIX%\Library\" || exit 1
copy "%RECIPE_DIR%\build-symlink-exe.bat" "%PREFIX%\Scripts\" || exit 1
copy "%RECIPE_DIR%\build-symlink-exe.sh" "%PREFIX%\Scripts\" || exit 1
