pwsh dotnet-install.ps1 -InstallDir %PREFIX%\opt\dotnet -Version %PKG_VERSION%
mkdir %PREFIX%\etc\conda\activate.d
mkdir %PREFIX%\etc\conda\deactivate.d
copy %RECIPE_DIR%\win\activate.d %PREFIX%\etc\conda\activate.d
copy %RECIPE_DIR%\win\deactivate.d %PREFIX%\etc\conda\deactivate.d
copy %RECIPE_DIR%\common\activate.d %PREFIX%\etc\conda\activate.d
copy %RECIPE_DIR%\common\deactivate.d %PREFIX%\etc\conda\deactivate.d
