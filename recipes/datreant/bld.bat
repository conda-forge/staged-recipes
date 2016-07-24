set BP=%SP_DIR%\datreant
mkdir %BP%
copy %RECIPE_DIR%\__init__.py %BP%\
%PYTHON% -c "import datreant"
