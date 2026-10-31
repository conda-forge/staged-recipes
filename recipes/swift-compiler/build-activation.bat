@echo on
mkdir "%PREFIX%\etc\conda\activate.d"
mkdir "%PREFIX%\etc\conda\deactivate.d"
copy "%RECIPE_DIR%\activate.bat" "%PREFIX%\etc\conda\activate.d\activate-swift.bat"
copy "%RECIPE_DIR%\deactivate.bat" "%PREFIX%\etc\conda\deactivate.d\deactivate-swift.bat"
