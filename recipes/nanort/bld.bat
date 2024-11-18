mkdir %PREFIX%\\Library
mkdir %PREFIX%\\Library\\include

cp nanort.h %PREFIX%\\Library\\include\\nanort.h
if %ERRORLEVEL% neq 0 exit 1
