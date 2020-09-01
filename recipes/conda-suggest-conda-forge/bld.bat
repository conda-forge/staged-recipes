mkdir %PREFIX%\\share\\conda-suggest
copy share\\conda-suggest\\conda-forge.noarch.map %PREFIX%\\share\\conda-suggest
if errorlevel 1 exit /b 1
copy share\\conda-suggest\\conda-forge.%build_platform%.map %PREFIX%\\share\\conda-suggest
if errorlevel 1 exit /b 1
