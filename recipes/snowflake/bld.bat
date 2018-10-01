set BP=%SP_DIR%\snowflake
mkdir %BP%
copy %RECIPE_DIR%\__init__.py %BP%\
%PYTHON% -c "import snowflake"

